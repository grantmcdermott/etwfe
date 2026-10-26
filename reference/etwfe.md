# Extended two-way fixed effects

Estimates an "extended" two-way fixed effects regression, with fully
saturated interaction effects *a la* Wooldridge (2023, 2025). At its
heart, `etwfe` is a convenience function that automates a number of
tedious and error prone preparation steps involving both the data and
model formulae. Computation is passed on to the
[`feols`](https://lrberge.github.io/fixest/reference/feols.html)
(linear) /
[`feglm`](https://lrberge.github.io/fixest/reference/feglm.html)
(nonlinear) functions from the **fixest** package. `etwfe` should be
paired with its companion
[`emfx`](http://grantmcdermott.com/etwfe/reference/emfx.md) function.

## Usage

``` r
etwfe(
  fml = NULL,
  tvar = NULL,
  gvar = NULL,
  data = NULL,
  ivar = NULL,
  xvar = NULL,
  tref = NULL,
  gref = NULL,
  cgroup = c("notyet", "never"),
  fe = NULL,
  family = NULL,
  ...
)
```

## Arguments

- fml:

  A two-side formula representing the outcome (lhs) and any control
  variables (rhs), e.g. `y ~ x1 + x2`. If no controls are required, the
  rhs must take the value of 0 or 1, e.g. `y ~ 0`.

- tvar:

  Time variable. Can be a string (e.g., "year") or an expression (e.g.,
  year).

- gvar:

  Group variable. Can be either a string (e.g., "first_treated") or an
  expression (e.g., first_treated). In a staggered treatment setting,
  the group variable typically denotes treatment cohort.

- data:

  The data frame that you want to run ETWFE on.

- ivar:

  Optional index variable. Can be a string (e.g., "country") or an
  expression (e.g., country). Leaving as NULL (the default) will result
  in group-level fixed effects being used, which is more efficient and
  necessary for nonlinear models (see `family` argument below). However,
  you may still want to cluster your standard errors by your index
  variable through the `vcov` argument. See Examples below.

- xvar:

  Optional interacted categorical covariate for estimating heterogeneous
  treatment effects. Enables recovery of the marginal treatment effect
  for distinct levels of `xvar`, e.g. "child", "teenager", or "adult".
  Note that the "x" prefix in "xvar" represents a covariate that is
  *interacted* with treatment, as opposed to a regular control variable.

- tref:

  Optional reference value for `tvar`. Defaults to its minimum value
  (i.e., the first time period observed in the dataset).

- gref:

  Optional reference value for `gvar`. You shouldn't need to provide
  this if your `gvar` variable is well specified. But providing an
  explicit reference value can be useful/necessary if the desired
  control group takes an unusual value.

- cgroup:

  What control group do you wish to use for estimating treatment
  effects. Either "notyet" treated (the default) or "never" treated.

- fe:

  What category of fixed effects should be used? One of either `"vs"`
  (varying slopes), `"feo"` (fixed effects only), or `"none"` (no fixed
  effects whatsoever). If left as `NULL` (i.e., no explicit choice) then
  will default to `"vs"` for linear/Gaussian models, since this is the
  most efficient estimation option and further limits the number of
  "nuisance" parameters in the return model object. However, for
  non-Gaussian families will default to `"none"`, since the downstream
  [`emfx`](http://grantmcdermott.com/etwfe/reference/emfx.md) function
  cannot compute standard errors for these models in the presence of
  fixed-effects. (See:
  https://github.com/vincentarelbundock/marginaleffects/issues/1487)
  Please note that the primary treatment parameters of interest should
  remain unchanged regardless of `fe` argument choice.

- family:

  Which [`family`](https://rdrr.io/r/stats/family.html) to use for the
  estimation. Defaults to NULL, in which case
  [`fixest::feols`](https://lrberge.github.io/fixest/reference/feols.html)
  is used. Otherwise passed to
  [`fixest::feglm`](https://lrberge.github.io/fixest/reference/feglm.html),
  so that valid entries include "logit", "poisson", and "negbin". Note
  that if a non-NULL family entry is detected, `ivar` will automatically
  be set to NULL.

- ...:

  Additional arguments passed to
  [`fixest::feols`](https://lrberge.github.io/fixest/reference/feols.html)
  (or
  [`fixest::feglm`](https://lrberge.github.io/fixest/reference/feglm.html)).
  The most common example would be a `vcov` argument. Note that
  incomplete cases are dropped before any controls (or `xvar`) are
  demeaned, but only for variables in `fml`, the `gvar`, `tvar`, `ivar`
  and `xvar` arguments, and one-sided formula `weights` (e.g.,
  `weights = ~pop`). Other sample restrictions passed here (e.g.,
  `subset`, or vector `weights` with missing values) are applied by
  `feols` after demeaning, so you should remove the affected rows from
  `data` beforehand.

## Value

A
[`fixest`](https://lrberge.github.io/fixest/reference/fixest-package.html)
object with fully saturated interaction effects, and a few additional
attributes used for post-estimation in `emfx`.

## Heterogeneous treatment effects

Specifying `etwfe(..., xvar = <xvar>)` will generate interaction effects
for all levels of `<xvar>` as part of the main regression model. The
reason that this is useful (as opposed to a regular, non-interacted
covariate in the formula RHS) is that it allows us to estimate
heterogeneous treatment effects as part of the larger ETWFE framework.
Specifically, we can recover heterogeneous treatment effects for each
level of `<xvar>` by passing the resulting `etwfe` model object on to
[`emfx()`](http://grantmcdermott.com/etwfe/reference/emfx.md).

For example, imagine that we have a categorical variable called "age" in
our dataset, with two distinct levels "adult" and "child". Running
`emfx(etwfe(..., xvar = age))` will tell us how the efficacy of
treatment varies across adults and children. We can then also leverage
the in-built hypothesis testing infrastructure of `marginaleffects` to
test whether the treatment effect is statistically different across
these two age groups; see Examples below. Note the same principles carry
over to categorical variables with multiple levels, or even continuous
variables (although continuous variables are not as well supported yet).

## Performance

Both `etwfe` and `emfx` should be fast, even for large datasets. In
particular, as of **etwfe** v0.7.0, `emfx` is orders of magnitude faster
than it used to be, because it now computes standard errors using exact
analytic Jacobians. (Earlier versions relied on a numerical delta
method, which required estimating two prediction models for *each*
coefficient in the model.)

## References

Wooldridge, Jeffrey M. (2025). Two-way fixed effects, the two-way
Mundlak regression, and difference-in-differences estimators. Empirical
Economics, 69, 2545-2587. Available:
https://doi.org/10.1007/s00181-025-02807-z

Wooldridge, Jeffrey M. (2023). Simple Approaches to Nonlinear
Difference-in-Differences with Panel Data. The Econometrics Journal,
26(3), C31-C66. Available: https://doi.org/10.1093/ectj/utad016

## See also

[`fixest::feols()`](https://lrberge.github.io/fixest/reference/feols.html),
[`fixest::feglm()`](https://lrberge.github.io/fixest/reference/feglm.html)
which power the underlying estimation routines.
[`emfx`](http://grantmcdermott.com/etwfe/reference/emfx.md) is a
companion function that handles post-estimation aggregation to extract
quantities of interest.

## Examples

``` r
# We'll use the base_stagg dataset from the fixest package, which simulates a
# staggered treatment rollout across 100 units over 10 years. Never-treated
# units have `year_treated = 10000`.
data("base_stagg", package = "fixest")

#
# Basic example
#

# The basic ETWFE workflow involves two consecutive function calls:
# 1) `etwfe` and 2) `emfx`

# 1) `etwfe`: Estimate a regression model with saturated interaction terms.
mod = etwfe(
  fml  = y ~ x1,       # outcome ~ controls (use 0 or 1 if none)
  tvar = year,         # time variable
  gvar = year_treated, # group variable
  data = base_stagg,   # dataset
  vcov = ~id           # vcov adjustment (here: clustered by unit)
  )

# mod ## A fixest model object with fully saturated interaction effects.

# 2) `emfx`: Recover the treatment effects of interest.

(mod_es = emfx(mod, type = "event")) # dynamic ATE a la an event study
#> 
#>  event Estimate Std. Error      z Pr(>|z|)     S  2.5 %  97.5 %
#>      0   -5.195      0.351 -14.79   <0.001 162.0 -5.884 -4.5070
#>      1   -3.467      0.360  -9.64   <0.001  70.7 -4.172 -2.7625
#>      2   -2.049      0.299  -6.86   <0.001  37.1 -2.635 -1.4637
#>      3   -0.881      0.411  -2.15   0.0319   5.0 -1.686 -0.0764
#>      4    0.917      0.358   2.56   0.0103   6.6  0.216  1.6186
#>      5    2.047      0.429   4.77   <0.001  19.1  1.206  2.8886
#>      6    4.150      0.427   9.72   <0.001  71.8  3.314  4.9872
#>      7    4.509      0.386  11.68   <0.001 102.3  3.752  5.2651
#>      8    5.220      0.742   7.04   <0.001  38.9  3.766  6.6734
#> 
#> Term: .Dtreat
#> Type: response
#> Comparison: TRUE - FALSE
#> 

# Etc. Other aggregation type options are "simple" (the default), "group"
# and "calendar"

# To visualize results, use the native plot method (see `?plot.emfx`)
plot(mod_es)


# Aside: With R >= 4.1.0, you can also chain the whole workflow together with
# the native pipe, e.g.:
# etwfe(
#   fml  = y ~ x1,
#   tvar = year,
#   gvar = year_treated,
#   data = base_stagg,
#   vcov = ~id
#   ) |>
#   emfx(type = "event") |>
#   plot()

# Notice that we don't get any pre-treatment effects with the default
# "notyet" treated control group. Switch to the "never" treated control
# group if you want this.
mod_never = etwfe(
  y ~ x1, tvar = year, gvar = year_treated, data = base_stagg,
  vcov = ~id,
  cgroup = "never"    ## <= use never treated group as control
  )
plot(emfx(mod_never, "event"))


#
# Heterogeneous treatment effects
#

# Example where we estimate heterogeneous treatment effects for two
# (arbitrary) groups of units.

base_stagg$grp = base_stagg$id > 50

hmod = etwfe(
  y ~ x1, tvar = year, gvar = year_treated, data = base_stagg,
  vcov = ~id,
  xvar = grp           ## <= het. TEs by grp
  )

# Heterogeneous ATEs (could also specify "event", etc.)

emfx(hmod)
#> 
#>  .Dtreat   grp Estimate Std. Error     z Pr(>|z|)   S 2.5 % 97.5 %
#>     TRUE FALSE   -1.603      0.596 -2.69   0.0071 7.1 -2.77 -0.436
#>     TRUE  TRUE   -0.773      0.662 -1.17   0.2431 2.0 -2.07  0.525
#> 
#> Term: .Dtreat
#> Type: response
#> Comparison: TRUE - FALSE
#> 

# To test whether the ATEs across these two groups are statistically
# different, simply pass an appropriate "hypothesis" argument.

emfx(hmod, hypothesis = "b1 = b2")
#> 
#>  Hypothesis Estimate Std. Error      z Pr(>|z|)   S 2.5 % 97.5 %
#>       b1=b2    -0.83      0.879 -0.945    0.345 1.5 -2.55  0.892
#> 
#> Type: response
#> 

plot(emfx(hmod))


#
# Nonlinear model (distribution / link) families
#

# Poisson example (using a transformed, strictly positive outcome)

base_stagg$y_exp = exp(base_stagg$y / 10)

pmod = etwfe(
  y_exp ~ x1, tvar = year, gvar = year_treated, data = base_stagg,
  vcov = ~id,
  family = "poisson"   ## <= family arg for nonlinear options
  )
#> The variables '.Dtreat:year_treated::3:year::2',
#> '.Dtreat:year_treated::4:year::2', '.Dtreat:year_treated::4:year::3',
#> '.Dtreat:year_treated::5:year::2', '.Dtreat:year_treated::5:year::3',
#> '.Dtreat:year_treated::5:year::4' and 66 others have been removed because of
#> collinearity (see $collin.var).
emfx(pmod, "event")
#> 
#>  event Estimate Std. Error      z Pr(>|z|)     S   2.5 %  97.5 %
#>      0   -0.412     0.0268 -15.39  < 0.001 175.0 -0.4647 -0.3597
#>      1   -0.316     0.0362  -8.72  < 0.001  58.4 -0.3864 -0.2446
#>      2   -0.189     0.0300  -6.30  < 0.001  31.7 -0.2483 -0.1305
#>      3   -0.101     0.0457  -2.20  0.02755   5.2 -0.1904 -0.0111
#>      4    0.118     0.0413   2.86  0.00421   7.9  0.0372  0.1991
#>      5    0.275     0.0576   4.77  < 0.001  19.1  0.1621  0.3880
#>      6    0.674     0.0835   8.07  < 0.001  50.4  0.5107  0.8380
#>      7    0.703     0.1041   6.75  < 0.001  36.0  0.4990  0.9070
#>      8    1.176     0.2346   5.01  < 0.001  20.8  0.7165  1.6362
#> 
#> Term: .Dtreat
#> Type: response
#> Comparison: TRUE - FALSE
#> 
```
