#' Post-estimation aggregation of ETWFE results
#'
#' @md
#' @description
#' Companion function to `etwfe`, enabling the recovery of aggregate treatment
#' effects along different dimensions of interest (e.g, an event study of
#' dynamic average treatment effects). `emfx` is a light wrapper around the
#' \code{\link[marginaleffects]{slopes}} function from the **marginaleffects**
#' package.
#' 
#' @param object An `etwfe` model object.
#' @param type Character. The desired type of post-estimation aggregation.
#' @param by_xvar Logical. Should the results account for heterogeneous
#'   treatment effects? Only relevant if the preceding `etwfe` call included a
#'   specified `xvar` argument, i.e. interacted categorical covariate. The
#'   default behaviour (`"auto"`) is to automatically estimate heterogeneous
#'   treatment effects for each level of `xvar` if these are detected as part
#'   of the underlying `etwfe` model object. Users can override by setting to
#'   either `FALSE` or `TRUE.` See the "Heterogeneous treatment effects"
#'   section below.
#' @param compress Logical. Compress the data by (period by cohort) groups
#'   before calculating marginal effects? This trades off a slight loss in
#'   precision (typically around the 1st or 2nd significant decimal point) for a
#'   substantial improvement in estimation time for large datasets. The default
#'   behaviour (`"auto"`) is to automatically compress if the original dataset
#'   has more than 500,000 rows. Users can override by setting either `FALSE` or
#'   `TRUE`. Note that collapsing by group is only valid if the preceding `etwfe`
#'   call was run with `"ivar = NULL"` (the default). See the "Performance
#'   tips" section below.
#' @param collapse Logical. An alias for `compress` (only used for backwards
#'   compatability and ignored if both arguments are provided). The behaviour is
#'   identical, but it will trigger a message nudging users to rather use the
#'   `compress` argument. 
#' @param predict Character. The type (scale) of prediction used to compute the
#'   marginal effects. If `"response"` (the default), then the output is at the
#'   level of the response variable, i.e. it is the expected predictor
#'   \eqn{E(Y|X)}. If `"link"`, the value returned is the linear predictor of
#'   the fitted model, i.e. \eqn{X\cdot \beta}. The difference should only
#'   matter for nonlinear models. (Note: This argument is typically called
#'   `type` when use in \code{\link[stats]{predict}} or
#'   \code{\link[marginaleffects]{slopes}}, but we rename it here to avoid a
#'   clash with the top-level `type` argument above.)
#' @param post_only Logical. Drop pre-treatment ATTs? Only evaluated if (a)
#'   `type = "event"` and (b) the original `etwfe` model object was estimated
#'   using the default `"notyet"` treated control group. If conditions (a) and
#'   (b) are met then the pre-treatment effects will be zero as a mechanical
#'   result of ETWFE's estimation setup. The default behaviour (`TRUE`) is
#'   thus to drop these nuisance rows from the dataset. The `post_only` argument
#'   recognises that you may still want to keep them for presentation purposes
#'   (e.g., plotting an event study). Nevertheless, be forewarned that enabling
#'   that behaviour via `FALSE` is _strictly_ performative: the "zero" treatment
#'   effects for any pre-treatment periods is purely an artefact of the
#'   estimation setup.
#' @param lean Logical. Enforces a lean return object; namely a simple
#'   data.frame of the main results, stripped of ancillary attributes. Defaults
#'   to `TRUE`, in which case `options(marginaleffects_lean = TRUE)` is set
#'   internally at the start of the `emfx` call, before being reverted upon
#'   exit. Note that this will disable some advanced `marginaleffects`
#'   post-processing features, but those are unlikely to be used in the `emfx`
#'   context and means that we can dramatically reduce the size of the return
#'   object.
#' @param ... Additional arguments passed to
#'   [`marginaleffects::slopes`]. For example, you can pass `vcov =
#'   FALSE` to dramatically speed up estimation times of the main marginal
#'   effects (but at the cost of not getting any information about standard
#'   errors; see Performance tips below). Another potentially useful
#'   application is testing whether heterogeneous treatment effects (i.e., the
#'   levels of any `xvar` covariate) are equal by invoking the `hypothesis`
#'   argument, e.g. `hypothesis = "b1 = b2"`.
#' @return A `data.frame` of aggregated treatment effects along the
#'   dimension(s) of interested. Note that this data.frame will have been
#'   overloaded with the \code{\link[marginaleffects]{slopes}} class, and so
#'   will come with a special print method. But the underlying columns will
#'   usually include:
#'
#'   - `term`
#'   - `contrast`
#'   - `<type>` (i.e., the name of your `type` string)
#'   - `estimate`
#'   - `std.error`
#'   - `statistic`
#'   - `p.value`
#'   - `s.value`
#'   - `conf.low`
#'   - `conf.high`
#' @references 
#' Wong, Jeffrey _et al._ (2021). \cite{You Only Compress Once: Optimal Data
#' Compression for Estimating Linear Models}. Working paper (version: March 16,
#' 2021). Available: 
#' https://doi.org/10.48550/arXiv.2102.11297
#' @seealso [marginaleffects::slopes] which does the heavily lifting behind the
#' scenes. [`etwfe`] is the companion estimating function that should be run
#' before `emfx`.
#' @inherit etwfe examples
#' @inheritSection etwfe Performance tips
#' @inheritSection etwfe Heterogeneous treatment effects
#' @importFrom data.table as.data.table setDT .N .SD
#' @importFrom marginaleffects slopes
#' @export
emfx = function(
    object,
    type = c("simple", "group", "calendar", "event"),
    by_xvar = "auto",
    compress = "auto",
    collapse = compress,
    predict = c("response", "link"),
    post_only = TRUE,
    lean = TRUE,
    ...
) {
  
  dots = list(...)
  
  ## FIXME: uncomment when marginaleffects 0.25.0 is released and remove
  ## workaround at the boom of this function
  ## https://github.com/vincentarelbundock/marginaleffects/pull/1296
  # if (isTRUE(lean)) {
  #   oldlean = getOption("marginaleffects_lean")
  #   options(marginaleffects_lean = TRUE)
  #   on.exit(options(marginaleffects_lean = oldlean))
  # }

  .Dtreat = NULL
  type = match.arg(type)
  predict = match.arg(predict)
  etwfe_attr = attr(object, "etwfe")
  etwfe_attr[["type"]] = type
  gvar = etwfe_attr[["gvar"]]
  tvar = etwfe_attr[["tvar"]]
  ivar = etwfe_attr[["ivar"]]
  xvar = etwfe_attr[["xvar"]]
  gref = etwfe_attr[["gref"]]
  tref = etwfe_attr[["tref"]]
  cgroup = etwfe_attr[["cgroup"]]
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
  
  dat = as.data.table(eval(object$call$data, object$call_env))
  if ("group" %in% names(dat)) dat[["group"]] = NULL
  
  # check compress argument
  nrows = NULL
  if (compress == "auto" && collapse != compress) {
    compress = collapse
    message(
      "\nPlease note that the `collapse` argument has been superseded by `compress`. ",
      "Both arguments have the identical effect, but we encourage users to use `compress` going forward.\n"
    )
  }
  if (compress == "auto") {
    nrows = nrow(dat)

    if (nrows >= 5e5) {
      compress = TRUE
    } else {
      compress = FALSE
    }
  }
  
  if (cgroup == "never") {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE] # Drop never treated reference group
    if (type != "event") {
      # For non-event studies, we want to calculated ATTs for post-treatment only
      dat = dat[dat[[".Dtreat"]], , drop = FALSE]
      dat = dat[dat[[tvar]] >= dat[[gvar]], , drop = FALSE]
    }
  } else if (type=="event" & isFALSE(post_only)) {
    dat = dat[dat[[gvar]] != gref, , drop = FALSE]
  } else if (".Dtreat" %in% names(dat)) {
    dat = dat[dat[[".Dtreat"]], , drop = FALSE]
  }
  
  # define formulas and calculate weights
  if(compress & is.null(ivar)){
    if(by_xvar){
      dat_weights = dat[(.Dtreat)][, .N, by = c(gvar, tvar, xvar)]
    } else {
      dat_weights = dat[(.Dtreat)][, .N, by = c(gvar, tvar)]
    }
    
   if (!is.null(nrows) && nrows > 5e5) warning(
    "\nNote: Dataset larger than 500k rows detected. The data will be ",
    "compressed by period-cohort groups to reduce estimation times. ", 
    "However, this shortcut can reduce the accuracy of the reported ",
    "marginal effects. ",
    "To override this default behaviour, specify: ",
    "`emfx(..., compress = FALSE)`\n"
    ) 
    
    # compress the data
    dat = dat[(.Dtreat)][, lapply(.SD, mean), by = c(gvar, tvar, xvar, ".Dtreat")] # compress data
    dat = setDT(dat)[, merge(.SD, dat_weights, all.x = TRUE)] # add weights
    
    
  } else if (compress & !is.null(ivar)) {
    warning("\"ivar\" is not NULL. Marginal effects are calculated without collapsing.")
    dat$N = 1L
    
  } else {
    dat$N = 1L
  }
  
  # compress the data 
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

  mfx = slopes(
    object,
    newdata = dat,   
    wts = "N",
    variables = ".Dtreat",
    by = by_var,
    type = predict,
    ...
  )
  
  ## FIXME: remove when marginaleffects 0.25.0 is released
  ## https://github.com/vincentarelbundock/marginaleffects/pull/1296
  if (isTRUE(lean)) {
    atts = names(attributes(mfx))
    for (a in setdiff(atts, c("names", "row.names", "class", "by", "conf_level", "lean"))) attr(mfx, a) = NULL
  }
  
  class(mfx) = c("emfx", class(mfx))
  attr(mfx, "etwfe") = etwfe_attr
  
  return(mfx)
}

