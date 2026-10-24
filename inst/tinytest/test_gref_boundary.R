# Boundary-cohort tests for `gref` (reference cohort) auto-selection.
#
# Two failure modes, both fixed/flagged by this change:
#   (A) a cohort whose onset is beyond the observed range of `tvar` used to
#       unconditionally win the `gref` selection, displacing a genuine
#       never-treated group and corrupting every reported effect.
#   (B) a cohort with no pre-treatment observations at all (onset at or before
#       its own earliest observed period) is fitted and pooled into aggregated
#       ATTs with no indication that it isn't identified like every other
#       cohort.
#
# Both are demonstrated by relabelling counties that are genuinely
# never-treated in `mpdta` (etwfe's own example dataset), so their true
# counterfactual trend is, by construction, identical to the real control
# group -- any nonzero "effect" etwfe reports for them is purely an artefact
# of the boundary timing, not a real effect.

data("mpdta", package = "did")
set.seed(1234)

m_clean <- etwfe(lemp ~ lpop, tvar = year, gvar = first.treat, data = mpdta, cgroup = "notyet")
att_clean <- emfx(m_clean, type = "simple", vcov = FALSE)$estimate

expect_equal(
  attr(m_clean, "etwfe")$gref, 0,
  info = "clean mpdta: the never-treated group (0) should be the reference"
)

## ---- Case A: onset beyond the observed panel (max(year) = 2007) ----------

never_ids <- unique(mpdta$countyreal[mpdta$first.treat == 0])
flipA <- sample(never_ids, 15)
mpdta_A <- mpdta
mpdta_A$first.treat[mpdta_A$countyreal %in% flipA] <- 2009L # beyond max(year) = 2007

expect_warning(
  m_A <- etwfe(lemp ~ lpop, tvar = year, gvar = first.treat, data = mpdta_A, cgroup = "notyet"),
  pattern = "beyond the observed range",
  info = "a cohort with onset beyond max(tvar) should trigger a gref warning"
)

expect_equal(
  attr(m_A, "etwfe")$gref, 0,
  info = "the genuine never-treated group should still be selected as gref, not the beyond-range cohort"
)

att_A <- emfx(m_A, type = "simple", vcov = FALSE)$estimate
expect_equal(
  att_A, att_clean,
  tolerance = 1e-8,
  info = paste(
    "the relabelled counties never contribute a single .Dtreat==TRUE row, so the pooled ATT",
    "should be numerically IDENTICAL to the clean baseline once gref selection is fixed",
    "(pre-fix this used to differ substantially, e.g. -0.0126 vs -0.0506 in one draw)"
  )
)

## ---- Case B: onset at the panel's first period (zero pre-treatment obs) --

flipB <- sample(setdiff(never_ids, flipA), 15)
mpdta_B <- mpdta
mpdta_B$first.treat[mpdta_B$countyreal %in% flipB] <- 2003L # = min(year); no pre-period

expect_warning(
  m_B <- etwfe(lemp ~ lpop, tvar = year, gvar = first.treat, data = mpdta_B, cgroup = "notyet"),
  pattern = "no pre-treatment observations",
  info = "a cohort with onset at/before min(tvar) should trigger a no-pre-period warning"
)

expect_equal(
  attr(m_B, "etwfe")$gref, 0,
  info = "a no-pre-period cohort should NOT affect gref selection (only Case A does)"
)

## dropping (rather than relabelling) the 15 counties should reproduce the clean baseline
## fairly closely, confirming the warned-about cohort is exactly what drives any shift in
## emfx(type = "simple") once it's included
m_B_drop <- etwfe(
  lemp ~ lpop, tvar = year, gvar = first.treat,
  data = mpdta[!mpdta$countyreal %in% flipB, ], cgroup = "notyet"
)
att_B_drop <- emfx(m_B_drop, type = "simple", vcov = FALSE)$estimate
expect_equal(
  att_B_drop, att_clean,
  tolerance = 0.02,
  info = "dropping the no-pre-period cohort should reproduce the clean baseline ATT closely"
)

## ---- Simulated DGP: confirm the fix actually recovers the true effect --------------------
## (Case A can silently bias the estimate, not just move a real-data point estimate around by
## an amount that could be dismissed as noise -- this checks recovery against a known truth.)

n_per_cohort <- 40L
periods <- 2001:2010
true_effect <- 0.5

make_unit <- function(id, g) {
  eps <- rnorm(length(periods), 0, 1)
  base <- 5 + 0.02 * (periods - min(periods)) + eps
  treated <- if (g == 0) rep(0L, length(periods)) else as.integer(periods >= g)
  data.frame(id = id, year = periods, g = g, y = base + true_effect * treated)
}

set.seed(99)
ids <- 1L
sim_rows <- list()
for (i in seq_len(n_per_cohort)) {
  sim_rows[[length(sim_rows) + 1L]] <- make_unit(ids, 0L)
  ids <- ids + 1L
} # never-treated
for (i in seq_len(n_per_cohort)) {
  sim_rows[[length(sim_rows) + 1L]] <- make_unit(ids, 2005L)
  ids <- ids + 1L
} # clean interior cohort
for (i in seq_len(n_per_cohort)) {
  sim_rows[[length(sim_rows) + 1L]] <- make_unit(ids, 2015L)
  ids <- ids + 1L
} # onset beyond max(year) = 2010; true DGP identical to the g=0 units

sim <- do.call(rbind, sim_rows)

expect_warning(
  m_sim <- etwfe(y ~ 0, tvar = year, gvar = g, data = sim, cgroup = "notyet"),
  pattern = "beyond the observed range",
  info = "simulated onset-beyond-panel cohort should trigger the same warning"
)
att_sim <- emfx(m_sim, type = "simple", vcov = FALSE)$estimate
expect_true(
  abs(att_sim - true_effect) < 0.15, # cf. the 0.15 simulation-recovery tolerance used in test_reference_invariance.R
  info = paste0(
    "with gref selection fixed, the estimated ATT (", round(att_sim, 4), ") should recover the ",
    "true effect (", true_effect, ") to within simulation noise, despite the onset-beyond-panel ",
    "cohort being present in the data"
  )
)
