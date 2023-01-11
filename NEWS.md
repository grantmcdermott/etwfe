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

## Improvements

- `emfx` now allows (time-invariant) interacted control variables on the fml RHS.

- `emfx` now has a `post_only` logical argument, which may be useful for plotting
aesthetics (but not inference). See the example in the introductory vignette.
- Various improvements to the documentation (restructuring, fixed typos, etc.)

# etwfe 0.1.0

* Initial release. 
