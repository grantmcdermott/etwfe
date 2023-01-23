##' Post-estimation treatment effects for an ETWFE regressions.
##'
##' @param object An `etwfe` model object.
##' @param type Character. The desired type of post-estimation aggregation.
##' @param post_only Logical. Only keep post-treatment effects. All
##'   pre-treatment effects will be zero as a mechanical result of ETWFE's 
##'   estimation setup, so the default is to drop these nuisance rows from
##'   the dataset. But you may want to keep them for presentation reasons
##'   (e.g., plotting an event-study); though be warned that this is 
##'   strictly performative. This argument will only be evaluated if
##'   `type = "event"`.
##' @param xvar Interacted Covariate. Calculates the marginal effect separately
##' for every value of `xvar` (default is NULL).
##' @param hypothesis Testing. This can be any test regarding the
##' marginal effects. For example, 
##' one can test whether b1 = b2 if `xvar` is binary.
##' @param ... Additional arguments passed to 
##' [`marginaleffects::marginaleffects`].
##' @return A marginaleffects object.
##' @seealso [marginaleffects::marginaleffects()]
##' @inherit etwfe return examples
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    post_only = TRUE,
    xvar = NULL,
    hypothesis = NULL,
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
  
  dat = eval(object$call$data, object$call_env)
  if (type=="event" & !post_only) {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE]
  } else {
    if (".Dtreat" %in% names(dat)) dat = dat[dat[[".Dtreat"]], , drop = FALSE]
  }

  if (type=="simple") by_var = ".Dtreat"
  if (type=="group") by_var = gvar
  if (type=="calendar") by_var = tvar
  if (type=="event") {
    dat[["event"]] = dat[[tvar]] - dat[[gvar]]
    by_var = "event"
  }
  
  if(!is.null(xvar)) by_var = c(by_var, xvar)
  
  mfx = marginaleffects::marginaleffects(
    object,
    newdata = dat,
    hypothesis = hypothesis,    
    variables = ".Dtreat",
    by = by_var
  )
  
  if (type!="simple") mfx = mfx[order(mfx[[by_var[1]]]), ]
   
  return(mfx)
}
