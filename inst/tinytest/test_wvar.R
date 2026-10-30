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
dat$wb = as.numeric(dat$post)
ev_mean = function(v) as.numeric(tapply(v[dat$post], (dat$t - dat$g)[dat$post], mean))

# Exact recovery (noise-free outcome) ----

m = etwfe(y0 ~ 0, tvar = t, gvar = g, ivar = id, wvar = w, data = dat)
ev = emfx(m, "event", vcov = FALSE)
expect_equal(ev$estimate, ev_mean(tau), tolerance = tol)

# with cohort trends
dat$y0_tr = dat$y0 + 0.3 * (dat$g == 4) * dat$t - 0.2 * (dat$g == 6) * dat$t
mt = etwfe(y0_tr ~ 0, tvar = t, gvar = g, ivar = id, wvar = w, trend = TRUE, data = dat)
expect_equal(emfx(mt, vcov = FALSE)$estimate, mean(tau[dat$post]), tolerance = tol)

# Binary dose reproduces the binary ETWFE ----

b1 = emfx(etwfe(y ~ x, tvar = t, gvar = g, ivar = id, data = dat, vcov = ~id), "event")
b2 = emfx(etwfe(y ~ x, tvar = t, gvar = g, ivar = id, wvar = wb, data = dat, vcov = ~id), "event")
expect_equal(b2$estimate, b1$estimate, tolerance = tol)
expect_equal(b2$std.error, b1$std.error, tolerance = tol)

# Controls and xvar ----

dat$grp = dat$id %% 2 == 0
mx = etwfe(y ~ x, tvar = t, gvar = g, ivar = id, wvar = w, xvar = grp, data = dat, vcov = ~id)
expect_equal(nrow(emfx(mx)), 2L)

# Treatment levels (wlevels) ----

expect_equal(
  emfx(m, "event", wlevels = "observed", vcov = FALSE)$estimate,
  ev_mean(tau * dat$w),
  tolerance = tol
)
ef = emfx(m, "event", wlevels = c(1, 3), vcov = FALSE)
ef = ef[order(ef$w, ef$event), ]
expect_equal(ef$w, rep(c(1, 3), each = nrow(ev)))
expect_equal(ef$estimate, c(ev$estimate, 3 * ev$estimate), tolerance = tol)
eq = emfx(m, wlevels = function(x) quantile(x, c(0.25, 0.5, 0.75)), vcov = FALSE)
wq = unique(quantile(dat$w[dat$post], c(0.25, 0.5, 0.75), names = FALSE))
expect_equal(eq$estimate, wq * mean(tau[dat$post]), tolerance = tol)
expect_error(emfx(m, wlevels = "median"), "must be \"slope\"")
expect_error(emfx(mx, wlevels = 1), "Fixed `wlevels`")

# Never-treated control group (leads and lags) ----

mn = etwfe(y0 ~ 0, tvar = t, gvar = g, ivar = id, wvar = w, cgroup = "never", data = dat)
expect_message(en <- emfx(mn, "event", vcov = FALSE), "observed treatment level")
pre = en$event < 0
# noise-free outcome with parallel trends: pre-treatment effects are exactly zero
expect_equal(en$estimate[pre], rep(0, sum(pre)), tolerance = tol)
expect_equal(en$estimate[!pre], ev_mean(tau * dat$w), tolerance = tol)
es = emfx(mn, "event", wlevels = "slope", vcov = FALSE)
expect_equal(es$estimate[es$event >= 0], ev$estimate, tolerance = tol)
# fixed levels: pre-treatment estimates reported once
ef = suppressMessages(emfx(mn, "event", wlevels = c(1, 3), vcov = FALSE))
expect_equal(c(sum(ef$event == -2), sum(ef$event == 0)), c(1L, 2L))
# non-event aggregations only use post-treatment periods
expect_equal(
  emfx(mn, "calendar", vcov = FALSE)$estimate,
  as.numeric(tapply(tau[dat$post], dat$t[dat$post], mean)),
  tolerance = tol
)
# binary dose reproduces the binary never-treated event study
bn = etwfe(y ~ x, tvar = t, gvar = g, ivar = id, cgroup = "never", data = dat, vcov = ~id)
bn1 = emfx(bn, "event")
bn2 = emfx(etwfe(y ~ x, tvar = t, gvar = g, ivar = id, wvar = wb, cgroup = "never", data = dat, vcov = ~id), "event")
expect_equal(bn2$estimate, bn1$estimate, tolerance = tol)
expect_equal(bn2$std.error, bn1$std.error, tolerance = tol)
# controls are nested within both the pre- and post-treatment cells
cn = names(coef(etwfe(y ~ x, tvar = t, gvar = g, ivar = id, wvar = w, cgroup = "never", data = dat)))
expect_true(any(grepl("^\\.Dpre:g::.*:x_dm$", cn)) && any(grepl("\\.Dpost:w:x_dm$", cn)))
# with `hypothesis`, non-event aggregations take a different code path
expect_equal(emfx(bn, hypothesis = "b1 = 0")$estimate, emfx(bn)$estimate, tolerance = tol)
expect_error(emfx(mn, "event", hypothesis = "b1 = b2"), "not supported for event studies")

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
  etwfe(y ~ 0, tvar = t, gvar = g, trend = TRUE, cgroup = "never", data = dat),
  "not supported with `cgroup"
)

# Wooldridge (2026), Table 7.1 (conditional SEs, as in the paper) ----

data("walmart", package = "etwfe")
t71 = data.frame(
  est  = c(0.0291, 0.0439, 0.0357, 0.0301, 0.0286, 0.0316, 0.0344, 0.0412, 0.0459, 0.0480, 0.0624, 0.0671, 0.0706, 0.0895, 0.0386),
  se   = c(0.0041, 0.0042, 0.0044, 0.0046, 0.0048, 0.0051, 0.0055, 0.0063, 0.0072, 0.0082, 0.0104, 0.0121, 0.0160, 0.0210, 0.0051),
  est_tr = c(0.0049, 0.0196, 0.0113, 0.0070, 0.0060, 0.0073, 0.0106, 0.0200, 0.0236, 0.0274, 0.0373, 0.0422, 0.0587, 0.0925, 0.0156),
  se_tr  = c(0.0033, 0.0034, 0.0035, 0.0036, 0.0039, 0.0041, 0.0046, 0.0054, 0.0064, 0.0083, 0.0111, 0.0146, 0.0200, 0.0302, 0.0046)
)
for (tr in c(FALSE, TRUE)) {
  mw = etwfe(
    log_retail_emp ~ 0, tvar = year, gvar = cohort, ivar = fips, wvar = n_open,
    trend = tr, data = walmart, vcov = ~fips
  )
  ew = emfx(mw, "event", vcov = TRUE)
  sw = emfx(mw, vcov = TRUE)
  expect_equal(round(c(ew$estimate, sw$estimate), 4), t71[[if (tr) "est_tr" else "est"]])
  expect_equal(round(c(ew$std.error, sw$std.error), 4), t71[[if (tr) "se_tr" else "se"]])
}
