# Test for reference level invariance (Issue #72)
# This test verifies that changing the factor reference level in xvar
# does not affect the estimated treatment effects

set.seed(123)
tol = 1e-6  # Strict tolerance for invariance

data("mpdta", package = "did")

# Create factor variables with different reference levels
gls1 <- c('IL' = 17, 'IN' = 18, 'MI' = 26, 'MN' = 27, 'NY' = 36, 'OH' = 39, 'PA' = 42, 'WI' = 55)
mpdta$gls1 <- substr(mpdta$countyreal, 1, 2) %in% gls1
mpdta$gls4 <- as.factor(ifelse(mpdta$gls1, 'gls', 'other'))
mpdta$gls5 <- relevel(mpdta$gls4, ref = 'other')

# Estimate with reference level "gls"
mod_gls4 = etwfe(
  fml = lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  xvar = gls4,
  vcov = ~countyreal
)

# Estimate with reference level "other"
mod_gls5 = etwfe(
  fml = lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  xvar = gls5,
  vcov = ~countyreal
)

# Get simple ATT estimates
att_gls4 = emfx(mod_gls4, type = "simple")
att_gls5 = emfx(mod_gls5, type = "simple")

# Test 1: Estimates should be identical regardless of reference level
expect_equal(
  att_gls4$estimate,
  att_gls5$estimate,
  tolerance = tol,
  info = "ATT estimates should be invariant to factor reference level (Issue #72)"
)

# Test 2: Standard errors should also be identical
expect_equal(
  att_gls4$std.error,
  att_gls5$std.error,
  tolerance = tol,
  info = "Standard errors should be invariant to factor reference level (Issue #72)"
)

# Test 3: Test with heterogeneous effects (by_xvar = TRUE)
att_het_gls4 = emfx(mod_gls4, type = "simple", by_xvar = TRUE)
att_het_gls5 = emfx(mod_gls5, type = "simple", by_xvar = TRUE)

# Sort by xvar level to ensure same ordering
att_het_gls4 = att_het_gls4[order(att_het_gls4$gls4), ]
att_het_gls5 = att_het_gls5[order(att_het_gls5$gls5), ]

expect_equal(
  att_het_gls4$estimate,
  att_het_gls5$estimate,
  tolerance = tol,
  info = "Heterogeneous ATT estimates should be invariant to reference level (Issue #72)"
)
