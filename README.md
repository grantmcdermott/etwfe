
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Extended two-way fixed effects (ETWFE)

<!-- badges: start -->

[![R-CMD-check](https://github.com/grantmcdermott/etwfe/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/grantmcdermott/etwfe/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of **etwfe** is to estimate extended (Mundlak) two-way fixed
effects *a la* [Wooldridge
(2021)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3906345).
Briefly, Wooldridge proposes a set of saturated interaction effects to
overcome the potential bias problems of vanilla TWFE in
difference-in-differences designs. The Wooldridge solution is intuitive
and elegant, but rather tedious and error prone to code up manually. The
**etwfe** package aims to simplify the process by providing convenience
functions that do the work for you.

## Installation

You can install the development version of **etwfe** from
[GitHub](https://github.com/):

``` r
# install.packages("remotes")
remotes::install_github("grantmcdermott/etwfe")
```

## Quickstart example

A detailed walkthrough of the package is provided in the introductory
vignette. See `vignette("etwfe")`. Here’s a quickstart example to
demonstrate the basic syntax.

``` r
library(etwfe)

# install.packages("did")
data("mpdta", package = "did")
head(mpdta)
#>     year countyreal     lpop     lemp first.treat treat
#> 866 2003       8001 5.896761 8.461469        2007     1
#> 841 2004       8001 5.896761 8.336870        2007     1
#> 842 2005       8001 5.896761 8.340217        2007     1
#> 819 2006       8001 5.896761 8.378161        2007     1
#> 827 2007       8001 5.896761 8.487352        2007     1
#> 937 2003       8019 2.232377 4.997212        2007     1

# Estimate the model
mod =
  etwfe(
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
#> Varying slopes: lpop (first.treat: 4),  lpop (year: 5)
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
#> ... 10 variables were removed because of collinearity (.Dtreat:first.treat::2006:year::2004, .Dtreat:first.treat::2006:year::2005 and 8 others [full set in $collin.var])
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE: 0.537131     Adj. R2: 0.87167 
#>                  Within R2: 8.449e-4

# Event-study treatment effects
emfx(mod, type = "event") |>
  summary()
#>      type               term             contrast             event         estimate       
#>  Length:4           Length:4           Length:4           Min.   :0.00   Min.   :-0.13787  
#>  Class :character   Class :character   Class :character   1st Qu.:0.75   1st Qu.:-0.11662  
#>  Mode  :character   Mode  :character   Mode  :character   Median :1.50   Median :-0.08344  
#>                                                           Mean   :1.50   Mean   :-0.08449  
#>                                                           3rd Qu.:2.25   3rd Qu.:-0.05131  
#>                                                           Max.   :3.00   Max.   :-0.03321  
#>    std.error         statistic         p.value             conf.low          conf.high       
#>  Min.   :0.01337   Min.   :-4.477   Min.   :7.566e-06   Min.   :-0.19823   Min.   :-0.07751  
#>  1st Qu.:0.01621   1st Qu.:-3.661   1st Qu.:5.280e-04   1st Qu.:-0.17922   1st Qu.:-0.05402  
#>  Median :0.02397   Median :-3.366   Median :7.649e-04   Median :-0.13193   Median :-0.03496  
#>  Mean   :0.02341   Mean   :-3.423   Mean   :3.629e-03   Mean   :-0.13037   Mean   :-0.03861  
#>  3rd Qu.:0.03118   3rd Qu.:-3.128   3rd Qu.:3.866e-03   3rd Qu.:-0.08308   3rd Qu.:-0.01955  
#>  Max.   :0.03232   Max.   :-2.484   Max.   :1.298e-02   Max.   :-0.05941   Max.   :-0.00701
```

## Acknowledgements

- [Jeffrey Wooldridge](https://twitter.com/jmwooldridge) for the
  [underlying
  theory](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3906345)
  behind ETWFE.
- [Laurent Bergé](https://twitter.com/lrberge)
  ([**fixest**](https://lrberge.github.io/fixest/)) and [Vincent
  Arel-Bundock](https://twitter.com/VincentAB)
  ([**marginaleffects**](https://vincentarelbundock.github.io/marginaleffects))
  for maintaining the two wonderful R packages that do most of the heavy
  lifting under the hood here.
- [Fernando Rios-Avila](https://twitter.com/friosavila) for the
  [`JWDID`](https://ideas.repec.org/c/boc/bocode/s459114.html) Stata
  module, which has provided a welcome foil for unit testing and whose
  elegant design helped inform my own choices for this R equivalent.
