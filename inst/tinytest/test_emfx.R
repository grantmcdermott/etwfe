data("mpdta", package = "did")
tol = 5e-4
# Add exponeniated employment outcome (for Poisson)
mpdta$emp = exp(mpdta$lemp)

# We'll continue with model 3 from the etwfe tests...
m3 = etwfe(
  lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  vcov = ~countyreal
)
# Poisson version
m3p = etwfe(
  emp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  vcov = ~countyreal,
  family = "poisson"
)

# Known outputs ----

# from m3 |> emfx(...) |> c() |> data.frame() |> dput()

simple_known = structure(
  list(
    term = ".Dtreat",
    contrast = "TRUE - FALSE",
    .Dtreat = TRUE,
    estimate = -0.0506270331228907,
    std.error = 0.0124972546529842,
    statistic = -4.05105237339478,
    p.value = 5.09877921904418e-05,
    s.value = 14.2594886048928,
    conf.low = -0.0751212021483654,
    conf.high = -0.026132864097416
  ),
  class = "data.frame",
  row.names = c(NA, -1L)
)

calendar_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c(
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE"
    ),
    year = 2004:2007,
    estimate = c(
      -0.0212480022225509,
      -0.0818499992698648,
      -0.0442655912990223,
      -0.0524323095862384
    ),
    std.error = c(
      0.0217240109737018,
      0.0273693827216135,
      0.0173733625406716,
      0.015015825012757
    ),
    statistic = c(
      -0.978088358005015,
      -2.99056796795158,
      -2.54790005074695,
      -3.49180345013967
    ),
    p.value = c(
      0.328030625301706,
      0.00278459151993077,
      0.0108373515879506,
      0.000479771149651068
    ),
    s.value = c(
      1.6080975821527,
      8.48831857483181,
      6.52784395317133,
      11.0253659737038
    ),
    conf.low = c(
      -0.0638262813307593,
      -0.13549300368332,
      -0.0783167561690959,
      -0.0818627858093978
    ),
    conf.high = c(
      0.0213302768856575,
      -0.0282069948564095,
      -0.0102144264289487,
      -0.0230018333630791
    )
  ),
  class = "data.frame",
  row.names = c(NA, -4L)
)

group_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c("TRUE - FALSE", "TRUE - FALSE", "TRUE - FALSE"),
    first.treat = c(2004, 2006, 2007),
    estimate = c(-0.0876269608795944, -0.0212783329358987, -0.0459545277368072),
    std.error = c(0.0230474099815232, 0.0185912208081438, 0.0179714452432232),
    statistic = c(-3.80203072492066, -1.1445366151844, -2.55708581668668),
    p.value = c(0.000143514924104987, 0.25240116196139, 0.0105553173898319),
    s.value = c(12.7665116091104, 1.98620954291842, 6.56588622976781),
    conf.low = c(-0.132799054380309, -0.0577164561484921, -0.0811779131636583),
    conf.high = c(-0.04245486737888, 0.0151597902766947, -0.0107311423099561)
  ),
  class = "data.frame",
  row.names = c(NA, -3L)
)

event_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c(
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE"
    ),
    event = c(0, 1, 2, 3),
    estimate = c(
      -0.0332122037837542,
      -0.0573456479257483,
      -0.137870386660852,
      -0.10953945536511
    ),
    std.error = c(
      0.0133659635774059,
      0.0171496442892364,
      0.0307883597041053,
      0.0323152785480507
    ),
    statistic = c(
      -2.48483422773177,
      -3.34383891342516,
      -4.47800363468108,
      -3.38971100627314
    ),
    p.value = c(
      0.0129611775056692,
      0.000826277000608205,
      7.53443190516573e-06,
      0.000699663399486979
    ),
    s.value = c(
      6.26965939868018,
      10.2410868685938,
      17.0180698323515,
      10.4810513556111
    ),
    conf.low = c(
      -0.0594090110141438,
      -0.0909583330803246,
      -0.198214462823963,
      -0.172876237469669
    ),
    conf.high = c(
      -0.00701539655336458,
      -0.023732962771172,
      -0.0775263104977414,
      -0.0462026732605506
    )
  ),
  class = "data.frame",
  row.names = c(NA, -4L)
)

