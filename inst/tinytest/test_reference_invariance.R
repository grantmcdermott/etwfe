# Test for reference level invariance (Issue #72)
# This test verifies that changing the factor reference level in xvar
# does not affect the estimated treatment effects

set.seed(123)
tol = 1e-6  # Strict tolerance for invariance

data("mpdta", package = "did")

# Create binary grouping variable with two different reference levels
mpdta$gls_refA = factor(ifelse(mpdta$industry <= 4, "A", "B"))  # ref = "A"
mpdta$gls_refB = factor(
  ifelse(mpdta$industry <= 4, "A", "B"),
  levels = c("B", "A")  # ref = "B"
)

# Estimate with reference level "A"
mod_refA = etwfe(
  fml = lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  xvar = gls_refA,
  vcov = ~countyreal
)

# Estimate with reference level "B"
mod_refB = etwfe(
  fml = lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  xvar = gls_refB,
  vcov = ~countyreal
)

# Get simple ATT estimates
att_refA = emfx(mod_refA, type = "simple")
att_refB = emfx(mod_refB, type = "simple")

# Test 1: Estimates should be identical regardless of reference level
expect_equal(
  att_refA$estimate,
  att_refB$estimate,
  tolerance = tol,
  info = "ATT estimates should be invariant to factor reference level (Issue #72)"
)

# Test 2: Standard errors should also be identical
expect_equal(
  att_refA$std.error,
  att_refB$std.error,
  tolerance = tol,
  info = "Standard errors should be invariant to factor reference level (Issue #72)"
)

# Test 3: Test with heterogeneous effects (by_xvar = TRUE)
att_het_refA = emfx(mod_refA, type = "simple", by_xvar = TRUE)
att_het_refB = emfx(mod_refB, type = "simple", by_xvar = TRUE)

# Sort by xvar level to ensure same ordering
att_het_refA = att_het_refA[order(att_het_refA$gls_refA), ]
att_het_refB = att_het_refB[order(att_het_refB$gls_refB), ]

expect_equal(
  att_het_refA$estimate,
  att_het_refB$estimate,
  tolerance = tol,
  info = "Heterogeneous ATT estimates should be invariant to reference level (Issue #72)"
)
