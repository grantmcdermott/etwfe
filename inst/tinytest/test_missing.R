# Missing outcomes should give identical results to fitting on complete cases,
# both in etwfe() (demeaned controls) and emfx() (aggregation rows) (#91)

data("base_stagg", package = "fixest")
dat = base_stagg
dat$y[dat$id %% 2 == 0 & dat$year > 7] = NA
dat_cc = dat[!is.na(dat$y), ]

cols = c("estimate", "std.error")

mod = etwfe(y ~ 0, tvar = year, gvar = year_treated, data = dat)
mod_cc = etwfe(y ~ 0, tvar = year, gvar = year_treated, data = dat_cc)
expect_equal(emfx(mod)[cols], emfx(mod_cc)[cols])
expect_equal(emfx(mod, "event")[cols], emfx(mod_cc, "event")[cols])

# controls
mod = etwfe(y ~ x1, tvar = year, gvar = year_treated, data = dat)
mod_cc = etwfe(y ~ x1, tvar = year, gvar = year_treated, data = dat_cc)
expect_equal(coef(mod), coef(mod_cc))
expect_equal(emfx(mod)[cols], emfx(mod_cc)[cols])

# lean models can't recover the estimation sample
mod = etwfe(y ~ 0, tvar = year, gvar = year_treated, data = dat, lean = TRUE)
expect_error(emfx(mod), "lean = TRUE")

# missing formula weights
dat = base_stagg
dat$w = runif(nrow(dat))
dat$w[dat$id %% 2 == 0 & dat$year > 7] = NA
mod = etwfe(y ~ x1, tvar = year, gvar = year_treated, data = dat, weights = ~w)
mod_cc = etwfe(y ~ x1, tvar = year, gvar = year_treated, data = dat[!is.na(dat$w), ], weights = ~w)
expect_equal(coef(mod), coef(mod_cc))
expect_equal(emfx(mod)[cols], emfx(mod_cc)[cols])
