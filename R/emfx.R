##' Post-estimation treatment effects for an ETWFE regressions.
##'
##' @param object An `etwfe` model object.
##' @param type Character. The desired type of post-estimation aggregation.
##' @param ... Additional arguments passed to 
##' [`marginaleffects::marginaleffects`].
##' @return A marginaleffects object.
##' @seealso [marginaleffects::marginaleffects()]
##' @inherit etwfe return examples
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    ...
) {
  
  .Dtreat = NULL
  type = match.arg(type)
  gvar = attributes(object)[["etwfe"]][["gvar"]]
  tvar = attributes(object)[["etwfe"]][["tvar"]]
  
  dat = eval(object$call$data, object$call_env)
  if (".Dtreat" %in% names(dat)) dat = dat[dat[[".Dtreat"]]==1L, , drop = FALSE]
  
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
    variables = ".Dtreat",
    by = by_var
  )
  
  if (type!="simple") mfx = mfx[order(mfx[[by_var]]), ]
   
  return(mfx)
}
