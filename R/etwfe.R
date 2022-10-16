##' Extended two-way fixed effects
##'
##' @param fml A formula with the outcome (lhs) and any additional control 
##' variables (rhs), e.g. `y ~ x1`. If no additional controls are required, the 
##' rhs must take the value of zero, e.g. `y ~ 0`.
##' @param ivar Index variable. Can be a string (e.g., "country") or an 
##' expression (e.g., country). Leaving as NULL (the default) will result in
##' group-level fixed effects being used, which is more efficient and necessary 
##' for nonlinear models (see `family`).
##' @param tvar Time variable. Can be a string (e.g., "year") or an expression
##' (e.g., year).
##' @param gvar Group variable. Can be either a string (e.g., "first_treated") 
##' or an expression (e.g., first_treated). In a staggered treatment setting, 
##' the group variable typically denotes treatment cohort.
##' @param data The data frame that you want to run ETWFE on.
##' @param tref Optional reference value for `tvar`. Defaults to its minimum 
##' value (i.e., the first time period observed in the dataset).
##' @param gref Optional reference value for `gvar`. You shouldn't need to 
##' provide this if your `gvar` variable is well specified (by default we will
##' look to reference against a value greater than `max(tvar)`). But providing 
##' an explicit reference value can be useful/necessary if the never treated 
##' group, for example, takes an unusual value.
##' @param cgroup What control group do you wish to use for 
##' estimating treatment effects. Either "notyet" treated (the default) or
##' "never" treated.
##' @param family Family to be used for the estimation. Defaults to NULL, in 
##' which case `fixest::feols` is used. Otherwise passed to `fixest::feglm`, so
##' that valid entries include "logit", "poisson", and "negbin". Note that if a
##' non-NULL family entry is detected, `ivar` will automatically be set to NULL. 
##' @param ... Additional arguments passed to `fixest::feols` (or 
##' `fixest::feglm`). The most common example would be a `vcov` argument. 
##' @return A fixest object with fully saturated interaction effects.
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
    family = NULL,
    ...
) {
  
  cgroup = match.arg(cgroup)
  rhs = ctrls = vs = ref_string = ctrls_dm_df = NULL
  
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
    vs = paste0("[", ctrls, "]") ## For varying slopes later
  }
  
  if (is.null(gref)) {
    ug = unique(data[[gvar]])
    ut = unique(data[[tvar]])
    gref = ug[ug > max(ut)]
    if (length(gref)==0) {
      stop("The '", cgroup,"' control group for ", gvar, " could not be identified. You can provide a bespoke group reference level via the `gref` argument.\n")
    }
    if (length(gref) > 1) {
      gref = min(gref) ## placeholder. could do something a bit smarter here like bin post periods.
      ## also: what about NA vals?
    }
  } else {
    # Sanity check proposed gref level
    if (!(gref %in% unique(data[[gvar]]))) {
      stop("Proposed reference level ", gref, " not found in ", gvar, ".\n")
    }
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
    data[[".Dtreat"]] = as.integer(data[[tvar]] >= data[[gvar]] & data[[gvar]]!=gref)
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
  }
  
  ## Fixed effects ----
  
  if (is.null(ivar)) {
    fes = stats::reformulate(paste0(c(gvar, tvar), vs))
  } else {
    fes = stats::reformulate(paste0(c(ivar, tvar), vs))
  }
  
  ## Estimation ----
  
  ## Full formula
  Fml = Formula::as.Formula(paste(lhs, " ~ ", rhs, "|", fes[2])) 
  
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
