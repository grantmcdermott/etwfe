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
##' before calculating marginal effects? This trades off a loss in estimate 
##' accuracy (typically around the 1st or 2nd significant decimal point) for a 
##' substantial improvement in estimation time for large datasets. The default 
##' behaviour ("auto") is to automatically collapse if the original dataset has 
##' more than 500,000 rows. Users can override by setting either FALSE or TRUE. 
##' Note that collapsing by group is only valid if the preceding `etwfe` call 
##' was run with "ivar = NULL" (the default). See the section on Performance
##' tips below.
##' @param post_only Logical. Only keep post-treatment effects. All
##' pre-treatment effects will be zero as a mechanical result of ETWFE's 
##' estimation setup, so the default is to drop these nuisance rows from
##' the dataset. But you may want to keep them for presentation reasons
##' (e.g., plotting an event-study); though be warned that this is 
##' strictly performative. This argument will only be evaluated if
##' `type = "event"`.
##' @param ... Additional arguments passed to [`marginaleffects::marginaleffects`]. 
##' For example, you can pass `vcov = FALSE` to dramatically speed up estimation
##' times of the main marginal effects (but at the cost of not getting any 
##' information about standard errors; see Performance tips below). Another
##' potentially useful application is testing whether heterogeneous treatment
##' effects (i.e. the levels of any `xvar` covariate) are equal by invoking the
##' `hypothesis` argument, e.g. `hypothesis = "adult = child"`.
##' 
##' @section Heterogeneous treatment effects:
##' 
##'   Specifying `etwfe(..., xvar = <xvar>)` will generate interaction effects
##'   for all levels of `<xvar>` as part of the main regression model. The
##'   reason that this is useful (as opposed to a regular, non-interacted
##'   covariate in the formula RHS) is that it allows us to estimate
##'   heterogeneous treatment effects as part of the larger ETWFE framework.
##'   Specifically, we can recover heterogeneous treatment effects for each
##'   level of `<xvar>` by passing the resulting `etwfe` model object on to 
##'   `emfx()`.
##'   
##'   For example, imagine that we have a categorical variable called "age" in
##'   our dataset, with two distinct levels "adult" and "child". Running
##'   `etwfe(..., xvar = age) |> emfx(...)` will tell us how the efficacy of 
##'   treatment varies across adults and children. The same principle carries
##'   over to variables with multiple levels.
##'   
##' @section Performance tips: 
##' 
##'   For datasets smaller than 100k rows, `emfx` should complete quite
##'   quickly; within a few seconds or less. However, the computation time does
##'   tend to scale linearly with the size of the data, as well as the number of
##'   interactions from the original `etwfe` model. Without getting too far into
##'   the weeds, the delta method of the underlying marginal effects calculation
##'   has to estimate two prediction models for *each* coefficient in the model
##'   and then compute their standard errors. So, it's a potentially expensive
##'   operation. 
##'   
##'   However, there are two key strategies that you can use to speed things up.
##'   The first is to pass "vcov = FALSE" as an argument to `emfx`. Doing so
##'   should reduce the estimation time to less than a second, even for datasets
##'   in excess of a million rows. This approach does come at the cost of not
##'   returning any standard errors. Yet it can be useful to combine our first
##'   strategy with a second strategy, which is to invoke the "collapse = TRUE"
##'   argument. Collapsing the data by groups prior to estimating the marginal
##'   effects can yield a substantial speed increase (albeit not nearly as
##'   dramatic as turning of the vcov calculations). But we do get standard
##'   errors this time. The trade-off from collapsing the data is that we lose
##'   some accuracy in our estimated parameters. Testing suggests that this loss
##'   in accuracy tends to be relatively minor, with results equivalent to the
##'   1st or 2nd significant decimal place (or even better). By combining these
##'   two strategies, users can very quickly see how bad the loss in accuracy is
##'   on the main marginal effects, before deciding whether to estimate with the
##'   collapsed dataset to get approximate standard errors.
##'   
##'   Summarizing, if you are worried about the estimation time for a large
##'   dataset, try the following three-step approach:
##'   
##'   1. Run `emfx(..., vcov = FALSE)`.
##'   
##'   2. Run `emfx(..., vcov = FALSE, collapse = TRUE)`.
##'   
##'   3. Compare the results from steps 1 and 2. If the main parameter estimates
##'   are similar enough, then as your final model run the following to also 
##'   obtain approximate standard errors: `emfx(..., collapse = TRUE)`.
##' @return A `slopes` object from the `marginaleffects` package.
##' @seealso [marginaleffects::slopes()]
##' @inherit etwfe return examples
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
  if (isTRUE(by_xvar) || by_xvar=="auto") {
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

