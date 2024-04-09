##' Post-estimation treatment effects for an ETWFE regressions.
##'
##' @param object An `etwfe` model object.
##' @param type Character. The desired type of post-estimation aggregation.
##' @param by_xvar Logical. Should the results account for heterogeneous
##'   treatment effects? Only relevant if the preceding `etwfe` call included a
##'   specified `xvar` argument, i.e. interacted categorical covariate. The
##'   default behaviour ("auto") is to automatically estimate heterogeneous
##'   treatment effects for each level of `xvar` if these are detected as part
##'   of the underlying `etwfe` model object. Users can override by setting to
##'   either FALSE or TRUE. See the section on Heterogeneous treatment effects
##'   below.
##' @param collapse Logical. Collapse the data by (period by cohort) groups
##'   before calculating marginal effects? This trades off a loss in estimate
##'   accuracy (typically around the 1st or 2nd significant decimal point) for a
##'   substantial improvement in estimation time for large datasets. The default
##'   behaviour ("auto") is to automatically collapse if the original dataset
##'   has more than 500,000 rows. Users can override by setting either FALSE or
##'   TRUE. Note that collapsing by group is only valid if the preceding `etwfe`
##'   call was run with "ivar = NULL" (the default). See the section on
##'   Performance tips below.
##' @param post_only Logical. Drop pre-treatment ATTs? Only evaluated if (a)
##'   `type = "event"` and (b) the original `etwfe` model object was estimated
##'   using the default "notyet" treated control group. If conditions (a) and
##'   (b) are met then the pre-treatment effects will be zero as a mechanical
##'   result of ETWFE's estimation setup. The default behaviour (`FALSE`) is
##'   thus to drop these nuisance rows from the dataset. The `post_only` argument
##'   recognises that you may still want to keep them for presentation purposes
##'   (e.g., plotting an event-study). Nevertheless, be forewarned that enabling
##'   that behaviour via `TRUE` is _strictly_ performative: the "zero" treatment
##'   effects for any pre-treatment periods is purely an artefact of the
##'   estimation setup.
##' @param ... Additional arguments passed to
##'   [`marginaleffects::slopes`]. For example, you can pass `vcov =
##'   FALSE` to dramatically speed up estimation times of the main marginal
##'   effects (but at the cost of not getting any information about standard
##'   errors; see Performance tips below). Another potentially useful
##'   application is testing whether heterogeneous treatment effects (i.e. the
##'   levels of any `xvar` covariate) are equal by invoking the `hypothesis`
##'   argument, e.g. `hypothesis = "b1 = b2"`.
##' @return A `slopes` object from the `marginaleffects` package.
##' @seealso [marginaleffects::slopes()]
##' @inherit etwfe return examples 
##' @inheritSection etwfe Performance tips
##' @inheritSection etwfe Heterogeneous treatment effects
##' @importFrom data.table as.data.table setDT .N .SD
##' @importFrom marginaleffects slopes
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    by_xvar = "auto",
    collapse = "auto",
    post_only = TRUE,
    max_e = NULL,
    ...
) {
  
  dots = list(...)

  .Dtreat = NULL
  type = match.arg(type)
  etwfe_attr = attr(object, "etwfe")
  gvar = etwfe_attr[["gvar"]]
  tvar = etwfe_attr[["tvar"]]
  ivar = etwfe_attr[["ivar"]]
  xvar = etwfe_attr[["xvar"]]
  gref = etwfe_attr[["gref"]]
  tref = etwfe_attr[["tref"]]
  cgroup = etwfe_attr[["cgroup"]]
  if (!by_xvar %in% c("auto", TRUE, FALSE)) stop("\"by_xvar\" has to be \"auto\", TRUE, or FALSE.")
  if (!collapse %in% c("auto", TRUE, FALSE)) stop("\"collapse\" has to be \"auto\", TRUE, or FALSE.")

  # sanity check
  if (isTRUE(by_xvar)) {
    if(is.null(xvar)){
      warning(
        "An \"xvar\" attribute was not found as part of the supplied model object. ",
        "(Did your original `etwfe()` call include a valid `xvar = ...` argument?)",
        "Average margins are reported instead."
        )
      by_xvar = FALSE
      }
  }

  if (by_xvar=="auto") by_xvar = !is.null(xvar)
  
  dat = as.data.table(eval(object$call$data, object$call_env))
  if ("group" %in% names(dat)) dat[["group"]] = NULL
  
  # check collapse argument
  nrows = NULL
  if (collapse == "auto") {
    nrows = nrow(dat)

    if (nrows >= 5e5) {
      collapse = TRUE
    } else {
      collapse = FALSE
    }
  }
  
  if (cgroup == "never") {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE] # Drop never treated reference group
    if (type != "event") {
      # For non-event studies, we want to calculated ATTs for post-treatment only
      dat = dat[dat[[".Dtreat"]], , drop = FALSE]
      dat = dat[dat[[tvar]] >= dat[[gvar]], , drop = FALSE]
    }
  } else if (type=="event" & isFALSE(post_only)) {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE]
  } else if (".Dtreat" %in% names(dat)) {
    dat = dat[dat[[".Dtreat"]], , drop = FALSE]
  }
  
  if (is.null(max_e)==FALSE){ #if user specifies max_e, calculate group average or overall effect only for post treatment periods 0 - max_e
    dat = dat[dat[[tvar]] <= (dat[[gvar]]+max_e), , drop = FALSE]
  }
  # define formulas and calculate weights
  if(collapse & is.null(ivar)){
    if(by_xvar){
      dat_weights = dat[(.Dtreat)][, .N, by = c(gvar, tvar, xvar)]
    } else {
      dat_weights = dat[(.Dtreat)][, .N, by = c(gvar, tvar)]
    }
    
   if (!is.null(nrows) && nrows > 5e5) warning(
    "\nNote: Dataset larger than 500k rows detected. The data will be ",
    "collapsed by period-cohort groups to reduce estimation times. ", 
    "However, this shortcut can reduce the accuracy of the reported ",
    "marginal effects. ",
    "To override this default behaviour, specify: ",
    "`emfx(..., collapse = FALSE)`\n"
    ) 
    
    # collapse the data
    dat = dat[(.Dtreat)][, lapply(.SD, mean), by = c(gvar, tvar, xvar, ".Dtreat")] # collapse data
    dat = setDT(dat)[, merge(.SD, dat_weights, all.x = TRUE)] # add weights
    
    
  } else if (collapse & !is.null(ivar)) {
    warning("\"ivar\" is not NULL. Marginal effects are calculated without collapsing.")
    dat$N = 1L
    
  } else {
    dat$N = 1L
  }
  
  # collapse the data 
  if (type=="simple") {
      by_var = ".Dtreat"
  } else if (type=="group") {
    by_var = gvar
  } else if (type=="calendar") {
    by_var = tvar
  } else if (type=="event") {
    dat[["event"]] = dat[[tvar]] - dat[[gvar]]
    by_var = "event"
  }
  
  if (by_xvar) by_var = c(by_var, xvar)

  mfx = slopes(
    object,
    newdata = dat,   
    wts = "N",
    variables = ".Dtreat",
    by = by_var,
    ...
  )

   
  return(mfx)
}

