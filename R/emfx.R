##' Post-estimation treatment effects for an ETWFE regressions.
##'
##' @param object An `etwfe` model object.
##' @param type Character. The desired type of post-estimation aggregation.
##' @param summary Logical. Should the resulting marginaleffects objects be passed to [`summary`] before being returned? Defaults to TRUE, but mostly for aesthetics reasons.
##' @param ... Additional arguments passed to 
##' [`marginaleffects::marginaleffects`].
##' @return A marginaleffects object.
##' @seealso [marginaleffects::marginaleffects()]
##' @inherit etwfe return examples
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    summary = TRUE,
    ...
) {
  
  .Dtreat = NULL
  type = match.arg(type)
  gvar = attributes(object)[["etwfe"]][["gvar"]]
  tvar = attributes(object)[["etwfe"]][["tvar"]]
  
  dat = eval(object$call$data, object$call_env)
  if (".Dtreat" %in% names(dat)) dat = subset(dat, .Dtreat==TRUE)
  
  if (type=="simple") by_var = ".Dtreat"
  if (type=="group") by_var = gvar
  if (type=="calendar") by_var = tvar
  if (type=="event") {
    dat = within(
      dat,
      event <-
        eval(as.name(tvar)) -
        eval(as.name(gvar))
    )
    by_var = "event"
  }
  
  mfx = marginaleffects::marginaleffects(
    object, 
    newdata = dat,
    variables = ".Dtreat",
    by = by_var
  )
  
  if (type!="simple") mfx = mfx[order(mfx[[by_var]]), ]
  
  if (summary) mfx = summary(mfx)
  
  return(mfx)
}
