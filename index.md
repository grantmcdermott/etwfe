# Extended Two-way Fixed Effects (ETWFE)

The goal of **etwfe** is to estimate extended two-way fixed effects *a
la* Wooldridge ([2023](https://doi.org/10.1093/ectj/utad016),
[2025](https://doi.org/10.1007/s00181-025-02807-z)). Briefly, Wooldridge
proposes a set of saturated interaction effects to overcome the
potential bias problems of vanilla TWFE in difference-in-differences
designs. The Wooldridge solution is intuitive and elegant, but rather
tedious and error prone to code up manually. The **etwfe** package aims
to simplify the process by providing convenience functions that do the
work for you.

Documentation is available on the package
[homepage](https://grantmcdermott.com/etwfe/).

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
[`vignette("etwfe")`](http://grantmcdermott.com/etwfe/articles/etwfe.md)
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
[`etwfe()`](http://grantmcdermott.com/etwfe/reference/etwfe.md) to
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
#> Standard-errors: Clustered (countyreal) 
#>                         Estimate Std. Error   t value  Pr(>|t|)    
#> lpop                    1.065461   0.021824 48.821102 < 2.2e-16 ***
#> first.treat::2004:lpop  0.050982   0.037756  1.350320  0.177525    
#> first.treat::2006:lpop -0.041095   0.047390 -0.867183  0.386259    
#> first.treat::2007:lpop  0.055518   0.039212  1.415838  0.157447    
#> year::2004:lpop         0.011014   0.007554  1.458043  0.145458    
#> year::2005:lpop         0.020733   0.008104  2.558268  0.010814 *  
#> year::2006:lpop         0.010535   0.010816  0.974084  0.330487    
#> year::2007:lpop         0.020921   0.011808  1.771708  0.077053 .  
#> ... 14 coefficients remaining (display them with summary() or use argument n)
#> ... 10 variables were removed because of collinearity
#> (.Dtreat:first.treat::2006:year::2004, .Dtreat:first.treat::2006:year::2005 and 8 others
#> [full set in $collin.var])
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> RMSE: 0.537131     Adj. R2: 0.871722
#>                  Within R2: 0.869464
```

**Step 2:** Pass to
[`emfx()`](http://grantmcdermott.com/etwfe/reference/emfx.md) to recover
the ATTs of interest. In this case, an event-study example.

``` r
emfx(mod, type = "event")
#> 
#>  event Estimate Std. Error     z Pr(>|z|)    S   2.5 %   97.5 %
#>      0  -0.0332     0.0134 -2.48    0.013  6.3 -0.0594 -0.00702
#>      1  -0.0573     0.0171 -3.34   <0.001 10.2 -0.0910 -0.02373
#>      2  -0.1379     0.0308 -4.48   <0.001 17.0 -0.1982 -0.07753
#>      3  -0.1095     0.0323 -3.39   <0.001 10.5 -0.1729 -0.04620
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
  [2](https://doi.org/10.1093/ectj/utad016)).
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
