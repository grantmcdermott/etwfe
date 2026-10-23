# Plot method for emfx objects

Visualize the results of an
[`emfx`](http://grantmcdermott.com/etwfe/reference/emfx.md) call.

## Usage

``` r
# S3 method for class 'emfx'
plot(
  x,
  type = c("pointrange", "errorbar", "ribbon"),
  pch = 16,
  zero = TRUE,
  grid = TRUE,
  ref = -1,
  ...
)
```

## Arguments

- x:

  An `emfx` object.

- type:

  Character. The type of plot display. One of `"pointrange"` (default),
  `"errorbar"`, or `"ribbon"`.

- pch:

  Integer or character. Which plotting character or symbol to use (see
  [`points`](https://rdrr.io/r/graphics/points.html)). Defaults to 16
  (i.e., small solid circle). Ignored if `type = "ribbon"`.

- zero:

  Logical. Should 0-zero line be emphasized? Default is `TRUE`.

- grid:

  Logical. Should a background grid be displayed? Default is `TRUE`.

- ref:

  Integer. Reference line marker for event-study plot. Default is `-1`
  (i.e., the period immediately preceding treatment). To remove
  completely, set to `NA`, `NULL`, or `FALSE`. Only used if the
  underlying object was computed using `emfx(..., type = "event")`.

- ...:

  Additional arguments passed to
  [`tinyplot::tinyplot`](https://grantmcdermott.com/tinyplot/man/tinyplot.html).

## Value

No return value, called for its side effect of producing a plot.

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
