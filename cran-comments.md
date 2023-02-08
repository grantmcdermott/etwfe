## Overview

This minor resubmission drops one of the examples from the help documentation to
bring the run time under 5 seconds, which was triggering a Windows check NOTE on
the previous submission. On my machine, the example run time is now done to < 4
seconds.

My comments on the previous submission contain the key updates:

This `etwfe` 0.3.0 update fixes the CRAN errors in version 0.2.0, which were due 
to some breaking changes in an upstream dependency. In addition, I have added
some new features for estimating heterogeneous treatment effects and improved
performance with large models. A full changelog is provided in the NEWS file.

Many thanks for reviewing.

## Test environments

* Local: Arch Linux
* GitHub Actions (ubuntu-22.04): oldrel-1, release, devel
* GitHub Actions (windows): release
* Github Actions (macOS): release
* Win Builder

## R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTEs.