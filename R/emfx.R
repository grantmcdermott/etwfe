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
##' @param ... Additional arguments passed to [`marginaleffects::marginaleffects`]. 
##' A potentially useful case is testing whether heterogeneous treatment effects
##' (from any `xvar` covariate) are equal by invoking the `hypothesis` argument,
##' e.g. `hypothesis = "adult = child"`. 
##' @return A marginaleffects object.
##' @seealso [marginaleffects::marginaleffects()]
##' @inherit etwfe return examples
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    xvar = NULL,
    post_only = TRUE,
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
  gref = attributes(object)[["etwfe"]][["gref"]]
  tref = attributes(object)[["etwfe"]][["tref"]]
  if(!is.null(xvar)) xvar = attributes(object)[["etwfe"]][["xvar"]]
  
  dat = as.data.table(eval(object$call$data, object$call_env))
  #dat = eval(object$call$data, object$call_env) # base version

  if (type=="event" & !post_only) {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE]
  } else {
    if (".Dtreat" %in% names(dat)) dat = dat[dat[[".Dtreat"]], , drop = FALSE]
  }
  
  # define formulas and calculate weights
  if(!is.null(xvar)){
    # form_count = stats::as.formula(paste(".", " ~", gvar, "+", tvar, "+", xvar)) # base
    # form_data  = stats::as.formula(paste(".", " ~", gvar, "+", tvar, "+", xvar, "+ .Dtreat")) # base
    # dat_weights = aggregate(form_count, data = subset(dat, .Dtreat == 1), FUN = length)[c(gvar, tvar, xvar, ".Dtreat")] # base
    # names(dat_weights)[names(dat_weights) == ".Dtreat"] = "N"
    dat_weights = dat[.Dtreat == T][, .N, by = c(gvar, tvar, xvar)]

  } else {
    # form_count = stats::as.formula(paste(".", " ~", gvar, "+", tvar)) # base
    # form_data  = stats::as.formula(paste(".", " ~", gvar, "+", tvar, "+ .Dtreat")) # base
    # dat_weights = aggregate(form_count, data = subset(dat, .Dtreat == 1), FUN = length)[c(gvar, tvar, ".Dtreat")] # base
    # names(dat_weights)[names(dat_weights) == ".Dtreat"] = "N"
    dat_weights = dat[.Dtreat == T][, .N, by = c(gvar, tvar)]
  }
  
  # collapse the data 
  # dat = aggregate(form_data, data = subset(dat, .Dtreat == 1), FUN = mean, na.rm = TRUE) # collapse data (base)
  # dat = merge(dat, dat_weights, all.x = T) # add weights (base)
  dat = dat[.Dtreat == T][, lapply(.SD, mean), by = c(gvar, tvar, xvar, ".Dtreat")] # collapse data
  dat = data.table::setDT(dat)[, merge(.SD, dat_weights, all.x = T)] # add weights
    
  if (type=="simple") by_var = ".Dtreat"
  if (type=="group") by_var = gvar
  if (type=="calendar") by_var = tvar
  if (type=="event") {
    dat[["event"]] = dat[[tvar]] - dat[[gvar]]
    by_var = "event"
  }
  
  mfx = marginaleffects::marginaleffects(
    object,
    newdata = dat,   
    wts = "N",
    variables = ".Dtreat",
    by = c(by_var, xvar),
    ...
  )
    
  if (type!="simple") mfx = mfx[order(mfx[[by_var]]),]
   
  return(mfx)
}

