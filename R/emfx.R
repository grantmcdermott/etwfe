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
##' @param collapse_data Logical. Collapses data before calculating marginal
##' effects. Is faster, but requires `ivar = NULL` in `etwfe` (Default is "auto",
##' which collapses if the data set has more than 10'000 rows).
##' @param ... Additional arguments passed to [`marginaleffects::marginaleffects`]. 
##' A potentially useful case is testing whether heterogeneous treatment effects
##' (from any `xvar` covariate) are equal by invoking the `hypothesis` argument,
##' e.g. `hypothesis = "adult = child"`. 
##' @return A marginaleffects object.
##' @seealso [marginaleffects::marginaleffects()]
##' @inherit etwfe return examples
##' @importFrom data.table .N .SD
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    xvar = NULL,
    post_only = TRUE,
    collapse_data = "auto",
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
  if (!collapse_data %in% c("auto", TRUE, FALSE)) stop("\"collapse_data\" has to be \"auto\", TRUE, or FALSE.")
  
  dat = data.table::as.data.table(eval(object$call$data, object$call_env))
  
  # check collapse_data argument
  if (collapse_data == "auto") {
    nrows = nrow(dat)

    if (nrows >= 1e5) {
      collapse_data = TRUE
    } else {
      collapse_data = FALSE
    }
  }
  
  if (type=="event" & !post_only) {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE]
  } else {
    if (".Dtreat" %in% names(dat)) dat = dat[dat[[".Dtreat"]], , drop = FALSE]
  }
  
  # define formulas and calculate weights
  if(collapse_data == T & is.null(ivar)){
    if(!is.null(xvar)){
      dat_weights = dat[.Dtreat == T][, .N, by = c(gvar, tvar, xvar)]
  
    } else {
      dat_weights = dat[.Dtreat == T][, .N, by = c(gvar, tvar)]
    }
    
    # collapse the data
    dat = dat[.Dtreat == T][, lapply(.SD, mean), by = c(gvar, tvar, xvar, ".Dtreat")] # collapse data
    dat = data.table::setDT(dat)[, merge(.SD, dat_weights, all.x = T)] # add weights
    
  } else if (collapse_data == T & !is.null(ivar)) {
    warning("\"ivar\" is not NULL. Marginal effects are calculated without collapsing.")
    dat$N = 1
    
  } else {
    dat$N = 1
  }
  
  # collapse the data 
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

