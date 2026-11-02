# Extended Two-way Fixed Effects (ETWFE)

R package for estimating Extended Two-Way Fixed Effects (ETWFE).

## Motivation

One of the most popular causal inference tools for social scientists is
the two-way fixed effects (TWFE) estimator, especially in the context of
difference-in-differences (DiD) designs. However, it turns out that
vanilla TWFE is often biased in real-life situations, such as under
staggered treatment rollout. Wooldridge
([2023](https://doi.org/10.1093/ectj/utad016),
[2025](https://doi.org/10.1007/s00181-025-02807-z)) points out that this
isn’t the fault of TWFE *per se*, but rather due to the fact that we
haven’t specified an appropriately flexible model. His recommended
solution involves saturating the model with cohort×time interaction
terms, yielding a specification that he calls **extended TWFE (ETWFE)**.
The same approach also extends to non-binary (e.g., continuous)
treatments ([Wooldridge, 2026](https://doi.org/10.2139/ssrn.7530698)).
The Wooldridge solution is intuitive and elegant, but rather tedious and
error prone to code up manually.

The good news is that the **etwfe** R package is here to help. It
provides a set of convenience functions and diagnostic tools that do the
work for you. Please see below for some quickstart examples. Full
documentation is available on the **etwfe**
[homepage](https://grantmcdermott.com/etwfe/).

Python users should take a look at Armand Kapllani’s
[port](https://armandkapllani.github.io/etwfe/#) of this package.

## Installation

You can install **etwfe** from CRAN.

``` r

install.packages("etwfe")
```

Or, you can grab the development version from R-universe.

``` r

install.packages("etwfe", repos = "https://grantmcdermott.r-universe.dev")
```

## Quickstart example

A detailed walkthrough of **etwfe** is provided in the introductory
vignette (available
[online](https://grantmcdermott.com/etwfe/articles/etwfe.html), or by
typing
[`vignette("etwfe")`](https://grantmcdermott.com/etwfe/articles/etwfe.md)
in your R console). But here’s a quickstart example to demonstrate the
basic syntax.

Start by loading the package and some data.

``` r

library(etwfe)

# install.packages("did")
data("mpdta", package = "did")
head(mpdta, 2)
#>     year countyreal     lpop     lemp first.treat treat
#> 866 2003       8001 5.896761 8.461469        2007     1
#> 841 2004       8001 5.896761 8.336870        2007     1
```

**Step 1:** Run
[`etwfe()`](https://grantmcdermott.com/etwfe/reference/etwfe.md) to
estimate a model with full saturated interactions.

``` r

mod = etwfe(
  fml  = lemp ~ lpop, # outcome ~ controls
  tvar = year,        # time variable
  gvar = first.treat, # group variable
  data = mpdta,       # dataset
  vcov = ~countyreal  # vcov adjustment (here: clustered)
)
mod
#> OLS estimation, Dep. Var.: lemp
#> Observations: 2,500
#> Fixed-effects: first.treat: 4,  year: 5
#> Varying slopes: lpop (first.treat): 4,  lpop (year): 5
#> Standard-errors: Clustered (countyreal) 
#>                                               Estimate Std. Error   t value   Pr(>|t|)    
#> .Dtreat:first.treat::2004:year::2004         -0.021248   0.021728 -0.977890 3.2860e-01    
#> .Dtreat:first.treat::2004:year::2005         -0.081850   0.027375 -2.989963 2.9279e-03 ** 
#> .Dtreat:first.treat::2004:year::2006         -0.137870   0.030795 -4.477097 9.3851e-06 ***
#> .Dtreat:first.treat::2004:year::2007         -0.109539   0.032322 -3.389024 7.5694e-04 ***
#> .Dtreat:first.treat::2006:year::2006          0.002537   0.018883  0.134344 8.9318e-01    
#> .Dtreat:first.treat::2006:year::2007         -0.045093   0.021987 -2.050907 4.0798e-02 *  
#> .Dtreat:first.treat::2007:year::2007         -0.045955   0.017975 -2.556568 1.0866e-02 *  
#> .Dtreat:first.treat::2004:year::2004:lpop_dm  0.004628   0.017584  0.263184 7.9252e-01    
#> .Dtreat:first.treat::2004:year::2005:lpop_dm  0.025113   0.017904  1.402661 1.6134e-01    
#> .Dtreat:first.treat::2004:year::2006:lpop_dm  0.050735   0.021070  2.407884 1.6407e-02 *  
#> .Dtreat:first.treat::2004:year::2007:lpop_dm  0.011250   0.026617  0.422648 6.7273e-01    
#> .Dtreat:first.treat::2006:year::2006:lpop_dm  0.038935   0.016472  2.363731 1.8474e-02 *  
#> .Dtreat:first.treat::2006:year::2007:lpop_dm  0.038060   0.022477  1.693276 9.1027e-02 .  
#> .Dtreat:first.treat::2007:year::2007:lpop_dm -0.019835   0.016198 -1.224528 2.2133e-01    
#> ... 10 variables were removed because of collinearity
#> (.Dtreat:first.treat::2006:year::2004, .Dtreat:first.treat::2006:year::2005 and 8 others
#> [full set in $collin.var])
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE: 0.537131     Adj. R2: 0.87167 
#>                  Within R2: 8.449e-4
```

**Step 2:** Pass to
[`emfx()`](https://grantmcdermott.com/etwfe/reference/emfx.md) to
recover the ATTs of interest. In this case, an event-study example.

``` r

emfx(mod, type = "event")
#> 
#>  event Estimate Std. Error     z Pr(>|z|)    S   2.5 %  97.5 %
#>      0  -0.0332     0.0135 -2.46   0.0141  6.2 -0.0597 -0.0067
#>      1  -0.0573     0.0180 -3.19   0.0014  9.5 -0.0925 -0.0222
#>      2  -0.1379     0.0339 -4.07   <0.001 14.4 -0.2042 -0.0715
#>      3  -0.1095     0.0323 -3.39   <0.001 10.5 -0.1728 -0.0463
#> 
#> Term: .Dtreat
#> Type: response
#> Comparison: TRUE - FALSE
```

## Acknowledgements

- [Jeffrey
  Wooldridge](https://econ.msu.edu/about/directory/Wooldridge-Jeffrey)
  for the underlying ETWFE theory
  ([1](https://doi.org/10.1007/s00181-025-02807-z),
  [2](https://doi.org/10.1093/ectj/utad016),
  [3](https://doi.org/10.2139/ssrn.7530698)).
- [Laurent Bergé](https://sites.google.com/site/laurentrberge/)
  ([**fixest**](https://lrberge.github.io/fixest/)) and [Vincent
  Arel-Bundock](https://arelbundock.com/)
  ([**marginaleffects**](https://marginaleffects.com/)) for maintaining
  the two wonderful R packages that do most of the heavy lifting under
  the hood here.
- [Fernando Rios-Avila](https://friosavila.github.io/) for the
  [`jwdid`](https://ideas.repec.org/c/boc/bocode/s459114.html) Stata
  module, which has provided a welcome foil for unit testing and whose
  elegant design helped inform my own choices for this R equivalent.
