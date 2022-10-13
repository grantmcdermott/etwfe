##' Post-estimation treatment effects for an ETWFE regressions.
##'
##' @param object An `etwfe` model object.
##' @param type Character. The desired type of post-estimation aggregation. 
##' @param ... Additional arguments passed to 
##' `marginaleffects::marginaleffects`.
##' @return A marginaleffects object.
##' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    ...
) {
  
  .Dtreat = NULL
  
  type = match.arg(type)
  
  dat = subset(eval(object$call$data, object$call_env), .Dtreat==TRUE)
  
  if (type=="simple") ovar = NULL
  if (type=="group") ovar = attributes(object)[["etwfe"]][["gvar"]]
  if (type=="calendar") ovar = attributes(object)[["etwfe"]][["tvar"]]
  if (type=="event") {
    dat = within(
      dat,
      event <-
        eval(as.name(attributes(object)[["etwfe"]][["tvar"]])) -
        eval(as.name(attributes(object)[["etwfe"]][["gvar"]]))
    )
    ovar = "event"
  }
  
  by_vars = c(".Dtreat", ovar)
  
  mfx = marginaleffects::marginaleffects(
    object, 
    newdata = dat,
    variables = ".Dtreat",
    by = by_vars
  )
  
  if (type!="simple") mfx = mfx[order(mfx[[ovar]]), ]
  
  return(mfx)
}
