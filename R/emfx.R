##' Post-estimation treatment effects for an ETWFE regressions.
##'
##' @param object An `etwfe` model object.
##' @param type Character. The desired type of post-estimation aggregation.
##' @param xvar Optional interacted categorical covariate for estimating
##' heterogeneous treatment effects. In other words, allows recovery of the
##' (marginal) treatment effect for distinct values of `xvar`. Works with binary
##' categorical variables (e.g. "adult" or "child"), as well as multiple values.
##' @param post_only Logical. Only keep post-treatment effects. All
##'   pre-treatment effects will be zero as a mechanical result of ETWFE's 
##'   estimation setup, so the default is to drop these nuisance rows from
##'   the dataset. But you may want to keep them for presentation reasons
##'   (e.g., plotting an event-study); though be warned that this is 
##'   strictly performative. This argument will only be evaluated if
##'   `type = "event"`.
##' @param collapse Logical. Collapse the data by (period by cohort) groups 
##' before calculating marginal effects? This trades off a loss in estimate 
##' accuracy (typically around the 1st or 2nd significant decimal point) for a 
##' substantial improvement in estimation time for large datasets. The default 
##' behaviour ("auto") is to automatically collapse if the original dataset has 
##' more than 500,000 rows. Users can override by setting either FALSE or TRUE. 
##' Note that collapsing by group is only valid if the preceding `etwfe` call 
##' was run with "ivar = NULL" (the default).
##' @param ... Additional arguments passed to [`marginaleffects::marginaleffects`]. 
##' A potentially useful case is testing whether heterogeneous treatment effects
##' (from any `xvar` covariate) are equal by invoking the `hypothesis` argument,
##' e.g. `hypothesis = "adult = child"`. 
##' @return A `slopes` object from the `marginaleffects` package.
##' @seealso [marginaleffects::slopes()]
##' @inherit etwfe return examples
##' @importFrom data.table .N .SD
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    xvar = NULL,
    post_only = TRUE,
    collapse = "auto",
    ...
) {
  
  # sanity check
  if (!is.null(xvar)) {
    if(!any( grepl(xvar, rownames(object$coeftable)) )){
      warning("The treatment was not interacted with \"xvar\" in the model object. Average margins are reported.")
      xvar = NULL
      }
  }

  .Dtreat = NULL
  type = match.arg(type)
  gvar = attributes(object)[["etwfe"]][["gvar"]]
  tvar = attributes(object)[["etwfe"]][["tvar"]]
  ivar = attributes(object)[["etwfe"]][["ivar"]]
  gref = attributes(object)[["etwfe"]][["gref"]]
  tref = attributes(object)[["etwfe"]][["tref"]]
  if (!collapse %in% c("auto", TRUE, FALSE)) stop("\"collapse\" has to be \"auto\", TRUE, or FALSE.")
  
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
    if(!is.null(xvar)){
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
    if (is.null(xvar)) {
      by_var = ".Dtreat"
    } else {
      by_var = xvar  
    }
  } else if (type=="group") {
    by_var = gvar
  } else if (type=="calendar") {
    by_var = tvar
  } else if (type=="event") {
    dat[["event"]] = dat[[tvar]] - dat[[gvar]]
    by_var = "event"
  }

  mfx = marginaleffects::slopes(
    object,
    newdata = dat,   
    wts = "N",
    variables = ".Dtreat",
    by = c(by_var, xvar),
    ...
  )

  # marginaleffects::slopes() sometimes -- but not always -- returns exact zero rows
  # this code can be removed when this is fixed upstream
  # https://github.com/vincentarelbundock/marginaleffects/issues/624
  if (post_only) {
    idx = mfx$estimate != 0 | mfx$std.error != 0
    mfx = mfx[idx, , drop = FALSE]
  }
  
  if (type!="simple" | !is.null(xvar)) mfx = mfx[order(mfx[[by_var]]),]
   
  return(mfx)
}

