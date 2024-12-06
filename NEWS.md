# etwfe 0.4.0.99 (development version)

## New features

- New `emfx` arguments:
  - `emfx(..., predict = c("response", "link"))`, where the latter
allows for obtaining the linear prediction for non-linear models. Internally
passed as `marginaleffects::slopes(..., type = predict)`, thus avoiding a clash
with the topline `emfx(..., type = <aggregration_type>)` argument. (#49)
- `emfx(..., lean = TRUE)` ensures a light return object by default, by
stripping away data-heavy attributes that are unlikely to be needed afterwards.
(#51)

## Documentation

- Various documentation improvements, including the addition of a "never"
treated control group example in the vignette and fixing some confusing typos
(e.g., refering to wrong default arguments).

# etwfe 0.4.0

## Bug fixes

- Fix ATT calculation for the never-treated case (i..e, `cgroup = "never`) due
to incorrect subsetting prior to recovering the marginal effects. Thanks to
@paulofelipe for reporting (#37).
- Avoid (where possible) or error out if user supplies reserved "group" variable
in formula (#41).

## Documentation

- Fix missing autolinks in documentation due to markdown formatting (#44
@etiennebacher).

# etwfe 0.3.5

## Internal

- Update tests to match upstream changes to **fixest**.
- Update maintainer email address.

# etwfe 0.3.4

## Internal

- Update tests to match upstream changes to **marginaleffects**
(#36 @vincentarelbundock).


# etwfe 0.3.3

## Internal

- Rejigged some internal tests following upstream changes to **marginaleffects**
(#35 @vincentarelbundock).


# etwfe 0.3.2

## Bug fixes

- Fixed internal centering procedure and handling of multiple covariate levels
(#30, #31). These fixes should have no impact on the main ATT estimates (i.e.,
typical use of the package). But it may lead to differences in the heterogeneous
ATTs---i.e., via the `xvar` arg---which were incorrectly estimated in some
cases. Thanks to @PhilipCarthy for flagging and to @frederickluser for helpful
discussions

- Fixed internal and upstream bug which was causing model offsets to error (#28,
thanks @mariofiorini for the initial report and several others for helpful
discussion). Note that this fix requires **insight** >= 0.19.1.8, which is the
development version at the time of writing. More information available here:
https://github.com/easystats/insight/pull/759

# etwfe 0.3.1

## Internal

- Minor updates to internal code and some unit tests to match forthcoming
updates to 
**marginaleffects** 0.10.0. The latter update also brings some notable
performance improvements to `emfx()`. 

## Other

- Some documentation improvements.
- The Examples have been wrapped in `\dontrun` to avoid triggering CRAN NOTEs on
Windows for exceeding 5 seconds execution time. Note that the package homepage
still runs these Examples if users want to inspect the output online.

# etwfe 0.3.0

## New features and enhancements

- Support for estimating heterogeneous treatment effects via the new 
`etwfe(..., xvar = <xvar>` argument (#16, thanks to @frederickluser). 
Automatically extends to `emfx()` via the latter's `by_xvar` argument (#21).
More details are provided in the dedicated "Heterogeneous treatment effects"
section of the vignette and help documentation

- The new `emfx(..., collapse = TRUE)` argument can substantially reduce
estimation times for large datasets (#19, thanks @frederickluser). This
performance boost does trade off against a loss in estimate accuracy. But
testing suggests that the difference is relatively minor for typical use cases
(i.e., results are equivalent up to the 1st or 2nd significant decimal place,
and sometimes even better). Please let us know if you find edge cases where this
is not true. More details are available in the dedicated "Performance tips" 
section of the vignette and help documentation, including advice for combining
collapsing with `emfx(..., vcov = FALSE)` (which yields an even more dramatic
speed boost but at a cost of not reporting any standard errors).

- Users can now use a 1 on the fml RHS to indicate that there are no control variables
as part of the `etwfe` call, e.g. `etwfe(y ~ 1, ...)`. This provides a second 
way of indicating no controls, alongside the existing 0 option, e.g. `etwfe(y ~ 0, ...)` 

## Bug fixes

- Internal code and tests have been updated to account for some upstream
breaking changes in **marginaleffects** 0.9.0 (#20, thanks @vincentarelbundock).
From the user side, the most notable changes are that we no longer have to call
`summary()` on `emfx` objects for pretty printing, and that the (former) "dydx"
column of the resulting object is now named "estimate". These changes are
reflected in the updated documentation.

## Other

- Various documentation improvements. For example, the aforementioned sections
on Heterogeneous TEs and Performance tips. I have also removed some warnings
about the use of time-varying controls (#17). In truth, I can't quite recall why
I included these warnings in the first place and testing confirms that it does
not appear to pose a problem for the ETWFE framework. Thanks to Felix Pretis for
prompting me to revisit this implicit restriction, including forwarding some
relevant correspondence with Prof. Wooldridge.

- **data.table** is added to Imports and thus becomes a direct dependency. It
was already an indirect dependency through **marginaleffects**.

- It's now possible to install the development version of the package from
R-universe. Details are provided in the README.

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
