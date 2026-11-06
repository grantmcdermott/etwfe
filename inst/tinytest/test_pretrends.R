data("mpdta", package = "did")
tol = 1e-6

# cgroup = "never": joint test of the pre-treatment cells (leads), excluding
# each cohort's base period (g - 1)
m = etwfe(
  lemp ~ lpop, tvar = year, gvar = first.treat, data = mpdta,
  vcov = ~countyreal, cgroup = "never"
)
pt = pretrends(m, print = FALSE)
ref = fixest::wald(m, c("2006:year::200[34]$", "2007:year::200[345]$"), print = FALSE)
expect_equal(pt$df1, 5L)
expect_equal(pt$stat, ref$stat, tolerance = tol)

# interactions with nested (demeaned) controls are opt-in
pti = pretrends(m, interactions = TRUE, print = FALSE)
refi = fixest::wald(m, c("2006:year::200[34]", "2007:year::200[345]"), print = FALSE)
expect_equal(pti$df1, 10L)
expect_equal(pti$stat, refi$stat, tolerance = tol)

# no never-treated group: last cohort is the base, so only 2006 leads remain
mn = etwfe(
  lemp ~ 0, tvar = year, gvar = first.treat, vcov = ~countyreal,
  data = subset(mpdta, first.treat > 0), cgroup = "never", gref = 2007
)
expect_equal(pretrends(mn, print = FALSE)$df1, 2L)

# trend = TRUE: joint test of the cohort trends
mt = etwfe(
  log_retail_emp ~ 0, tvar = year, gvar = cohort, ivar = fips,
  wvar = n_open, data = walmart, vcov = ~fips, trend = TRUE
)
expect_equal(
  pretrends(mt, print = FALSE)$stat,
  fixest::wald(mt, "^cohort::.*:year$", print = FALSE)$stat,
  tolerance = tol
)

# non-binary treatment with cgroup = "never": binary leads
mw = etwfe(
  log_retail_emp ~ 0, tvar = year, gvar = cohort, ivar = fips,
  wvar = n_open, data = walmart, vcov = ~fips, cgroup = "never"
)
expect_equal(
  pretrends(mw, print = FALSE)$stat,
  fixest::wald(mw, "^\\.Dpre:", print = FALSE)$stat,
  tolerance = tol
)

# default "notyet" model has nothing to test
mny = etwfe(
  lemp ~ lpop, tvar = year, gvar = first.treat, data = mpdta,
  vcov = ~countyreal
)
expect_error(pretrends(mny), "No pre-trend terms")
expect_error(pretrends(lm(lemp ~ lpop, mpdta)), "etwfe")
