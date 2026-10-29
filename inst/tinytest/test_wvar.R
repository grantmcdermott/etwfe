set.seed(123)
tol = 1e-6

# Simulated staggered panel with a time-varying dose that is correlated with
# the unit effect, and slopes that vary by cohort and event time
N = 300; T = 8
u = data.frame(id = 1:N, g = sample(c(0, 4, 6), N, TRUE), x = rnorm(N), c = rnorm(N))
u$r = ifelse(u$g == 0, 0, rpois(N, exp(0.5 + 0.5 * u$c)) + 1)
dat = merge(u, data.frame(t = 1:T))
dat$post = dat$t >= dat$g & dat$g > 0
dat$w = dat$post * (dat$r + (dat$t - dat$g > 1)) # dose can change post-treatment
tau = with(dat, 0.1 + 0.05 * (t - dat$g) + 0.1 * (g == 6))
dat$y0 = with(dat, 2 * c + 0.2 * t + w * tau) # noise-free
dat$y = dat$y0 + rnorm(nrow(dat), sd = 0.5)

# Exact recovery of the aggregated slopes (noise-free outcome) ----

m = etwfe(y0 ~ 0, tvar = t, gvar = g, ivar = id, wvar = w, data = dat)
expect_equal(emfx(m, vcov = FALSE)$estimate, mean(tau[dat$post]), tolerance = tol)
ev = emfx(m, "event", vcov = FALSE)
expect_equal(
  ev$estimate,
  as.numeric(tapply(tau[dat$post], (dat$t - dat$g)[dat$post], mean)),
  tolerance = tol
)
expect_equal(attr(m, "etwfe")[["wvar"]], "w")

# Cohort trends: exact recovery with trending cohorts ----

dat$y0_tr = dat$y0 + 0.3 * (dat$g == 4) * dat$t - 0.2 * (dat$g == 6) * dat$t
mt = etwfe(y0_tr ~ 0, tvar = t, gvar = g, ivar = id, wvar = w, trend = TRUE, data = dat)
expect_equal(emfx(mt, vcov = FALSE)$estimate, mean(tau[dat$post]), tolerance = tol)
expect_equal(unname(coef(mt)[c("g::4:t", "g::6:t")]), c(0.3, -0.2), tolerance = tol)
# trends also work for binary treatments
expect_silent(etwfe(y ~ 0, tvar = t, gvar = g, trend = TRUE, data = dat))

# Binary dose reproduces the binary ETWFE ----

dat$wb = as.numeric(dat$post)
b1 = emfx(etwfe(y ~ x, tvar = t, gvar = g, ivar = id, data = dat, vcov = ~id), "event")
b2 = emfx(etwfe(y ~ x, tvar = t, gvar = g, ivar = id, wvar = wb, data = dat, vcov = ~id), "event")
expect_equal(b2$estimate, b1$estimate, tolerance = tol)
expect_equal(b2$std.error, b1$std.error, tolerance = tol)

# Controls and xvar ----

dat$grp = dat$id %% 2 == 0
mx = etwfe(y ~ x, tvar = t, gvar = g, ivar = id, wvar = w, xvar = grp, data = dat, vcov = ~id)
ex = emfx(mx)
expect_equal(nrow(ex), 2L)
expect_true(all(is.finite(ex$std.error)))

# Level effects (observed treatment level vs. none) ----

expect_equal(
  emfx(m, wlevels = "observed", vcov = FALSE)$estimate,
  mean((tau * dat$w)[dat$post]),
  tolerance = tol
)
expect_equal(
  emfx(m, "event", wlevels = "observed", vcov = FALSE)$estimate,
  as.numeric(tapply((tau * dat$w)[dat$post], (dat$t - dat$g)[dat$post], mean)),
  tolerance = tol
)
# levels and slopes coincide for a binary dose
mb = etwfe(y ~ x, tvar = t, gvar = g, ivar = id, wvar = wb, data = dat, vcov = ~id)
lb = emfx(mb, "event", wlevels = "observed")
expect_equal(lb$estimate, b2$estimate, tolerance = tol)
expect_equal(lb$std.error, b2$std.error, tolerance = tol)

# Effects at fixed treatment levels ----

ef = emfx(m, "event", wlevels = c(1, 3), vcov = FALSE)
ef = ef[order(ef$w, ef$event), ]
expect_equal(ef$w, rep(c(1, 3), each = nrow(ev)))
expect_equal(ef$estimate, c(ev$estimate, 3 * ev$estimate), tolerance = tol)
expect_equal(attr(ef, "etwfe")[["wlevels"]], c(1, 3))
eq = emfx(m, wlevels = \(x) quantile(x, c(0.25, 0.5, 0.75)), vcov = FALSE)
wq = unique(quantile(dat$w[dat$post], c(0.25, 0.5, 0.75), names = FALSE))
expect_equal(eq$w, wq)
expect_equal(eq$estimate, wq * mean(tau[dat$post]), tolerance = tol)
expect_equal(emfx(m, wlevels = fivenum, vcov = FALSE)$w, unique(fivenum(dat$w[dat$post])))
expect_error(emfx(m, wlevels = \(x) "a"), "must return a numeric")
expect_warning(emfx(mb, wlevels = 2), "binary")
expect_warning(emfx(etwfe(y ~ 0, tvar = t, gvar = g, data = dat), wlevels = 1), "only used")
expect_error(emfx(m, wlevels = "median"), "must be NULL")
expect_error(emfx(mx, wlevels = 1), "Fixed `wlevels`")

# Errors ----

expect_error(
  etwfe(y ~ 0, tvar = t, gvar = g, wvar = w, data = dat),
  "require unit-level fixed effects"
)
expect_error(
  etwfe(y ~ 0, tvar = t, gvar = g, ivar = id, wvar = w, data = dat, family = "poisson"),
  "only supported for linear models"
)
expect_error(
  etwfe(y ~ 0, tvar = t, gvar = g, ivar = id, wvar = w, data = dat, cgroup = "never"),
  "not yet supported"
)
expect_error(
  etwfe(y ~ 0, tvar = t, gvar = g, ivar = id, wvar = grp, data = dat),
  "single numeric variable"
)
dat$tc = factor(dat$t)
expect_error(
  etwfe(y ~ 0, tvar = tc, gvar = g, trend = TRUE, data = dat),
  "numeric `tvar`"
)
