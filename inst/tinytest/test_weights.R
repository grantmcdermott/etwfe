# emfx() should aggregate using the model's regression weights

data("base_stagg", package = "fixest")
dat = base_stagg
set.seed(1)
dat$w = exp(rnorm(nrow(dat)))

mod = etwfe(y ~ x1, tvar = year, gvar = year_treated, data = dat, weights = ~w)

# simple ATT equals the weighted mean of the unit-level effects
d = eval(mod$call$data, mod$call_env)
d = d[d$.Dtreat, ]
s = marginaleffects::slopes(
  structure(mod, class = setdiff(class(mod), "etwfe")),
  newdata = d,
  variables = ".Dtreat",
  vcov = FALSE
)
expect_equal(emfx(mod, vcov = FALSE)$estimate, weighted.mean(s$estimate, d$w))

# compressed data (cell weights + weighted covariate means) give the same result
cols = c("estimate", "std.error")
expect_equal(
  emfx(mod, "event", vcov = TRUE)[cols],
  emfx(mod, "event", compress = TRUE, vcov = TRUE)[cols]
)

# never-treated controls: the zero-weighted (post-only) and subset paths agree
modn = etwfe(y ~ x1, tvar = year, gvar = year_treated, data = dat, weights = ~w, cgroup = "never")
expect_equal(
  emfx(modn, vcov = FALSE)$estimate,
  emfx(modn, hypothesis = "b1 = 0", vcov = FALSE)$estimate
)
