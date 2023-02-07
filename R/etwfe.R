##' Extended two-way fixed effects
##'
##' @param fml A two-side formula representing the outcome (lhs) and any control
##'   variables (rhs), e.g. `y ~ x1 + x2`. If no controls are required, the rhs
##'   must take the value of 0 or 1, e.g. `y ~ 0`.
##' @param tvar Time variable. Can be a string (e.g., "year") or an expression
##'   (e.g., year).
##' @param gvar Group variable. Can be either a string (e.g., "first_treated")
##'   or an expression (e.g., first_treated). In a staggered treatment setting,
##'   the group variable typically denotes treatment cohort.
##' @param data The data frame that you want to run ETWFE on.
##' @param ivar Optional index variable. Can be a string (e.g., "country") or an
##'   expression (e.g., country). Leaving as NULL (the default) will result in
##'   group-level fixed effects being used, which is more efficient and
##'   necessary for nonlinear models (see `family` argument below). However, you
##'   may still want to cluster your standard errors by your index variable
##'   through the `vcov` argument. See Examples below.
##' @param xvar Optional interacted categorical covariate for estimating
##'   heterogeneous treatment effects. Enables recovery of the marginal
##'   treatment effect for distinct levels of `xvar`, e.g. "child", "teenager",
##'   or "adult". Note that the "x" prefix in "xvar" represents a covariate that
##'   is *interacted* with treatment, as opposed to a regular control variable.
##' @param tref Optional reference value for `tvar`. Defaults to its minimum
##'   value (i.e., the first time period observed in the dataset).
##' @param gref Optional reference value for `gvar`. You shouldn't need to
##'   provide this if your `gvar` variable is well specified. But providing an
##'   explicit reference value can be useful/necessary if the desired control
##'   group takes an unusual value.
##' @param cgroup What control group do you wish to use for estimating treatment
##'   effects. Either "notyet" treated (the default) or "never" treated.
##' @param fe What level of fixed effects should be used? Defaults to "vs"
##'   (varying slopes), which is the most efficient in terms of estimation and
##'   terseness of the return model object. The other two options, "feo" (fixed
##'   effects only) and "none" (no fixed effects whatsoever), trade off
##'   efficiency for additional information on other (nuisance) model
##'   parameters. Note that the primary treatment parameters of interest should
##'   remain unchanged regardless of choice.
##' @param family Which [`family`] to use for the estimation. Defaults to NULL,
##'   in which case [`fixest::feols`] is used. Otherwise passed to
##'   [`fixest::feglm`], so that valid entries include "logit", "poisson", and
##'   "negbin". Note that if a non-NULL family entry is detected, `ivar` will
##'   automatically be set to NULL.
##' @param ... Additional arguments passed to [`fixest::feols`] (or
##'   [`fixest::feglm`]). The most common example would be a `vcov` argument.
##' @return A fixest object with fully saturated interaction effects.
##' 
##' @section Heterogeneous treatment effects:
##' 
##'   Specifying `etwfe(..., xvar = <xvar>)` will generate interaction effects
##'   for all levels of `<xvar>` as part of the main regression model. The
##'   reason that this is useful (as opposed to a regular, non-interacted
##'   covariate in the formula RHS) is that it allows us to estimate
##'   heterogeneous treatment effects as part of the larger ETWFE framework.
##'   Specifically, we can recover heterogeneous treatment effects for each
##'   level of `<xvar>` by passing the resulting `etwfe` model object on to 
##'   `emfx()`.
##'   
##'   For example, imagine that we have a categorical variable called "age" in
##'   our dataset, with two distinct levels "adult" and "child". Running
##'   `emfx(etwfe(..., xvar = age))` will tell us how the efficacy of treatment 
##'   varies across adults and children. We can then also leverage the in-built 
##'   hypothesis testing infrastructure of `marginaleffects` to test whether
##'   the treatment effect is statistically different across these two age
##'   groups; see Examples below. Note the same principles carry over to 
##'   categorical variables with multiple levels, or even continuous variables
##'   (although continuous variables are not as well supported yet).
##'   
##' @section Performance tips: 
##' 
##'   Under most situations, `etwfe` should complete very quickly. For its part,
##'   `emfx` is quite performant too and should take a few seconds or less for 
##'   datasets under 100k rows. However, `emfx`'s computation time does tend to
##'   scale linearly with the size of the original data, as well as the number
##'   of interactions from the underlying `etwfe` model. Without getting too deep
##'   into the weeds, the numerical delta method used to recover the ATEs of
##'   interest has to estimate two prediction models for *each* coefficient in
##'   the model and then compute their standard errors. So, it's a potentially
##'   expensive operation that can push the computation time for large datasets
##'   (> 1m rows) up to several minutes or longer. 
##'   
##'   Fortunately, there are two
##'   complementary strategies that you can use to speed things up. The first is
##'   to turn off the most expensive part of the whole procedure---standard
##'   error calculation---by calling `emfx(..., vcov = FALSE)`. Doing so should
##'   bring the estimation time back down to a few seconds or less, even for
##'   datasets in excess of a million rows. While the loss of standard errors
##'   might not be an acceptable trade-off for projects where statistical
##'   inference is critical, the good news is this first strategy can still be
##'   combined our second strategy. It turns out that collapsing the data by
##'   groups prior to estimating the marginal effects can yield substantial
##'   speed gains of its own. Users can do this by invoking the `emfx(...,
##'   collapse = TRUE)` argument. While the effect here is not as dramatic as
##'   the first strategy, our second strategy does have the virtue of retaining
##'   information about the standard errors. The trade-off this time, however,
##'   is that collapsing our data does lead to a loss in accuracy for our
##'   estimated parameters. On the other hand, testing suggests that this loss
##'   in accuracy tends to be relatively minor, with results equivalent up to
##'   the 1st or 2nd significant decimal place (or even better).
##'   
##'   Summarizing, here's a quick plan of attack for you to try if you are
##'   worried about the estimation time for large datasets and models:
##'   
##'   0. Estimate `mod = etwfe(...)` as per usual.
##'   
##'   1. Run `emfx(mod, vcov = FALSE, ...)`. 
##'   
##'   2. Run `emfx(mod, vcov = FALSE, collapse = TRUE, ...)`. 
##'   
##'   3. Compare the point estimates from steps 1 and 2. If they are are similar
##'   enough to your satisfaction, get the approximate standard errors by
##'   running `emfx(mod, collapse = TRUE, ...)`.
##' 
##' @references 
##' Wooldridge, Jeffrey M. (2021). \cite{Two-Way Fixed Effects, the 
##' Two-Way Mundlak Regression, and Difference-in-Differences Estimators}.
##' Working paper (version: August 16, 2021). Available: 
##' http://dx.doi.org/10.2139/ssrn.3906345
##'
##' Wooldridge, Jeffrey M. (2022). \cite{Simple Approaches to Nonlinear Difference-in-Differences with Panel Data}.
##' Working paper (version: August 7, 2022). Available: 
##' http://dx.doi.org/10.2139/ssrn.4183726
##' @seealso [fixest::feols()], [fixest::feglm()]
##' @examples
##' # We’ll use the mpdta dataset from the did package (which you’ll need to 
##' # install separately).
##'
##' # install.packages("did")
##' data("mpdta", package = "did")
##' 
##' #
##' # Basic example
##' #
##' 
##' # The basic ETWFE workflow involves two steps:
##' 
##' # 1) Estimate the main regression model with etwfe().
##' 
##' mod = etwfe(
##'     fml  = lemp ~ lpop, # outcome ~ controls (use 0 or 1 if none)
##'     tvar = year,        # time variable
##'     gvar = first.treat, # group variable
##'     data = mpdta,       # dataset
##'     vcov = ~countyreal  # vcov adjustment (here: clustered by county)
##'     )
##' mod
##' 
##' # 2) Recover the treatment effects of interest with emfx().
##' 
##' emfx(mod)                 # simple average treatment effect (default)
##' emfx(mod, type = "event") # dynamic treatment effect a la an event study
##' # Etc. Other aggregation types are "group" and "calendar"
##' 
##' 
##' #
##' # Heterogeneous treatment effects
##' #
##' 
##' # Example where we estimate heterogeneous treatment effects for counties 
##' # within the 8 US Great Lake states (versus all other counties). 
##' 
##' gls = c("IL" = 17, "IN" = 18, "MI" = 26, "MN" = 27,
##'         "NY" = 36, "OH" = 39, "PA" = 42, "WI" = 55)
##' 
##' mpdta$gls = substr(mpdta$countyreal, 1, 2) %in% gls
##' 
##' hmod = etwfe(
##'    lemp ~ lpop, tvar = year, gvar = first.treat, data = mpdta, 
##'    vcov = ~countyreal,
##'    xvar = gls           ## <= het. TEs by gls
##'    )
##' 
##' # Heterogeneous ATEs (could also specify "event", etc.) 
##' 
##' emfx(hmod)
##' 
##' # To test whether the ATEs across these two groups (non-GLS vs GLS) are 
##' # statistically different, simply pass an appropriate "hypothesis" argument.
##' 
##' emfx(hmod, hypothesis = "b1 = b2")
##' 
##' 
##' #
##' # Nonlinear model (distribution / link) families
##' #
##' 
##' # Poisson example
##' 
##' mpdta$emp = exp(mpdta$lemp)
##' 
##' etwfe(
##'    emp ~ lpop, tvar = year, gvar = first.treat, data = mpdta, 
##'    vcov = ~countyreal,
##'    family = "poisson"   ## <= family arg for nonlinear options
##'    ) |>
##'    emfx("event")
##' 
##' @export
etwfe = function(
    fml = NULL,
    tvar = NULL,
    gvar = NULL,
    data = NULL,
    ivar = NULL,
    xvar = NULL,
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
  data = as.data.frame(data)
  
  ## NSE ----
  nl = as.list(seq_along(data))
  names(nl) = names(data)
  tvar = eval(substitute(tvar), nl, parent.frame())
  if (is.numeric(tvar)) tvar = names(data)[tvar]
  gvar = eval(substitute(gvar), nl, parent.frame())
  if (is.numeric(gvar)) gvar = names(data)[gvar]
  ivar = eval(substitute(ivar), nl, parent.frame())
  if (is.numeric(ivar)) ivar = names(data)[ivar]
  xvar = eval(substitute(xvar), nl, parent.frame())
  if (is.numeric(xvar)) xvar = names(data)[xvar]

  if (is.null(gvar)) stop("A non-NULL `gvar` argument is required.\n")
  if (is.null(tvar)) stop("A non-NULL `tvar` argument is required.\n")
  if (!is.null(family)) ivar = NULL
  
  fml_paste = paste(fml)
  lhs = fml_paste[2]
  ctrls = fml_paste[3]
  if (length(ctrls) == 0) {
    ctrls = NULL
  } else if (ctrls %in% c("0", "1")) {
    ctrls = NULL
  } else {
    ctrls_dm = unique(paste0(strsplit(ctrls, " \\+ | \\* | \\: ")[[1]], "_dm"))
    if (fe == "vs") {
      vs = paste0("[", gsub(" \\+", ",", ctrls), "]") ## For varying slopes later 
    }
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
    data[[".Dtreat"]] = data[[tvar]] >= data[[gvar]] & data[[gvar]] != gref
    if (!gref_min_flag) {
      data[[".Dtreat"]] = ifelse(data[[tvar]] < gref, data[[".Dtreat"]], NA)
    } else {
      data[[".Dtreat"]] = ifelse(data[[tvar]] > gref, data[[".Dtreat"]], NA)
    }
  } else {
    ## Placeholder .Dtreat for never treated group
    data[[".Dtreat"]] = TRUE
  }
  rhs = paste0(".Dtreat : ", rhs)
  
  rhs = paste0(rhs, "i(", gvar, ", i.", tvar, ref_string, ")")
  
  ## Demean and interact controls ----
  if (!is.null(ctrls)) {
    dm_fml = stats::reformulate(c(gvar, tvar), response = ctrls)
    ctrls_dm_df = fixest::demean(dm_fml, data = data, as.matrix = FALSE)
    ctrls_dm_df = stats::setNames(ctrls_dm_df, ctrls_dm)
    data = cbind(data, ctrls_dm_df)
    
    if (length(ctrls_dm) > 1) {
      rhs = paste(rhs, "/", "(", paste(ctrls_dm, collapse = " + "), ")")
    } else {
      rhs = paste(rhs, "/", ctrls_dm)
    }
    
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
  
  ## Demean the interacted covariate ----
  if (!is.null(xvar)) {
    data$.Dtreated_cohort = ifelse(data[[gvar]] != gref & !is.na(data[[gvar]]), 1, 0) # generate a treatment-dummy
    
    dm_fml = stats::reformulate(c(tvar), response = xvar)
    ctrls_dm_df = fixest::demean(dm_fml, data = data, weights = data$.Dtreated_cohort, as.matrix = FALSE) # weights: only use the treated cohorts (units) to demean
    ctrls_dm_df = stats::setNames(ctrls_dm_df, paste0(xvar, "_dm")) # give a name
    data = cbind(data, ctrls_dm_df)
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
  
  ## Formula
  if( !is.null(xvar) ) {# Formula with interaction
    # one could add gvar:xvar, but the result is equivalent
    Fml <- Formula::as.Formula(paste0(
      lhs, " ~ ", rhs, "*", xvar, "_dm - ", xvar, "_dm",
      "+ i(", tvar, ", ref = ", tref, "):", xvar, "_dm |", fes
    )) 
  } else {# formula without interaction
    Fml = Formula::as.Formula(paste(lhs, " ~ ", rhs, "|", fes)) 
  }
  
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
      tvar = tvar,
      xvar = xvar,
      ivar = ivar,
      gref = gref,
      tref = tref
      )

  ## Return ----
  return(est)
  
}
