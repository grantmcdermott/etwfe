#' Plot method for emfx objects
#'
#' @md
#' @description Visualize the results of an [`emfx`] call.
#' 
#' @param x An `emfx` object.
#' @param type Character. The type of plot display. One of `"pointrange"`
#'   (default), `"errorbar"`, or `"ribbon"`.
#' @param pch Integer or character. Which plotting character or symbol to use
#'   (see \code{\link[graphics]{points}}). Defaults to 16 (i.e., small solid
#'   circle). Ignored if `type = "ribbon"`.
#' @param zero Logical. Should 0-zero line be emphasized? Default is `TRUE`.
#' @param ref Integer. Reference line marker for event-study plot. Default is
#'   `-1` (i.e., the period immediately preceding treatment). To remove
#'   completely, set to `NA`, `NULL`, or `FALSE`. Only used if the
#'   underlying object was computed using `emfx(..., type = "event")`.
#' @param grid Logical. Should a background grid be displayed? Default is
#'   `TRUE`.
#' @param ... Additional arguments passed to [`tinyplot::tinyplot`].
#' @inherit tinyplot::tinyplot return
#' @importFrom graphics abline par plot
#' @importFrom utils modifyList
#' @importFrom tinyplot tinyplot
#' @inherit etwfe examples
#' @export
plot.emfx = function(
    x,
    type = c("pointrange", "errorbar", "ribbon"),
    pch = 16,
    zero = TRUE,
    grid = TRUE,
    ref = -1,
    ...) {
  dots = list(...)
  etwfe_attr = attr(x, "etwfe")
  type = match.arg(type)
  if (type=="ribbon" && etwfe_attr[["type"]]=="simple") {
    warning('\nRibbon plots are not allowed for `emfx(..., type = "simple")` objects. Reverting to pointrange.\n')
    type = "pointrange"
  }
  byvar = attr(x, "by")
  xvar = etwfe_attr[["xvar"]]
  if (is.null(xvar)) {
    fml = reformulate(byvar, response = "estimate")
  } else {
    byvar = setdiff(byvar, xvar)
    fml = reformulate(paste(byvar, "|", xvar), response = "estimate")
  }
  
  if (isTRUE(zero)) {
    if (is.null(dots[["ylim"]])) {
      dots$ylim = range(c(x$conf.low, x$conf.high, x$estimate, 0), na.rm = TRUE)
    }
  }
  ref_flag = byvar=="event" && !is.null(ref) && !(is.na(ref) || isFALSE(ref))
  if (ref_flag) {
    dots$xlim = range(c(x$event, ref), na.rm = TRUE)
  }
  # catch for ribbon plots
  if (byvar=="event" && type=="ribbon") {
    idx = which(x$event == -1)
    x$conf.low[idx] = x$conf.high[idx] = x$estimate[idx]
  }
  xlab = ylab = main = NULL
  # ensure nice x axis ticks
  if (etwfe_attr[["type"]]=="simple") {
    x[[byvar]] = TRUE
    x[[byvar]] = as.factor(x[[byvar]])
    xlab = "Treated?"
  } else {
    olab = par("lab")
    nxticks = if (!is.null(dots$xlim)) diff(range(dots$xlim)) else diff(range(x[[byvar]]))
    if (nxticks < olab[1]) {
      olab[1] = nxticks
      op = par(lab = olab)
      on.exit(par(op), add = TRUE)
    }
  }
  # dodge CIs if heterogenous groups
  if (!is.null(xvar) && type!="ribbon") {
    uxvar = unique(x[[xvar]])
    xbmp = scale(seq_along(uxvar), scale = FALSE)[, 1] / 10 * 1.5
    # edge case
    if (etwfe_attr[["type"]]=="simple") {
      x[[byvar]] = as.numeric(x[[byvar]])
      xlab = "Treated? (1 == TRUE)"
      olab = par("lab")
      olab[1] = 1
      op = par(lab = olab)
      on.exit(par(op), add = TRUE)
      dots$xlim = c(0.5, 1.5)
    }
    for (ux in seq_along(uxvar)) {
      idx = x[[xvar]]==uxvar[ux] 
      x[[byvar]][idx] = x[[byvar]][idx] + xbmp[ux] 
    }
  }
  if (byvar=="event") xlab = "Time since treatment"
  main = paste("Effect on", etwfe_attr[["yvar"]])
  pargs = list(
    x = fml,
    data = x,
    ymin = x$conf.low,
    ymax = x$conf.high,
    type = type,
    pch = pch,
    grid = grid,
    xlab = xlab,
    ylab = "ATT",
    main = main
  )
  pargs = modifyList(pargs, dots)
  do.call(tinyplot, pargs)
  if (isTRUE(zero)) abline(h = 0, lty = 2, col = "grey50")
  if (ref_flag) abline(v = ref, lty = 2, col = "grey50")
}
