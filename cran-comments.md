## Resubmission

This is a resubmission. In this version I have:

* Converted the DESCRIPTION title field to title case.
* Added <doi:...> citation links to the DESCRIPTION description field.

## Previous submission(s)

* Converted the DESCRIPTION title to title case, as well as shortened it.
* Updated the Date field in the DESCRIPTION file.
* Used the CRAN MIT LICENSE file template, with appropriate reference from the DESCRIPTION file.
* Converted any "http" prefixes to "https" and included trailing URL slashes where necessary.
* Fixed some typos and minor cosmetic changes in the vignette and reference manual.
* All core estimation code and tests remain unchanged.

## Overview

`etwfe` is a new package implementing the extended two-way fixed effects (ETWFE)
regression procedure proposed by [Wooldridge
(2021)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3906345). The
package itself is fairly simple, since it primarily involves formulae
construction and data preparation. All estimation and computation is passed on
to other packages; specifically `fixest` and `marginaleffects`.

I have added a variety of tests. All results are benchmarked against equivalent
packages in other software.

Many thanks for considering `etwfe` and for the work that the CRAN team does in
service to the wider R community.

## Test environments

* Local: Arch Linux
* GitHub Actions (ubuntu-22.04): oldrel-1, release, devel
* GitHub Actions (windows): release
* Github Actions (macOS): release
* Win Builder

## R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTES.