# family = "negbin" via fixest::fenegbin(), and family objects (#93)

data("mpdta", package = "did")
mpdta$emp = round(exp(mpdta$lemp)) # integer counts

# Family objects no longer break the `fe` default
mp = etwfe(emp ~ lpop, tvar = year, gvar = first.treat, data = mpdta, family = "poisson")
mpo = etwfe(emp ~ lpop, tvar = year, gvar = first.treat, data = mpdta, family = poisson())
expect_equal(coef(mpo), coef(mp))
expect_identical(attr(mpo, "etwfe")$fe, "none")

# family = "negbin" is estimated with fenegbin(), without a singular fit
# despite the empty (all-zero) treatment cells
mnb = etwfe(
  emp ~ lpop, tvar = year, gvar = first.treat, data = mpdta,
  family = "negbin", vcov = ~countyreal
)
expect_identical(mnb$method, "fenegbin")
expect_true(mnb$convStatus)
expect_false(anyNA(fixest::se(mnb)))

# Same model as the standard treatment term when there are no empty cells
# (never-treated + 2004 cohort only)
d = subset(mpdta, first.treat %in% c(0, 2004))
m1 = etwfe(emp ~ 1, tvar = year, gvar = first.treat, data = d, family = "negbin")
d$.Dtreat = d$year >= d$first.treat & d$first.treat != 0
m2 = fixest::fenegbin(
  emp ~ .Dtreat:i(first.treat, i.year, ref = 0, ref2 = 2003) +
    i(first.treat, ref = 0) + i(year, ref = 2003),
  data = d, notes = FALSE
)
expect_equal(unname(coef(m1)), unname(coef(m2)), tolerance = 1e-6)
expect_equal(m1$theta, m2$theta, tolerance = 1e-6)

# emfx() falls back to the model vcov, since fenegbin() has no bread() method
expect_warning(emfx(mnb), "Unconditional standard errors are not available")
e1 = suppressWarnings(emfx(mnb))
e2 = emfx(mnb, vcov = TRUE)
expect_equal(e1$std.error, e2$std.error)
expect_true(all(is.finite(e2$std.error)))

# Never-treated control group, incl. pretrends() on the renamed lead terms
mnbn = etwfe(
  emp ~ lpop, tvar = year, gvar = first.treat, data = mpdta,
  family = "negbin", cgroup = "never", vcov = ~countyreal
)
expect_false(anyNA(fixest::se(mnbn)))
expect_true(is.numeric(pretrends(mnbn, print = FALSE)$p))

# weights are rejected, since fenegbin() would silently ignore them
expect_error(
  etwfe(emp ~ 1, tvar = year, gvar = first.treat, data = mpdta, family = "negbin", weights = ~lpop),
  "weights"
)
