#' Test for pre-trends
#'
#' @md
#' @description Jointly tests the null hypothesis of parallel (common) trends
#'   prior to treatment, following Wooldridge (2025, Sec. 7). A light wrapper
#'   around [fixest::wald()] that selects the relevant coefficients on your
#'   behalf. The test depends on how the [etwfe] model was estimated:
#'
#'   - `trend = TRUE`: tests that the cohort-specific linear trends are jointly
#'   zero.
#'   - `cgroup = "never"`: tests that the pre-treatment cohort-period effects
#'   (i.e., the "leads" in an event study) are jointly zero.
#'
#'   These are alternative tests of the same null hypothesis, and cannot be
#'   combined in a single model; cohort trends and a full set of pre-treatment
#'   effects are not separately identified. Note that the `cgroup = "never"`
#'   model is equivalent to augmenting the default `"notyet"` model with the
#'   pre-treatment effects, as per Wooldridge's test regression.
#' @details The `cgroup = "never"` test involves roughly one restriction per
#'   pre-treatment period per cohort, which can be a lot. Each cohort's
#'   restrictions are informed mainly by that cohort's own units, so a
#'   cluster-robust test needs many clusters (units) per cohort. With few
#'   clusters per cohort, the cluster-robust vcov can badly underestimate the
#'   variance of some combinations of the pre-treatment effects, leading the
#'   joint test to over-reject (sometimes wildly) even when the individual
#'   estimates look unremarkable. The cohort trends test (one restriction per
#'   cohort) is much less susceptible to this problem.
#' @param x An `etwfe` model object.
#' @param interactions Logical. Should interactions between the tested terms
#'   and any (demeaned) controls or `xvar` covariates also be included in the
#'   joint null? Defaults to `FALSE`, following Wooldridge (2025), who notes
#'   that testing for covariate-dependent violations of parallel trends comes
#'   at a considerable cost in power.
#' @param ... Additional arguments passed to [fixest::wald()], e.g. `print` or
#'   `vcov`.
#' @return The result of [fixest::wald()]: a list containing the test statistic,
#'   p-value, degrees of freedom, and vcov type.
#' @references
#' Wooldridge, Jeffrey M. (2025). \cite{Two-way fixed effects, the two-way
#' Mundlak regression, and difference-in-differences estimators}. Empirical
#' Economics, 69, 2545-2587. Available: https://doi.org/10.1007/s00181-025-02807-z
#' @seealso [fixest::wald()], which performs the underlying test.
#' @examples
#' #
#' # Option 1: cgroup = "notyet" (default) + trend = TRUE
#' #
#'
#' # Tests whether the cohort-specific linear trends are jointly zero. Requires
#' # at least two pre-treatment periods per cohort, so we drop the cohort
#' # treated in year 2.
#' data("base_stagg", package = "fixest")
#' mod_trend = etwfe(
#'   y ~ x1, tvar = year, gvar = year_treated,
#'   data = subset(base_stagg, year_treated != 2), vcov = ~id,
#'   trend = TRUE # <= cohort trends (with default cgroup = "notyet")
#' )
#' pretrends(mod_trend)
#'
#' #
#' # Option 2: cgroup = "never"
#' #
#'
#' # Tests whether the pre-treatment effects (event study leads) are jointly
#' # zero. This involves many more restrictions, so we switch to the bundled
#' # walmart dataset, which has enough units per cohort for a reliable
#' # cluster-robust test.
#' mod_never = etwfe(
#'   log_retail_emp ~ 0, tvar = year, gvar = cohort,
#'   ivar = fips, wvar = n_open,
#'   data = walmart, vcov = ~fips,
#'   cgroup = "never" # <= never-treated control group
#' )
#' pretrends(mod_never)
#' @importFrom stats coef
#' @export
pretrends = function(x, interactions = FALSE, ...) {
  if (!inherits(x, "etwfe")) stop("`x` must be an `etwfe` model object.\n")
  a = attr(x, "etwfe")
  cf = names(coef(x))
  ## Match fixest's coefficient names with fixed strings (no regex), since
  ## gvar/tvar names may contain regex metacharacters
  if (isTRUE(a$trend)) {
    ## i(gvar, tvar): "<gvar>::<g>:<tvar>"
    nms = cf[startsWith(cf, paste0(a$gvar, "::")) & endsWith(cf, paste0(":", a$tvar))]
  } else if (a$cgroup == "never") {
    ## Treatment cells: "<lead>:<gvar>::<g>:<tvar>::<t>[:<nested covariate>]".
    ## Leads are the cells with t < g (each cohort's base period, g - 1, is
    ## already omitted from the model).
    lead = paste0(if (is.null(a$wvar)) ".Dtreat" else ".Dpre", ":", a$gvar, "::")
    cf = cf[startsWith(cf, lead)]
    parts = strsplit(substring(cf, nchar(lead) + 1), paste0(":", a$tvar, "::"), fixed = TRUE)
    g = as.numeric(vapply(parts, `[`, "", 1))
    rest = vapply(parts, `[`, "", 2)
    is_int = grepl(":", rest, fixed = TRUE)
    is_pre = as.numeric(sub(":.*", "", rest)) < g
    nms = cf[is_pre & (!is_int | isTRUE(interactions))]
  } else {
    nms = character(0)
  }
  if (!length(nms)) {
    stop(
      "No pre-trend terms to test. Re-estimate with either `trend = TRUE` ",
      "(cohort-specific linear trends) or `cgroup = \"never\"` ",
      "(pre-treatment effects).\n"
    )
  }
  ## wald() matches by regex, so escape the exact names
  rx = paste0("^", gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", nms), "$")
  fixest::wald(x, keep = rx, ...)
}
