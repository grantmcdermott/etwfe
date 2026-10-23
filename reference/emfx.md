# Post-estimation aggregation of ETWFE results

Companion function to `etwfe`, enabling the recovery of aggregate
treatment effects along different dimensions of interest (e.g, an event
study of dynamic average treatment effects). `emfx` is a light wrapper
around the
[`slopes`](https://rdrr.io/pkg/marginaleffects/man/slopes.html) function
from the **marginaleffects** package.

## Usage

``` r
emfx(
  object,
  type = c("simple", "group", "calendar", "event"),
  by_xvar = "auto",
  compress = "auto",
  collapse = compress,
  predict = c("response", "link"),
  post_only = TRUE,
  window = NULL,
  lean = FALSE,
  ...
)
```

## Arguments

- object:

  An `etwfe` model object.

- type:

  Character. The desired type of post-estimation aggregation.

- by_xvar:

  Logical. Should the results account for heterogeneous treatment
  effects? Only relevant if the preceding `etwfe` call included a
  specified `xvar` argument, i.e. interacted categorical covariate. The
  default behaviour (`"auto"`) is to automatically estimate
  heterogeneous treatment effects for each level of `xvar` if these are
  detected as part of the underlying `etwfe` model object. Users can
  override by setting to either `FALSE` or `TRUE.` See the
  "Heterogeneous treatment effects" section below.

- compress:

  Logical. Compress the data by (period by cohort) groups before
  calculating marginal effects? This legacy argument was originally
  intended as a shortcut to reduce estimation times for large datasets.
  However, it is largely irrelevant as of **etwfe** v0.7.0, which
  introduced fast analytic standard errors (see the "Standard errors"
  section below). The default `"auto"` is retained for backwards
  compatibility and is equivalent to `FALSE`. Note that switching to
  `TRUE` also means losing the default unconditional standard errors,
  since these are not supported with data compression.

- collapse:

  Logical. An alias for `compress` (only used for backwards
  compatability and ignored if both arguments are provided). The
  behaviour is identical, but it will trigger a message nudging users to
  rather use the `compress` argument.

- predict:

  Character. The type (scale) of prediction used to compute the marginal
  effects. If `"response"` (the default), then the output is at the
  level of the response variable, i.e. it is the expected predictor
  \\E(Y\|X)\\. If `"link"`, the value returned is the linear predictor
  of the fitted model, i.e. \\X\cdot \beta\\. The difference should only
  matter for nonlinear models. (Note: This argument is typically called
  `type` when use in [`predict`](https://rdrr.io/r/stats/predict.html)
  or [`slopes`](https://rdrr.io/pkg/marginaleffects/man/slopes.html),
  but we rename it here to avoid a clash with the top-level `type`
  argument above.)

- post_only:

  Logical. Drop pre-treatment ATTs? Only evaluated if (a)
  `type = "event"` and (b) the original `etwfe` model object was
  estimated using the default `"notyet"` treated control group. If
  conditions (a) and (b) are met then the pre-treatment effects will be
  zero as a mechanical result of ETWFE's estimation setup. The default
  behaviour (`TRUE`) is thus to drop these nuisance rows from the
  dataset. The `post_only` argument recognises that you may still want
  to keep them for presentation purposes (e.g., plotting an event
  study). Nevertheless, be forewarned that enabling that behaviour via
  `FALSE` is *strictly* performative: the "zero" treatment effects for
  any pre-treatment periods is purely an artefact of the estimation
  setup.

- window:

  Numeric of length 1 or 2. Limits the temporal window of consideration
  around treatment.

  - NULL (default): Include all available periods.

  - Length 1: Truncate to a symmetric window around the treatment event.
    E.g., `window = 2` will truncate to two pre-treatment periods and
    two post-treatment periods.

  - Length 2: Asymmetric window, where the first number gives the
    maximum number of pre-treatment periods and the second number gives
    the maximum number of post-treatment periods. E.g.,
    `window = c(5, 2)` will truncate to five pre-treatment periods and
    two post-treatment periods.

  Note that the pre-treatment truncation is only ever binding in cases
  where the "never" treated group is used as a control, i.e.,
  `etwfe(..., cgroup = "never")` in the original call.

- lean:

  Logical. Default is `FALSE`. Switching to `TRUE` enforces a lean
  return object; namely a simple data.frame of the main results,
  stripped of ancillary attributes. Note that this will disable some
  advanced `marginaleffects` post-processing features, but those are
  unlikely to be used in the `emfx` context. The upside is a potentially
  dramatic reduction in the size of the return object. Consequently, we
  may change the default to `TRUE` in a future version of **etwfe**.

- ...:

  Additional arguments passed to
  [`marginaleffects::slopes`](https://rdrr.io/pkg/marginaleffects/man/slopes.html).
  For example, you can pass `vcov = FALSE` to skip standard errors
  entirely, or your own `vcov` argument (see the "Standard errors"
  section below). Another potentially useful application is testing
  whether heterogeneous treatment effects (i.e., the levels of any
  `xvar` covariate) are equal by invoking the `hypothesis` argument,
  e.g. `hypothesis = "b1 = b2"`.

## Value

A `data.frame` of aggregated treatment effects along the dimension(s) of
interested. Note that this data.frame will have been overloaded with the
[`slopes`](https://rdrr.io/pkg/marginaleffects/man/slopes.html) class,
and so will come with a special print method. But the underlying columns
will usually include:

- `term`

- `contrast`

- `<type>` (i.e., the name of your `type` string)

- `estimate`

- `std.error`

- `statistic`

- `p.value`

- `s.value`

- `conf.low`

- `conf.high`

## Standard errors

As of **etwfe** v0.7.0, `emfx` computes its standard errors using a fast
and exact analytic path, which yields both greater performance and
precision than the old numeric approach (which was based on the delta
method).

Moreover, we now also report "unconditional" standard errors by default,
which account for sampling variation in the covariate distribution over
which the treatment effects are averaged (see:
[`marginaleffects::vcovUnconditional`](https://rdrr.io/pkg/marginaleffects/man/vcovUnconditional.html)).
Any one-way clustering in the original `etwfe` model (e.g.,
`vcov = ~countyreal`) is carried over automatically.

Exceptions to this rule, where `emfx` instead falls back to the model's
own (conditional) variance-covariance matrix, are as follows:

- Compressed data (`compress = TRUE`), since the compressed groups no
  longer map to the original observations. (Explicitly requesting
  unconditional standard errors for compressed data, e.g.
  `vcov = "unconditional"`, is an error.)

- Multiway or interacted clustering (e.g., `vcov = ~countyreal + year`),
  which `vcovUnconditional` does not support.

A warning is triggered in both cases.

Users can override the default by passing their own `vcov` argument,
e.g. `vcov = TRUE` to recover the model's conditional standard errors
(the default behaviour prior to **etwfe** v0.7.0), or
`vcov = marginaleffects::vcovUnconditional(type = "HC1", cluster = ~id)`
for finer control.

## Performance

Both `etwfe` and `emfx` should be fast, even for large datasets. In
particular, as of **etwfe** v0.7.0, `emfx` is orders of magnitude faster
than it used to be, because it now computes standard errors using exact
analytic Jacobians. (Earlier versions relied on a numerical delta
method, which required estimating two prediction models for *each*
coefficient in the model.)

## Heterogeneous treatment effects

Specifying `etwfe(..., xvar = <xvar>)` will generate interaction effects
for all levels of `<xvar>` as part of the main regression model. The
reason that this is useful (as opposed to a regular, non-interacted
covariate in the formula RHS) is that it allows us to estimate
heterogeneous treatment effects as part of the larger ETWFE framework.
Specifically, we can recover heterogeneous treatment effects for each
level of `<xvar>` by passing the resulting `etwfe` model object on to
`emfx()`.

For example, imagine that we have a categorical variable called "age" in
our dataset, with two distinct levels "adult" and "child". Running
`emfx(etwfe(..., xvar = age))` will tell us how the efficacy of
treatment varies across adults and children. We can then also leverage
the in-built hypothesis testing infrastructure of `marginaleffects` to
test whether the treatment effect is statistically different across
these two age groups; see Examples below. Note the same principles carry
over to categorical variables with multiple levels, or even continuous
variables (although continuous variables are not as well supported yet).

## References

Wong, Jeffrey *et al.* (2021). You Only Compress Once: Optimal Data
Compression for Estimating Linear Models. Working paper (version: March
16, 2021). Available: https://doi.org/10.48550/arXiv.2102.11297

## See also

[marginaleffects::slopes](https://rdrr.io/pkg/marginaleffects/man/slopes.html)
which does the heavily lifting behind the scenes.
[`etwfe`](http://grantmcdermott.com/etwfe/reference/etwfe.md) is the
companion estimating function that should be run before `emfx`.

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
#> Warning: 
#> It is essential to check the order of estimates when specifying hypothesis tests using positional indices like b1, b2, etc. The indices of estimates can change depending on the order of rows in the original dataset, user-supplied arguments, model-fitting package, and version of `marginaleffects`.
#> 
#> It is also good practice to use assertions that ensure the order of estimates is consistent across different runs of the same code. Example:
#> 
#> ```r
#> mod <- lm(mpg ~ am * carb, data = mtcars)
#> 
#> # assertion for safety
#> p <- avg_predictions(mod, by = 'carb')
#> stopifnot(p$carb[1] == 1, p$carb[2] == 2)
#> 
#> # hypothesis test
#> avg_predictions(mod, by = 'carb', hypothesis = 'b1 - b2 = 0')
#> ```
#> 
#> Disable this warning with: `options(marginaleffects_safe = FALSE)`
#>  This warning appears once per session.
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
