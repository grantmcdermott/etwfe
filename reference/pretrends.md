# Test for pre-trends

Jointly tests the null hypothesis of parallel (common) trends prior to
treatment, following Wooldridge (2025, Sec. 7). A light wrapper around
[`fixest::wald()`](https://lrberge.github.io/fixest/reference/wald.html)
that selects the relevant coefficients on your behalf. The test depends
on how the [etwfe](https://grantmcdermott.com/etwfe/reference/etwfe.md)
model was estimated:

- `trend = TRUE`: tests that the cohort-specific linear trends are
  jointly zero.

- `cgroup = "never"`: tests that the pre-treatment cohort-period effects
  (i.e., the "leads" in an event study) are jointly zero.

These are alternative tests of the same null hypothesis, and cannot be
combined in a single model; cohort trends and a full set of
pre-treatment effects are not separately identified. Note that the
`cgroup = "never"` model is equivalent to augmenting the default
`"notyet"` model with the pre-treatment effects, as per Wooldridge's
test regression.

## Usage

``` r
pretrends(x, interactions = FALSE, ...)
```

## Arguments

- x:

  An `etwfe` model object.

- interactions:

  Logical. Should interactions between the tested terms and any
  (demeaned) controls or `xvar` covariates also be included in the joint
  null? Defaults to `FALSE`, following Wooldridge (2025), who notes that
  testing for covariate-dependent violations of parallel trends comes at
  a considerable cost in power.

- ...:

  Additional arguments passed to
  [`fixest::wald()`](https://lrberge.github.io/fixest/reference/wald.html),
  e.g. `print` or `vcov`.

## Value

The result of
[`fixest::wald()`](https://lrberge.github.io/fixest/reference/wald.html):
a list containing the test statistic, p-value, degrees of freedom, and
vcov type.

## Details

The `cgroup = "never"` test involves roughly one restriction per
pre-treatment period per cohort, which can be a lot. Each cohort's
restrictions are informed mainly by that cohort's own units, so a
cluster-robust test needs many clusters (units) per cohort. With few
clusters per cohort, the cluster-robust vcov can badly underestimate the
variance of some combinations of the pre-treatment effects, leading the
joint test to over-reject (sometimes wildly) even when the individual
estimates look unremarkable. The cohort trends test (one restriction per
cohort) is much less susceptible to this problem.

## References

Wooldridge, Jeffrey M. (2025). Two-way fixed effects, the two-way
Mundlak regression, and difference-in-differences estimators. Empirical
Economics, 69, 2545-2587. Available:
https://doi.org/10.1007/s00181-025-02807-z

## See also

[`fixest::wald()`](https://lrberge.github.io/fixest/reference/wald.html),
which performs the underlying test.

## Examples

``` r
#
# Option 1: cgroup = "notyet" (default) + trend = TRUE
#

# Tests whether the cohort-specific linear trends are jointly zero. Requires
# at least two pre-treatment periods per cohort, so we drop the cohort
# treated in year 2.
data("base_stagg", package = "fixest")
mod_trend = etwfe(
  y ~ x1, tvar = year, gvar = year_treated,
  data = subset(base_stagg, year_treated != 2), vcov = ~id,
  trend = TRUE # <= cohort trends (with default cgroup = "notyet")
)
pretrends(mod_trend)
#> Wald test, H0: joint nullity of year_treated::3:year, year_treated::4:year, year_treated::5:year, year_treated::6:year, year_treated::7:year, year_treated::8:year and 2 others
#>  stat = 0.511144, p-value = 0.845112, on 8 and 89 DoF, VCOV: Clustered (id).

#
# Option 2: cgroup = "never"
#

# Tests whether the pre-treatment effects (event study leads) are jointly
# zero. This involves many more restrictions, so we switch to the bundled
# walmart dataset, which has enough units per cohort for a reliable
# cluster-robust test.
mod_never = etwfe(
  log_retail_emp ~ 0, tvar = year, gvar = cohort,
  ivar = fips, wvar = n_open,
  data = walmart, vcov = ~fips,
  cgroup = "never" # <= never-treated control group
)
pretrends(mod_never)
#> Wald test, H0: joint nullity of .Dpre:cohort::1986:year::1977, .Dpre:cohort::1986:year::1978, .Dpre:cohort::1986:year::1979, .Dpre:cohort::1986:year::1980, .Dpre:cohort::1986:year::1981, .Dpre:cohort::1986:year::1982 and 197 others
#>  stat = 4.19796, p-value < 2.2e-16, on 203 and 1,287 DoF, VCOV: Clustered (fips).
```
