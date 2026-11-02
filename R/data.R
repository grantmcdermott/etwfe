#' Walmart openings and county retail employment
#'
#' @md
#' @description
#' A balanced county-level panel of Walmart store openings and retail
#' employment in the United States, 1977--1999. No county in the panel housed a
#' Walmart before 1986, and openings are staggered thereafter, so that the data
#' are a natural testbed for (non-binary) staggered difference-in-differences.
#' This is the dataset used in the empirical application of Wooldridge (2026).
#'
#' @format A data frame with 29,624 rows (1,288 counties x 23 years) and 5
#'   variables:
#' \describe{
#'   \item{fips}{County FIPS code.}
#'   \item{year}{Year (1977--1999).}
#'   \item{cohort}{Year in which the county's first Walmart opened (1986--1999),
#'   or 0 if the county did not have a Walmart by 1999 (never treated).}
#'   \item{n_open}{Number of Walmart stores open in the county in that year.}
#'   \item{log_retail_emp}{Log of county retail employment (rounded to four
#'   decimal places).}
#' }
#'
#' @details
#' The underlying data were constructed by Brown and Butts (2025), with the
#' sample of counties following the selection criteria of Basker (2005), and
#' were subsequently used by Wooldridge (2025, 2026). We are grateful to the
#' original authors for permission to redistribute them here.
#'
#' Please note that this is a _subset_ of the original data. It retains only
#' the five variables needed to illustrate the **etwfe** functionality, whereas
#' the original contains many more (e.g., employment in other sectors and
#' pre-treatment county characteristics). The outcome variable has also been
#' rounded to reduce file size, although this does not affect results at the
#' precision reported by Wooldridge (2026). Users interested in the full dataset
#' should consult the original sources.
#'
#' @source Subset of the data constructed by Brown and Butts (2025), as
#'   distributed with the replication files for Wooldridge (2026). See the
#'   References below.
#'
#' @references
#' Basker, Emek (2005). \cite{Job Creation or Destruction? Labor Market Effects
#' of Wal-Mart Expansion}. Review of Economics and Statistics, 87(1), 174-183.
#' Available: https://doi.org/10.1162/0034653053327568
#'
#' Brown, Nicholas and Kyle Butts (2025). \cite{Dynamic Treatment Effect
#' Estimation with Interactive Fixed Effects and Short Panels}. Journal of
#' Econometrics, 250, 106013. Available:
#' https://doi.org/10.1016/j.jeconom.2025.106013
#'
#' Wooldridge, Jeffrey M. (2025). \cite{Two-way fixed effects, the two-way
#' Mundlak regression, and difference-in-differences estimators}. Empirical
#' Economics, 69, 2545-2587. Available:
#' https://doi.org/10.1007/s00181-025-02807-z
#'
#' Wooldridge, Jeffrey M. (2026). \cite{A Heterogeneous Slopes Approach to
#' Difference-in-Differences with Non-Binary Treatments}. Working paper.
#' Available: https://doi.org/10.2139/ssrn.7530698
#'
#' @examples
#' data("walmart", package = "etwfe")
#'
#' # Effect of each additional Walmart store on (log) retail employment, cf.
#' # Wooldridge (2026, Table 7.1)
#' mod = etwfe(
#'   log_retail_emp ~ 0, tvar = year, gvar = cohort, data = walmart,
#'   ivar = fips, vcov = ~fips,
#'   wvar = n_open
#'   )
#' emfx(mod)
"walmart"
