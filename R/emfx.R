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
#' before calculating marginal effects? This legacy argument was originally
#' intended as a shortcut to reduce estimation times for large datasets.
#' However, it is largely irrelevant as of **etwfe** v0.7.0, which introduced
#' fast analytic standard errors (see the "Standard errors" section below). The
#' default `"auto"` is retained for backwards compatibility and is equivalent
#' to `FALSE`. Note that switching to `TRUE` also means losing the default
#' unconditional standard errors, since these are not supported with data
#' compression.
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
#' @param wlevels Only relevant for non-binary treatments, i.e. if the
#'   preceding `etwfe` call included a `wvar` argument. Controls the treatment
#'   level(s) at which effects are evaluated:
#'
#'   - NULL (default): Equivalent to `"slope"`, except for event studies with
#'     the `"never"` treated control group, where it is equivalent to
#'     `"observed"` (since the pre-treatment estimates are level differences).
#'   - `"slope"`: Average marginal effect of a one-unit change in `wvar`.
#'   - `"observed"`: Average effect of each unit's observed treatment level,
#'     relative to no treatment (`wvar = 0`). This also reflects how treatment
#'     levels evolve over time, and is the closest analogue to a binary ATT.
#'   - Numeric vector: Effects of setting the treatment level to each of the
#'     supplied values, relative to no treatment, e.g. `wlevels = c(1, 2, 5)`.
#'     Results are reported (and plotted) separately for each treatment level.
#'   - Function: As above, but with treatment levels computed by applying the
#'     function to the treated observations' `wvar` values, e.g.
#'     `wlevels = fivenum` or `wlevels = \(x) quantile(x, c(0.25, 0.5, 0.75))`.
#'
#'   These options mirror the ergonomics of
#'   \code{\link[marginaleffects]{datagrid}}, which similarly accepts values or
#'   functions (e.g., `datagrid(x = fivenum)`). Note that effects at fixed
#'   treatment levels are linear in `wvar` by construction, and that levels far
#'   from the bulk of the data (e.g., the minimum and maximum in `fivenum`) are
#'   extrapolations.
#'
#'   For event studies with the `"never"` treated control group, the
#'   pre-treatment estimates do not depend on `wvar`, and are reported only once
#'   (with a missing `wvar` value, and as a "Pre" group in plots).
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
#' @param lean Logical. Default is `FALSE`. Switching to `TRUE` enforces a lean
#'   return object; namely a simple data.frame of the main results, stripped of
#'   ancillary attributes. Note that this will disable some advanced
#'   `marginaleffects` post-processing features, but those are unlikely to be
#'   used in the `emfx` context. The upside is a potentially dramatic reduction
#'   in the size of the return object. Consequently, we may change the default
#'   to `TRUE` in a future version of **etwfe**.
#' @param window Numeric of length 1 or 2. Limits the temporal window of
#'   consideration around treatment.
#'
#'   - NULL (default): Include all available periods.
#'   - Length 1: Truncate to a symmetric window around the treatment event.
#'     E.g., `window = 2` will truncate to two pre-treatment periods and two
#'     post-treatment periods.
#'   - Length 2: Asymmetric window, where the first number gives the maximum
#'     number of pre-treatment periods and the second number gives the maximum
#'     number of post-treatment periods. E.g., `window = c(5, 2)` will truncate
#'     to five pre-treatment periods and two post-treatment periods.
#'
#' Note that the pre-treatment truncation is only ever binding in cases where
#' the "never" treated group is used as a control, i.e.,
#' `etwfe(..., cgroup = "never")` in the original call.
#' @param ... Additional arguments passed to
#'   [`marginaleffects::slopes`]. For example, you can pass `vcov = FALSE`
#'   to skip standard errors entirely, or your own `vcov` argument (see the
#'   "Standard errors" section below). Another potentially useful
#'   application is testing whether heterogeneous treatment effects (i.e., the
#'   levels of any `xvar` covariate) are equal by invoking the `hypothesis`
#'   argument, e.g. `hypothesis = "b1 = b2"`.
#' @section Standard errors:
#' As of **etwfe** v0.7.0, `emfx` computes its standard errors using a fast and
#' exact analytic path, which yields both greater performance and precision
#' than the old numeric approach (which was based on the delta method).
#'
#' Moreover, we now also report "unconditional" standard errors by default,
#' which account for sampling variation in the covariate distribution over
#' which the treatment effects are averaged (see:
#' [`marginaleffects::vcovUnconditional`]). Any one-way clustering in the
#' original `etwfe` model (e.g., `vcov = ~countyreal`) is carried over
#' automatically.
#'
#' Exceptions to this rule, where `emfx` instead falls back to the model's own
#' (conditional) variance-covariance matrix, are as follows:
#'
#' - Compressed data (`compress = TRUE`), since the compressed groups no longer
#'   map to the original observations. (Explicitly requesting unconditional
#'   standard errors for compressed data, e.g. `vcov = "unconditional"`, is an
#'   error.)
#' - Multiway or interacted clustering (e.g., `vcov = ~countyreal + year`),
#'   which `vcovUnconditional` does not support.
#'
#' A warning is triggered in both cases.
#'
#' Users can override the default by passing their own `vcov` argument, e.g.
#' `vcov = TRUE` to recover the model's conditional standard errors (the
#' default behaviour prior to **etwfe** v0.7.0), or
#' `vcov = marginaleffects::vcovUnconditional(type = "HC1", cluster = ~id)` for
#' finer control.
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
#' @inheritSection etwfe Performance
#' @inheritSection etwfe Heterogeneous treatment effects
#' @importFrom data.table as.data.table setDT .N .SD
#' @importFrom marginaleffects comparisons slopes vcovUnconditional
#' @importFrom stats reformulate setNames
#' @importFrom fixest obs
#' @importFrom utils modifyList
#' @export
emfx = function(
  object,
  type = c("simple", "group", "calendar", "event"),
  by_xvar = "auto",
  compress = "auto",
  collapse = compress,
  predict = c("response", "link"),
  wlevels = NULL,
  post_only = TRUE,
  window = NULL,
  lean = FALSE,
  ...
) {
  dots = list(...)

  .Dtreat = NULL
  type = match.arg(type)
  predict = match.arg(predict)
  etwfe_attr = attr(object, "etwfe")
  etwfe_attr[["type"]] = type
  yvar = etwfe_attr[["yvar"]]
  ctrls = etwfe_attr[["ctrls"]]
  gvar = etwfe_attr[["gvar"]]
  tvar = etwfe_attr[["tvar"]]
  ivar = etwfe_attr[["ivar"]]
  xvar = etwfe_attr[["xvar"]]
  gref = etwfe_attr[["gref"]]
  tref = etwfe_attr[["tref"]]
  cgroup = etwfe_attr[["cgroup"]]
  fe = etwfe_attr[["fe"]]
  wvar = etwfe_attr[["wvar"]]
  if (!by_xvar %in% c("auto", TRUE, FALSE)) {
    stop("\"by_xvar\" has to be \"auto\", TRUE, or FALSE.")
  }
  if (!collapse %in% c("auto", TRUE, FALSE)) {
    stop("\"collapse\" has to be \"auto\", TRUE, or FALSE.")
  }

  # sanity check
  if (isTRUE(by_xvar)) {
    if (is.null(xvar)) {
      warning(
        "An \"xvar\" attribute was not found as part of the supplied model object. ",
        "(Did your original `etwfe()` call include a valid `xvar = ...` argument?)",
        "Average margins are reported instead."
      )
      by_xvar = FALSE
    }
  }

  if (by_xvar == "auto") {
    by_xvar = !is.null(xvar)
  }

  if (!is.null(wlevels) && is.null(wvar)) {
    warning("`wlevels` is only used for non-binary treatments (`etwfe(..., wvar = ...)`). Ignoring.")
    wlevels = NULL
  }
  never_event = !is.null(wvar) && cgroup == "never" && type == "event"
  if (!is.null(wvar)) {
    wlevels_default = is.null(wlevels)
    if (wlevels_default) {
      wlevels = if (never_event) "observed" else "slope"
    }
    if (!(is.numeric(wlevels) || is.function(wlevels) ||
      (is.character(wlevels) && length(wlevels) == 1 && wlevels %in% c("slope", "observed")))) {
      stop("`wlevels` must be \"slope\", \"observed\", a numeric vector, or a function.")
    }
    if (isTRUE(by_xvar) && (is.numeric(wlevels) || is.function(wlevels))) {
      stop("Fixed `wlevels` cannot currently be combined with heterogeneous effects by `xvar`. Use `by_xvar = FALSE`.")
    }
    if (isTRUE(compress) || isTRUE(collapse)) {
      stop("`compress = TRUE` is not supported for non-binary treatments (`wvar`).")
    }
    if (never_event && !is.null(dots$hypothesis)) {
      stop(
        "`hypothesis` is not supported for event studies with non-binary ",
        "treatments and `cgroup = \"never\"`, since the pre- and ",
        "post-treatment estimates are computed separately."
      )
    }
  }

  if (isTRUE(object$lean)) {
    stop(
      "`emfx()` does not support models estimated with `lean = TRUE`, since ",
      "these don't retain the information needed to recover the estimation ",
      "sample. Please re-estimate the model without `lean = TRUE`."
    )
  }

  # restrict to the estimation sample, i.e. drop any rows that feols() removed
  # (missing values, etc.) (#91)
  dat = as.data.table(eval(object$call$data, object$call_env))[obs(object)]
  if ("group" %in% names(dat)) {
    dat[["group"]] = NULL
  }

  # check compress argument ("auto" is kept for backwards compatibility, but
  # analytic Jacobians make compression unnecessary, so it means FALSE)
  if (compress == "auto" && collapse != compress) {
    compress = collapse
    message(
      "\nPlease note that the `collapse` argument has been superseded by `compress`. ",
      "Both arguments have the identical effect, but we encourage users to use `compress` going forward.\n"
    )
  }
  if (compress == "auto") {
    compress = FALSE
  }

  if (cgroup == "never") {
    dat = dat[
      dat[[gvar]] != gref,
      ,
      drop = FALSE,
      env = list(gvar = I(gvar), gref = gref)
    ] # Drop never treated reference group
    if (type != "event") {
      # For non-event studies, we want to calculated ATTs for post-treatment
      # only. Rather than dropping the other rows, we give them zero weight
      # (below), since subsetting would drop columns from the model matrix and
      # thus force marginaleffects onto a (much slower) numerical Jacobian
      post = dat[[".Dtreat"]] & dat[[tvar]] >= dat[[gvar]]
      if (isTRUE(compress) || !is.null(dots$hypothesis)) {
        dat = dat[post, , drop = FALSE]
      } else {
        dat[[".post"]] = post
      }
    }
  } else if (type == "event" & isFALSE(post_only)) {
    dat = dat[
      dat[[gvar]] != gref,
      ,
      drop = FALSE,
      env = list(gvar = I(gvar), gref = gref)
    ]
  } else if (".Dtreat" %in% names(dat)) {
    dat = dat[dat[[".Dtreat"]], , drop = FALSE]
  }

  if (!is.null(window)) {
    if (length(window) == 1) {
      dat = dat[
        dat[[tvar]] >= (dat[[gvar]] - window) &
          dat[[tvar]] <= (dat[[gvar]] + window),
        ,
        drop = FALSE,
        env = list(tvar = I(tvar), gvar = I(gvar))
      ]
    } else if (length(window) == 2) {
      dat = dat[
        dat[[tvar]] >= (dat[[gvar]] - window[1]) &
          dat[[tvar]] <= (dat[[gvar]] + window[2]),
        ,
        drop = FALSE,
        env = list(tvar = I(tvar), gvar = I(gvar))
      ]
    } else {
      stop("Invalid `window` argument. Must be of length 1 or 2.")
    }
  }

  # catch for non-linear models
  if (!is.null(dots)) {
    if (
      !is.null(object$family) &&
        object$family$family != "gaussian" &&
        fe != "none"
    ) {
      if (is.null(dots$vcov) || !isFALSE(dots$vcov)) {
        dots$vcov = FALSE
        warning(
          'Cannot estimate standard errors for non-Gaussian model families in the presence of fixed effects.\n',
          'To calculate standard errors, re-estimate the original model with `etwfe(..., fe = "none")`.\n'
        )
      }
    }
  }

  # define formulas and calculate weights
  if (compress & is.null(ivar)) {
    if (by_xvar) {
      dat_weights = dat[(.Dtreat)][, .N, by = c(gvar, tvar, xvar)]
    } else {
      dat_weights = dat[(.Dtreat)][, .N, by = c(gvar, tvar)]
    }

    if (is.null(dots$vcov)) {
      warning(
        "Unconditional standard errors are not available for compressed ",
        "data; using the model's variance-covariance matrix instead. ",
        "Use `vcov = TRUE` to silence this warning."
      )
    }

    # id factor / character columns for dropping, since we can't compute means
    # on these (https://github.com/Rdatatable/data.table/issues/7261)
    scols = sapply(dat, function(x) is.factor(x) || is.character(x))
    scols[c(gvar, tvar, xvar, ".Dtreat")] = TRUE
    # compress the data
    dat = dat[(.Dtreat)][,
      lapply(.SD, mean),
      by = c(gvar, tvar, xvar, ".Dtreat"),
      .SDcols = !scols
    ]
    dat = setDT(dat)[, merge(.SD, dat_weights, all.x = TRUE)] # add weights
  } else if (compress & !is.null(ivar)) {
    warning(
      "\"ivar\" is not NULL. Marginal effects are calculated without collapsing."
    )
    dat$N = 1L
  } else {
    dat$N = 1L
  }

  # compress the data
  if (type == "simple") {
    by_var = ".Dtreat"
  } else if (type == "group") {
    by_var = gvar
  } else if (type == "calendar") {
    by_var = tvar
  } else if (type == "event") {
    dat[["event"]] = dat[[tvar]] - dat[[gvar]]
    by_var = "event"
  }

  if (by_xvar) {
    by_var = c(by_var, xvar)
  }

  # zero-weight non-post-treatment rows (see above). Groups without any
  # post-treatment rows (e.g., calendar periods before the first treatment) get
  # placeholder weights instead, and are dropped after estimation
  bykey = function(x) do.call(paste, c(lapply(by_var, function(v) x[[v]]), sep = "\r"))
  empty_keys = NULL
  if (".post" %in% names(dat)) {
    dat$N = as.integer(dat[[".post"]])
    keys = bykey(dat)
    empty_keys = setdiff(unique(keys), unique(keys[dat$N > 0]))
    data.table::set(dat, which(keys %in% empty_keys), "N", 1L)
  }

  # unconditional standard errors (default): inherit the model's one-way
  # cluster variable, since marginaleffects::vcovUnconditional() can't
  if (is.null(dots$vcov) && !(compress && is.null(ivar))) {
    dots$vcov = "unconditional"
  }
  if (
    compress &&
      is.null(ivar) &&
      (identical(dots$vcov, "unconditional") ||
        identical(dots$vcov, marginaleffects::vcovUnconditional) ||
        inherits(dots$vcov, "marginaleffects_vcov_unconditional"))
  ) {
    stop(
      "Unconditional standard errors are not available for compressed data. ",
      "Use `compress = FALSE` (the default), or `vcov = TRUE` for the model's ",
      "conditional standard errors."
    )
  }
  if (
    identical(dots$vcov, "unconditional") ||
      identical(dots$vcov, vcovUnconditional)
  ) {
    dots$vcov = vcov_unconditional(object)
  }

  if (isTRUE(lean)) {
    old_lean = getOption("marginaleffects_lean", default = FALSE)
    options(marginaleffects_lean = TRUE)
    on.exit(options(marginaleffects_lean = old_lean))
  }

  ## Note: Rather use do.call so can pass adjusted dots if vcov is overriden.
  # mfx = slopes(
  #   object,
  #   newdata = dat,
  #   wts = "N",
  #   variables = ".Dtreat",
  #   by = by_var,
  #   type = predict,
  #   ...
  # )
  # etwfe doesn't override fixest prediction, so pass a plain fixest object;
  # marginaleffects only uses analytic Jacobians for exact (non-sub)classes
  model = object
  class(model) = setdiff(class(model), "etwfe")
  args_list = list(
    model = model,
    newdata = dat,
    wts = "N",
    variables = if (is.null(wvar)) ".Dtreat" else wvar,
    by = by_var,
    type = predict
  )
  if (!is.null(dots)) {
    args_list = modifyList(args_list, dots)
  }
  # never-treated event studies: pre-treatment cells are binary contrasts on
  # .Dpre, computed separately from the post-treatment effects. Both use all
  # rows (keeping the full model matrix, and thus the fast analytic Jacobian),
  # and we keep the relevant (disjoint) event groups afterwards.
  if (never_event) {
    pre_args = args_list
    pre_args[["variables"]] = ".Dpre"
  }

  # effects at treatment levels: contrast observed (or fixed) wvar against zero.
  # Fixed levels stack one copy of the data per level, grouped by wvar. Binary
  # wvar levels coincide with slopes (and marginaleffects needs 0/1 contrasts).
  mfx_fun = "slopes"
  if (!is.null(wvar) && !identical(wlevels, "slope") && all(dat[[wvar]] %in% c(0, 1))) {
    if (!identical(wlevels, "observed")) {
      warning("`wvar` is binary, so effects at fixed `wlevels` are just slopes. Ignoring `wlevels`.")
    }
    wlevels = "slope"
  }
  if (never_event && wlevels_default && identical(wlevels, "observed")) {
    message(
      "Pre-treatment estimates are level differences, so post-treatment ",
      "effects are reported at the observed treatment level for comparability. ",
      "Use `wlevels = \"slope\"` for per-unit slopes instead."
    )
  }
  # slopes: since the model is linear in wvar, a +1 contrast is exactly the
  # slope, and comparisons() is much faster than slopes() for unconditional SEs
  if (!is.null(wvar) && identical(wlevels, "slope") && !all(dat[[wvar]] %in% c(0, 1))) {
    mfx_fun = "comparisons"
    args_list[["variables"]] = setNames(list(1), wvar)
  }
  if (!is.null(wvar) && !identical(wlevels, "slope")) {
    mfx_fun = "comparisons"
    args_list[["variables"]] = setNames(
      list(function(x) data.frame(lo = 0 * x, hi = x)),
      wvar
    )
    if (!identical(wlevels, "observed")) {
      nd = args_list[["newdata"]]
      if (is.function(wlevels)) {
        wlevels = wlevels(nd[[wvar]][nd[[tvar]] >= nd[[gvar]]])
        if (!is.numeric(wlevels)) {
          stop("A `wlevels` function must return a numeric vector.")
        }
      }
      wlevels = sort(unique(unname(wlevels)))
      args_list[["newdata"]] = do.call(
        rbind,
        lapply(wlevels, function(w) {
          d = as.data.frame(nd)
          d[[wvar]] = w
          d
        })
      )
      args_list[["by"]] = c(by_var, wvar)
    }
  }
  etwfe_attr[["wlevels"]] = wlevels
  mfx = do.call(mfx_fun, args = args_list)

  # stack pre- (once, i.e. not per treatment level) and post-treatment estimates,
  # keeping the post-treatment object's attributes
  if (never_event) {
    pre = as.data.frame(do.call("slopes", args = pre_args))
    pre = pre[pre[["event"]] < 0, , drop = FALSE]
    if (is.numeric(wlevels)) pre[[wvar]] = NA_real_
    post = as.data.frame(mfx)
    post = post[post[["event"]] >= 0, names(pre), drop = FALSE]
    out = rbind(pre, post)
    rownames(out) = NULL
    keep = setdiff(names(attributes(mfx)), c("names", "row.names"))
    attributes(out)[keep] = attributes(mfx)[keep]
    mfx = out
  }

  # drop any placeholder groups that contain no post-treatment rows
  if (length(empty_keys)) {
    keep = !bykey(as.data.frame(mfx)) %in% empty_keys
    if (!all(keep)) {
      out = as.data.frame(mfx)[keep, , drop = FALSE]
      rownames(out) = NULL
      ka = setdiff(names(attributes(mfx)), c("names", "row.names"))
      attributes(out)[ka] = attributes(mfx)[ka]
      mfx = out
    }
  }

  class(mfx) = c("emfx", class(mfx))
  attr(mfx, "etwfe") = etwfe_attr

  return(mfx)
}

## Build a vcovUnconditional() request that matches the model's clustering.
## Falls back to the model's own vcov (NULL) for multiway or non-bare clusters,
## which vcovUnconditional() doesn't support.
vcov_unconditional = function(object) {
  vtype = attr(object$cov.scaled, "vcov_type")
  if (is.null(vtype) || !grepl("^Clustered \\(", vtype)) {
    return(vcovUnconditional())
  }
  cl = sub("^Clustered \\((.*)\\)$", "\\1", vtype)
  if (cl != make.names(cl)) {
    warning(
      "Unconditional standard errors only support one-way clustering by a ",
      "single variable, but the model is \"",
      vtype,
      "\". ",
      "Falling back to the model's own variance-covariance matrix."
    )
    return(NULL)
  }
  vcovUnconditional(cluster = reformulate(cl))
}