event_pre_known = structure(
  list(
    term = c(
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat"
    ),
    contrast = c(
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE"
    ),
    event = c(-4, -3, -2, -1, 0, 1, 2, 3),
    estimate = c(
      0,
      0,
      0,
      0,
      -0.0332122037837542,
      -0.0573456479257483,
      -0.137870386660852,
      -0.10953945536511
    ),
    std.error = c(
      NA,
      NA,
      NA,
      NA,
      0.0133659635774059,
      0.0171496442892364,
      0.0307883597041053,
      0.0323152785480507
    ),
    statistic = c(
      NA,
      NA,
      NA,
      NA,
      -2.48483422773177,
      -3.34383891342516,
      -4.47800363468108,
      -3.38971100627314
    ),
    p.value = c(
      NA,
      NA,
      NA,
      NA,
      0.0129611775056692,
      0.000826277000608205,
      7.53443190516573e-06,
      0.000699663399486979
    ),
    s.value = c(
      NA,
      NA,
      NA,
      NA,
      6.26965939868018,
      10.2410868685938,
      17.0180698323515,
      10.4810513556111
    ),
    conf.low = c(
      NA,
      NA,
      NA,
      NA,
      -0.0594090110141438,
      -0.0909583330803246,
      -0.198214462823963,
      -0.172876237469669
    ),
    conf.high = c(
      NA,
      NA,
      NA,
      NA,
      -0.00701539655336458,
      -0.023732962771172,
      -0.0775263104977414,
      -0.0462026732605506
    )
  ),
  class = "data.frame",
  row.names = c(NA, -8L)
)

event_pois_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c(
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE"
    ),
    event = c(0, 1, 2, 3),
    estimate = c(
      -25.3497484355494,
      1.09175116997388,
      -75.1246321552693,
      -101.823979344829
    ),
    std.error = c(
      15.8862762958862,
      40.2952222352926,
      23.1541376499351,
      27.0877431076141
    ),
    statistic = c(
      -1.59570109215045,
      0.0270938118568724,
      -3.24454459462367,
      -3.75904256549921
    ),
    p.value = c(
      0.110555544688288,
      0.978384910373312,
      0.00117638595699075,
      0.000170564820647175
    ),
    s.value = c(
      3.17715671248583,
      0.0315259415305138,
      9.73142281727341,
      12.5173922610964
    ),
    conf.low = c(
      -56.4862778239388,
      -77.8854331602371,
      -120.505908042225,
      -154.914980258226
    ),
    conf.high = c(
      5.78678095284,
      80.0689355001849,
      -29.7433562683137,
      -48.7329784314324
    )
  ),
  class = "data.frame",
  row.names = c(NA, -4L)
)

event_pois_link_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c(
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE"
    ),
    event = c(0, 1, 2, 3),
    estimate = c(
      -0.0325653634930092,
      -0.0675071046997911,
      -0.132971344933511,
      -0.117022779216096
    ),
    std.error = c(
      0.0128503810792558,
      0.0183966910997271,
      0.0237253182969748,
      0.0225005664705109
    ),
    statistic = c(
      -2.53419437852929,
      -3.66952428204833,
      -5.60461795576696,
      -5.2008814697828
    ),
    p.value = c(
      0.0112706193566784,
      0.000243002256143726,
      2.08714813737549e-08,
      1.98345571064795e-07
    ),
    s.value = c(
      6.47128939136694,
      12.0067426710178,
      25.513891758279,
      22.2654804808659
    ),
    conf.low = c(
      -0.0577516475959654,
      -0.103563956689965,
      -0.179472114317331,
      -0.161123079130047
    ),
    conf.high = c(
      -0.00737907939005289,
      -0.0314502527096174,
      -0.0864705755496916,
      -0.0729224793021455
    )
  ),
  class = "data.frame",
  row.names = c(NA, -4L)
)

# Tests ----

e1 = emfx(m3)
e2 = emfx(m3, type = "simple")
e3 = emfx(m3, type = "calendar")
e4 = emfx(m3, type = "group")
e5 = emfx(m3, type = "event")
e6 = emfx(m3, type = "event", post_only = FALSE)
e7 = emfx(m3p, type = "event")
e8 = emfx(m3p, type = "event", predict = "link")

# match order
e3 = e3[order(e3$year), ]
e4 = e4[order(e4$first.treat), ]

for (col in c("estimate", "std.error", "conf.low", "conf.high")) {
  expect_equivalent(e1[[col]], simple_known[[col]], tolerance = tol)
  expect_equivalent(e2[[col]], simple_known[[col]], tolerance = tol)
  expect_equivalent(e3[[col]], calendar_known[[col]], tolerance = tol)
  expect_equivalent(e4[[col]], group_known[[col]], tolerance = tol)
  expect_equivalent(e5[[col]], event_known[[col]], tolerance = tol)
  expect_equivalent(e6[[col]], event_pre_known[[col]], tolerance = tol)
  expect_equivalent(e7[[col]], event_pois_known[[col]], tolerance = tol)
  expect_equivalent(e8[[col]], event_pois_link_known[[col]], tolerance = tol)
}
