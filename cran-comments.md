## Overview

`etwfe` is a new package implementing the extended two-way fixed effects (ETWFE)
regression procedure proposed by [Wooldridge
(2021)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3906345). The
package itself is fairly simple, since it primarily involves formulae
construction and data preparation. All estimation and computation is passed on
to other packages; specifically `fixest` and `marginaleffects`.

I have added a variety of tests. All results are benchmarked against equivalent
packages in other software.

Many thanks for considering and for the work that the CRAN team does in service
to the wider R community.

## Test environments

* Local: Arch Linux
* GitHub Actions (ubuntu-22.04): oldrel-1, release, devel
* GitHub Actions (windows): release
* Github Actions (macOS): release
* Win Builder

## R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTES.