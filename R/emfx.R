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
##' @param post_only Logical. Only keep post-treatment effects. All
##'   pre-treatment effects will be zero as a mechanical result of ETWFE's
##'   estimation setup, so the default is to drop these nuisance rows from the
##'   dataset. But you may want to keep them for presentation reasons (e.g.,
##'   plotting an event-study); though be warned that this is strictly
##'   performative. This argument will only be evaluated if `type = "event"`.
##' @param ... Additional arguments passed to
##'   [`marginaleffects::marginaleffects`]. For example, you can pass `vcov =
##'   FALSE` to dramatically speed up estimation times of the main marginal
##'   effects (but at the cost of not getting any information about standard
##'   errors; see Performance tips below). Another potentially useful
##'   application is testing whether heterogeneous treatment effects (i.e. the
##'   levels of any `xvar` covariate) are equal by invoking the `hypothesis`
##'   argument, e.g. `hypothesis = "b1 = b2"`.
##' @seealso [marginaleffects::slopes()]
##' @inherit etwfe return examples 
##' @inheritSection etwfe Performance tips
##' @inheritSection etwfe Heterogeneous treatment effects
##' @importFrom data.table .N .SD
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    by_xvar = "auto",
    collapse = "auto",
    post_only = TRUE,
    ...
) {
  
  dots = list(...)

  .Dtreat = NULL
  type = match.arg(type)
  gvar = attributes(object)[["etwfe"]][["gvar"]]
  tvar = attributes(object)[["etwfe"]][["tvar"]]
  ivar = attributes(object)[["etwfe"]][["ivar"]]
  xvar = attributes(object)[["etwfe"]][["xvar"]]
  gref = attributes(object)[["etwfe"]][["gref"]]
  tref = attributes(object)[["etwfe"]][["tref"]]
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
  
  dat = data.table::as.data.table(eval(object$call$data, object$call_env))
  
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
  
  if (type=="event" & !post_only) {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE]
  } else {
    if (".Dtreat" %in% names(dat)) dat = dat[dat[[".Dtreat"]], , drop = FALSE]
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
    dat = data.table::setDT(dat)[, merge(.SD, dat_weights, all.x = TRUE)] # add weights
    
    
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

  mfx = marginaleffects::slopes(
    object,
    newdata = dat,   
    wts = "N",
    variables = ".Dtreat",
    by = by_var,
    ...
  )

  # marginaleffects::slopes() sometimes -- but not always -- returns exact zero rows
  # this code can be removed when this is fixed upstream
  # https://github.com/vincentarelbundock/marginaleffects/issues/624
  if (post_only) {
    vcv = dots$vcov
    # catch for vcov = FALSE
    if (!is.null(vcv) && isFALSE(vcv)) {
      idx = mfx$estimate != 0
    } else {
      idx = mfx$estimate != 0 | mfx$std.error != 0
    }
    mfx = mfx[idx, , drop = FALSE]
  }
  
  if (type!="simple" | !by_xvar) mfx = mfx[order(mfx[[by_var[1]]]),]
   
  return(mfx)
}

