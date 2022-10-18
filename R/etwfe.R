##' Extended two-way fixed effects
##'
##' @param fml A formula with the outcome (lhs) and any additional control 
##' variables (rhs), e.g. `y ~ x1`. If no additional controls are required, the 
##' rhs must take the value of zero, e.g. `y ~ 0`.
##' @param ivar Index variable. Can be a string (e.g., "country") or an 
##' expression (e.g., country). Leaving as NULL (the default) will result in
##' group-level fixed effects being used, which is more efficient and necessary 
##' for nonlinear models (see `family` argument below).
##' @param tvar Time variable. Can be a string (e.g., "year") or an expression
##' (e.g., year).
##' @param gvar Group variable. Can be either a string (e.g., "first_treated") 
##' or an expression (e.g., first_treated). In a staggered treatment setting, 
##' the group variable typically denotes treatment cohort.
##' @param data The data frame that you want to run ETWFE on.
##' @param tref Optional reference value for `tvar`. Defaults to its minimum 
##' value (i.e., the first time period observed in the dataset).
##' @param gref Optional reference value for `gvar`. You shouldn't need to 
##' provide this if your `gvar` variable is well specified. But providing an 
##' explicit reference value can be useful/necessary if the desired control 
##' group takes an unusual value.
##' @param cgroup What control group do you wish to use for 
##' estimating treatment effects. Either "notyet" treated (the default) or
##' "never" treated.
##' @param fe What level of fixed effects should be used? Defaults to "vs" 
##' (varying slopes), which is the most efficient in terms of estimation and 
##' terseness of the return model object. The other two options, "feo" (fixed 
##' effects only) and "none" (no fixed effects whatsoever), trade off efficiency
##' for additional information on other (nuisance) model parameters. Note that
##' the primary treatment parameters of interest should remain unchanged 
##' regardless of choice.
##' @param family Which [`family`] to use for the estimation. Defaults to NULL, in 
##' which case [`fixest::feols`] is used. Otherwise passed to [`fixest::feglm`], so
##' that valid entries include "logit", "poisson", and "negbin". Note that if a
##' non-NULL family entry is detected, `ivar` will automatically be set to NULL. 
##' @param ... Additional arguments passed to [`fixest::feols`] (or 
##' [`fixest::feglm`]). The most common example would be a `vcov` argument.
##' @return A fixest object with fully saturated interaction effects.
##' @references Wooldridge, Jeffrey M. (2021). \cite{Two-Way Fixed Effects, the 
##' Two-Way Mundlak Regression, and Difference-in-Differences Estimators}.
##' Working paper (version: August 16, 2021). Available: 
##' http://dx.doi.org/10.2139/ssrn.3906345
##' @seealso [fixest::feols()], [fixest::feglm()]
##' @examples
##' # We'll use the 'base_stagg' dataset from fixest to demonstrate ETWFE's
##' # functionality in a staggered difference-in-differences setting.
##' data("base_stagg", package = "fixest")
##' 
##' # Run the estimation
##' mod = etwfe(
##'     fml  = y ~ x1, 
##'     tvar = year, 
##'     gvar = year_treated, 
##'     data = base_stagg, 
##'     vcov = ~ id
##'     )
##' mod
##' 
##' # We can recover a variety of treatment effects of interest with the 
##' # complementary emfx() function. For example:
##' emfx(mod, type = "event")
##' 
##' @export
etwfe = function(
    fml = NULL,
    ivar = NULL,
    tvar = NULL, 
    gvar = NULL,
    data = NULL,
    tref = NULL,
    gref = NULL,
    cgroup = c("notyet", "never"),
    fe = c("vs", "feo", "none"),
    family = NULL,
    ...
) {
  
  cgroup = match.arg(cgroup)
  fe = match.arg(fe)
  rhs = ctrls = vs = ref_string = ctrls_dm_df = NULL
  gref_min_flag = FALSE
  
  if (is.null(fml)) stop("A non-NULL `fml` argument is required.\n")
  if (is.null(data)) stop("A non-NULL `data` argument is required.\n")
  
  ## NSE ----
  nl = as.list(seq_along(data))
  names(nl) = names(data)
  ivar = eval(substitute(ivar), nl, parent.frame())
  if (is.numeric(ivar)) ivar = names(data)[ivar]
  tvar = eval(substitute(tvar), nl, parent.frame())
  if (is.numeric(tvar)) tvar = names(data)[tvar]
  gvar = eval(substitute(gvar), nl, parent.frame())
  if (is.numeric(gvar)) gvar = names(data)[gvar]
  
  if (is.null(gvar)) stop("A non-NULL `gvar` argument is required.\n")
  if (is.null(tvar)) stop("A non-NULL `tvar` argument is required.\n")
  if (!is.null(family)) ivar = NULL
  
  fml_paste = paste(fml)
  lhs = fml_paste[2]
  ctrls = fml_paste[3]
  if (length(ctrls) == 0) {
    ctrls = NULL
  } else if (ctrls == "0") {
    ctrls = NULL
  } else {
    ctrls_dm = paste0(ctrls, "_dm")
    if (fe == "vs") vs = paste0("[", ctrls, "]") ## For varying slopes later 
  }
  
  if (is.null(gref)) {
    ug = unique(data[[gvar]])
    ut = unique(data[[tvar]])
    gref = ug[ug > max(ut)]
    if (length(gref)==0) gref = ug[ug < min(ut)]
    if (length(gref)==0 && cgroup=="notyet") gref = max(ug)
    if (length(gref)==0) {
      stop("The '", cgroup,"' control group for ", gvar, " could not be identified. You can provide a bespoke group reference level via the `gref` argument.\n")
    }
    if (length(gref) > 1) {
      gref = min(gref) ## placeholder. could do something a bit smarter here like bin post periods.
      ## also: what about NA vals?
    }
    if (gref < min(ut)) gref_min_flag = TRUE
  } else {
    # Sanity check proposed gref level
    if (!(gref %in% unique(data[[gvar]]))) {
      stop("Proposed reference level ", gref, " not found in ", gvar, ".\n")
    }
    if (gref < min(unique(data[[tvar]]))) gref_min_flag = TRUE
  }
  
  ref_string = paste0(", ref = ", gref)
  
  if (is.null(tref)) {
      tref = min(data[[tvar]], na.rm = TRUE)
  } else if (!(tref %in% unique(data[[tvar]]))) {
      stop("Proposed reference level ", tref, " not found in ", tvar, ".\n")
  }
  if (length(tref) > 1) {
      tref = min(tref, na.rm = TRUE) ## placeholder. could do something a bit smarter here like bin post periods.
      ## also: what about NA vals?
  }
  ref_string = paste0(ref_string, ", ref2 = ", tref)
  
  if (cgroup == "notyet") {
    data[[".Dtreat"]] = as.integer(data[[tvar]] >= data[[gvar]] & data[[gvar]] != gref)
    if (!gref_min_flag) {
      data[[".Dtreat"]] = ifelse(data[[tvar]] < gref, data[[".Dtreat"]], NA_integer_)
    } else {
      data[[".Dtreat"]] = ifelse(data[[tvar]] > gref, data[[".Dtreat"]], NA_integer_)
    }
  } else {
    ## Placeholder .Dtreat for never treated group
    data[[".Dtreat"]] = 1L
  }
  rhs = paste0(".Dtreat : ", rhs)
  
  rhs = paste0(rhs, "i(", gvar, ", i.", tvar, ref_string, ")")
  
  ## Demean and interact controls ----
  
  if (!is.null(ctrls)) {
    dm_fml = stats::reformulate(c(gvar, tvar), response = ctrls)
    ctrls_dm_df = fixest::demean(dm_fml, data = data, as.matrix = FALSE)
    ctrls_dm_df = stats::setNames(ctrls_dm_df, ctrls_dm)
    data = cbind(data, ctrls_dm_df)
    
    rhs = paste(rhs, "/", ctrls_dm)
    
    if (fe != "vs") {
      ictrls = strsplit(ctrls, split = " \\+ ")[[1]]
      ictrls = paste(
        c(
          ctrls,
          paste(paste0("i(", gvar, ", ", ictrls, ", ref = ", gref, ")"), collapse = " + "),
          paste(paste0("i(", tvar, ", ", ictrls, ", ref = ", tref, ")"), collapse = " + ")
          ),
        collapse = " + "
        )
      rhs = paste(rhs, "+", ictrls) 
    }
  }
  
  ## Fixed effects ----
  
  if (fe != "none") {
    if (is.null(ivar)) {
      fes = stats::reformulate(paste0(c(gvar, tvar), vs))
    } else {
      fes = stats::reformulate(paste0(c(ivar, tvar), vs))
    }
    fes = paste(fes)[2]
  } else {
    fes = 0
    rhs = paste0(
      rhs, 
      "+ i(", gvar, ", ref = ", gref, ") + i(", tvar, ", ref = ", tref, ")"
      )
  }
  
  ## Estimation ----
  
  ## Full formula
  Fml = Formula::as.Formula(paste(lhs, " ~ ", rhs, "|", fes)) 
  
  ## Estimate
  if (is.null(family)) {
    est = fixest::feols(Fml, data = data, notes = FALSE, ...)
  } else {
    est = fixest::feglm(Fml, data = data, notes = FALSE, family = family, ...)
  }
  
  ## Overload class and new attributes (for post-estimation) ----
  class(est) = c("etwfe", class(est))
  attr(est, "etwfe") = list(
    gvar = gvar,
    tvar = tvar
  )
  
  ## Return ----
  
  return(est)
  
}
