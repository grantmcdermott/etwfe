# Test for reference level invariance (Issue #72)
# This test verifies that changing the factor reference level in xvar
# does not affect the estimated treatment effects

set.seed(123)
tol = 1e-6  # Strict tolerance for invariance

data("mpdta", package = "did")

# Create factor variables with different reference levels
gls1 = c('IL' = 17, 'IN' = 18, 'MI' = 26, 'MN' = 27, 'NY' = 36, 'OH' = 39, 'PA' = 42, 'WI' = 55)
mpdta$gls1 = substr(mpdta$countyreal, 1, 2) %in% gls1
mpdta$gls4 = as.factor(ifelse(mpdta$gls1, 'gls', 'other'))  # ref = 'gls' (alphabetical)
mpdta$gls5 = relevel(mpdta$gls4, ref = 'other')  # ref = 'other'

# For matching
gls_ord = c("gls", "other")

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

att_gls4 = att_gls4[gls_ord, ]
att_gls5 = att_gls5[gls_ord, ]

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
att_het_gls4 = att_het_gls4[gls_ord, ]
att_het_gls5 = att_het_gls5[gls_ord, ]

expect_equal(
  att_het_gls4$estimate,
  att_het_gls5$estimate,
  tolerance = tol,
  info = "Heterogeneous ATT estimates should be invariant to reference level (Issue #72)"
)

# Test 4: Simulation - verify correct recovery of known treatment effects
set.seed(42)
N = 500
T = 5
sim = data.table::CJ(id = 1:N, time = 1:T)
sim[, cohort := sample(c(0, 3, 4, 5), 1, prob = c(0.4, 0.2, 0.2, 0.2)), by = id]
sim[, x := sample(0:1, 1, prob = if (cohort[1] == 0) c(0.3, 0.7) else c(0.7, 0.3)), by = id]
sim[, xf := factor(ifelse(x == 1, "high", "low"))]
sim[, xf_flip := relevel(xf, ref = "low")]
sim[, treat := as.integer(cohort > 0 & time >= cohort)]
# True ATT: 2 for low (x=0), 3 for high (x=1)
sim[, y := 0.5 * id / N + 0.3 * time + treat * (2 + x) + rnorm(.N, sd = 0.5)]

mod_sim = etwfe(y ~ 1, tvar = time, gvar = cohort, data = sim, xvar = xf)
att_sim = emfx(mod_sim, type = "simple", by_xvar = TRUE)

mod_sim_flip = etwfe(y ~ 1, tvar = time, gvar = cohort, data = sim, xvar = xf_flip)
att_sim_flip = emfx(mod_sim_flip, type = "simple", by_xvar = TRUE)

xf_ord = c("high", "low")

expect_equal(
  att_sim$estimate[order(match(att_sim$xf, xf_ord))],
  att_sim_flip$estimate[order(match(att_sim_flip$xf_flip, xf_ord))],
  tolerance = tol,
  info = "Simulation: estimates should be reference-invariant"
)

expect_equal(
  att_sim$estimate[order(match(att_sim$xf, xf_ord))],
  c(3, 2),
  tolerance = 0.15,
  info = "Simulation: should recover true heterogeneous ATTs (high=3, low=2)"
)
