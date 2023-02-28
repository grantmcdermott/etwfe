This is a resubmission that wraps Examples in `\dontrun` to avoid the NOTE
triggered by my previous submission (23 Feb), regarding examples taking more
than 5 seconds on Windows. The key features of this `etwfe` update are otherwise
unchanged and remain as per the below.

## Overview

`etwfe` 0.3.1 is a patch release that ensures the package internals reflect some
changes introduced by an upstream dependency.

## Test environments

* Local: Arch Linux
* GitHub Actions (ubuntu-22.04): oldrel-1, release, devel
* GitHub Actions (windows): release
* Github Actions (macOS): release
* Win Builder

## R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTEs.