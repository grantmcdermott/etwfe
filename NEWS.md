# etwfe 0.2.9005 (development version)

## New features and enhancements

#### etwfe

- Support for heterogeneous treatment effects via the new `xvar` interacted
covariate argument (#16, thanks @frederickluser). Also extends to `emfx`.

- Users can now specify no covariates with a 1 on the fml RHS, e.g, 
`etwfe(y ~ 1, ...)`. This provides a second way of doing this, alongside the 
existing 0 option, e.g. `etwfe(y ~ 0, ...)` 

#### emfx

- A new section on Performance tips in the `emfx` help documentation coincides
with two new supported arguments:
  
  1. The `collapse` argument can substantially reduce estimation times for large
  datasets (#19. thanks @frederickluser). This performance boost does trade off
  against a loss in estimate accuracy. But testing suggests that the difference
  is relatively minor for typical use cases (i.e., results are equivalent up to 
  the 1st or 2nd significant decimal place, and sometimes even better). Please 
  let us know if you find edge cases where this is not true.
  
  2. An even more dramatic performance gain (>100 speedup for large datasets) is
  possible with `emfx(..., vcov = FALSE)`. The trade-off in this case is that we
  don't get standard errors. However, the aforementioned Performance tips
  section provides more practical guidance on how to combine
  `emfx(..., vcov = FALSE, collapse = TRUE)`.

## Bug fixes

- Internal code and tests have been updated to account for some upstream
breaking changes in **marginaleffects** 0.9.0 (#20, thanks @vincentarelbundock).

# etwfe 0.2.0

## Bug fixes and breaking changes

- The `.Dtreat` indicator variable created during the `etwfe` call is now
logical instead of integer (#14). This fix yields slightly different effect
sizes for `emfx` output when applied to non-linear model families (e.g.,
`etwfe(..., family = "poisson")`. The reason is that we are now implicitly
calling `marginaleffects::comparisons` under the hood rather than
`marginaleffects::marginaleffects`. Note that the main `etwfe` coefficients (for
any family) are unaffected, and the same is also true for `emfx` when applied to
a linear model (i.e., the default).

- The (optional) `ivar` argument of `etwfe()` has been moved down the argument 
order list from second position to fifth (i.e., after the `data` argument). This
means that the four required arguments of function now occupy the top positions,
which could enable shorter, unnamed notation like
`etwfe(y ~ x, year, cohort, dat)`.

## New features and enhancements

- `emfx` now allows (time-invariant) interacted control variables on the fml RHS.

- `emfx` now has a `post_only` logical argument, which may be useful for plotting
aesthetics (but not inference). See the example in the introductory vignette.
- Various improvements to the documentation (restructuring, fixed typos, etc.)

# etwfe 0.1.0

* Initial release. 
