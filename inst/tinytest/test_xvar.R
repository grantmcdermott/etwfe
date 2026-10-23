set.seed(123)
tol = 5e-4
data("mpdta", package = "did")

# Vignette example ----

gls_fips = c(
  "IL" = 17,
  "IN" = 18,
  "MI" = 26,
  "MN" = 27,
  "NY" = 36,
  "OH" = 39,
  "PA" = 42,
  "WI" = 55
)

mpdta$gls = substr(mpdta$countyreal, 1, 2) %in% gls_fips
hmod_att = emfx(etwfe(
  lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  vcov = ~countyreal,
  xvar = gls ## <= het. TEs by gls
))

hmod_att_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat"),
    contrast = c("TRUE - FALSE", "TRUE - FALSE"),
    .Dtreat = c(TRUE, TRUE),
    gls = c(FALSE, TRUE),
    estimate = c(-0.0600010426077679, -0.0449165785109597),
    std.error = c(0.0366171596259543, 0.0281570035332875),
    statistic = c(-1.63860450184234, -1.59521869782268),
    p.value = c(0.101295654168178, 0.11066333894837),
    s.value = c(3.30335581457368, 3.17575073615861),
    conf.low = c(-0.131769356690793, -0.10010329134877),
    conf.high = c(0.0117672714752564, 0.010270134326851)
  ),
  class = "data.frame",
  row.names = c(NA, -2L)
)

cols = c(
  "estimate",
  "std.error",
  "statistic",
  "p.value",
  "conf.low",
  "conf.high"
)
for (col in cols) {
  expect_equal(hmod_att[[col]], hmod_att_known[[col]], tolerance = tol)
}

# Simulation example ----

library(data.table)

# 70 indivs
# 20 time periods
# staggered treat rollout at t = 11 and t = 16
# one control group (0), followed by tree equi-sized treatment groups 1:3
# (with each treatment group separated across rollout periods)

set.seed(1234L)

ids = 70
periods = 20

dat = CJ(id = 1:ids, period = 1:periods)

dat[,
  x := 0.1 * period + runif(n = .N, max = 0.1)
][,
  te_grp := fcase(
    id <= 10,
    0,
    id <= 20,
    1,
    id <= 30,
    2,
    id <= 40,
    3,
    id <= 50,
    1,
    id <= 60,
    2,
    id <= 70,
    3
  )
][,
  first_treat := fcase(
    te_grp == 0,
    Inf,
    id <= 40,
    11,
    id <= 70,
    16
  )
][,
  te := 0
][
  period >= first_treat,
  te := te_grp * (period - first_treat) + rnorm(.N, sd = 0.01) # add a little noise to the TEs
][,
  te_grp := as.factor(te_grp)
][,
  y := 1 * x + te + rnorm(n = .N, sd = 0.1)
][]

## known ATTs for the event study
# dat[
#   period >= first_treat,
#   .(ATE = mean(te)),
#   by = .(te_grp, event = period - first_treat)
# ]

sim_mod = etwfe(
  y ~ x,
  tvar = period,
  gvar = first_treat,
  xvar = te_grp,
  data = dat,
  vcov = "iid"
)

sim_att = emfx(sim_mod, lean = TRUE)
sim_es = emfx(sim_mod, "event", lean = TRUE)

sim_att_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c("TRUE - FALSE", "TRUE - FALSE", "TRUE - FALSE"),
    .Dtreat = c(TRUE, TRUE, TRUE),
    te_grp = structure(2:4, levels = c("0", "1", "2", "3"), class = "factor"),
    estimate = c(3.64409742004784, 7.31766444932634, 10.9924992277363),
    std.error = c(0.225721106890033, 0.448856626545844, 0.674467960251115),
    statistic = c(16.1442475196755, 16.3028994484032, 16.2980302632072),
    p.value = c(
      1.24659473651541e-58,
      9.41193294437532e-60,
      1.0192425391374e-59
    ),
    s.value = c(192.35383697707, 196.081194651171, 195.966260202027),
    conf.low = c(3.20169217999284, 6.43792162707437, 9.67056631691791),
    conf.high = c(4.0865026601028, 8.19740727157836, 12.3144321385547)
  ),
  class = "data.frame",
  row.names = c(NA, -3L)
)

sim_es_known = structure(
  list(
    term = c(
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
      ".Dtreat",
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
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE"
    ),
    event = c(
      0,
      0,
      0,
      1,
      1,
      1,
      2,
      2,
      2,
      3,
      3,
      3,
      4,
      4,
      4,
      5,
      5,
      5,
      6,
      6,
      6,
      7,
      7,
      7,
      8,
      8,
      8,
      9,
      9,
      9
    ),
    te_grp = structure(
      c(
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L,
        2L,
        3L,
        4L
      ),
      levels = c("0", "1", "2", "3"),
      class = "factor"
    ),
    estimate = c(
      -0.043374785997939,
      0.00938397938197281,
      -0.0237484443155469,
      0.957378771774771,
      1.98084154437812,
      2.95127402899149,
      2.05926108133396,
      4.00769294397254,
      6.01763770859724,
      2.96004156883017,
      5.95023186844904,
      9.01045082176056,
      3.96227702407247,
      7.98393664549455,
      12.0024108692249,
      4.9681600484615,
      9.9737817695494,
      14.9746049439183,
      5.99790531685755,
      12.0085642277569,
      17.9713002199087,
      7.00419009414942,
      14.0485277165315,
      21.0492535202316,
      7.95623841751119,
      15.9211608341913,
      23.9627880615379,
      8.94380010371113,
      17.9487582285135,
      27.0134917019308
    ),
    std.error = c(
      0.0477654215888954,
      0.0469981843504118,
      0.0276940080950101,
      0.026638998701713,
      0.0280526105156292,
      0.028499552901781,
      0.0340623779862456,
      0.033679282041549,
      0.0359388860632248,
      0.0293812200771637,
      0.031375601017307,
      0.0305877735353296,
      0.0361318509685794,
      0.0339902205097102,
      0.0325518301027566,
      0.0610701763164618,
      0.0554828534949186,
      0.0658412575477613,
      0.0474744547534635,
      0.0535095054429017,
      0.0473433193687061,
      0.0505007695207753,
      0.0535711540526076,
      0.0584668320242112,
      0.0498309748651796,
      0.0567107453872937,
      0.0513160344635654,
      0.0548225899018262,
      0.0622342001479752,
      0.0546208149472728
    ),
    statistic = c(
      -0.908079203718564,
      0.199666849004493,
      -0.857530056257664,
      35.938992395814,
      70.6116652948528,
      103.555099238252,
      60.4555877503275,
      118.995795071484,
      167.440852173582,
      100.746039853279,
      189.645191662422,
      294.576877632337,
      109.661612064048,
      234.889227718124,
      368.716930241305,
      81.3516571938944,
      179.763316796039,
      227.434977727479,
      126.339635663092,
      224.419271461393,
      379.595272565238,
      138.694720112675,
      262.240527854694,
      360.020421690108,
      159.664514672698,
      280.74328287287,
      466.964922602441,
      163.140780465114,
      288.406666846019,
      494.564054527554
    ),
    p.value = c(
      0.363836377005536,
      0.841741142323068,
      0.391152011311908,
      7.52030858468724e-283,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ),
    s.value = c(
      1.45863830148061,
      0.248551460294281,
      1.35419871153254,
      937.194858991159,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf,
      Inf
    ),
    conf.low = c(
      -0.136993292022333,
      -0.082730769287402,
      -0.0780277027734947,
      0.905167293733395,
      1.92585943809352,
      2.89541593172676,
      1.99250004725146,
      3.94168276414428,
      5.94719878626724,
      2.90245543565881,
      5.88873682046366,
      8.95049988726592,
      3.89145989747916,
      7.91731703746897,
      11.9386104545926,
      4.84846470235771,
      9.86503737494574,
      14.8455584504339,
      5.90485709535405,
      11.9036875242568,
      17.8785090190359,
      6.90521040470633,
      13.9435301839876,
      20.9346606351836,
      7.85857150146603,
      15.8100098157008,
      23.862210482165,
      8.83634980195603,
      17.8267814376088,
      26.9064368718196
    ),
    conf.high = c(
      0.0502437200188813,
      0.10149872804376,
      0.0305308141340663,
      1.00959024981253,
      2.03582365065944,
      3.00713212625272,
      2.12602211541313,
      4.07370312379749,
      6.08807663092406,
      3.01762770200498,
      6.0117269164381,
      9.07040175625894,
      4.03309415066553,
      8.05055625352018,
      12.0662112838572,
      5.08785539457727,
      10.0825261641648,
      15.1036514374148,
      6.09095353835898,
      12.1134409312541,
      18.0640914207783,
      7.10316978361089,
      14.1535252490943,
      21.1638464052988,
      8.05390533356658,
      16.0323118526918,
      24.063365640921,
      9.05125040544961,
      18.0707350194022,
      27.1205465320254
    )
  ),
  class = "data.frame",
  row.names = c(NA, -30L)
)

# Tests ----
# match order
sim_es = sim_es[order(sim_es$event, sim_es$te_grp), ]

for (col in c("estimate", "std.error", "conf.low", "conf.high")) {
  expect_equivalent(sim_att[[col]], sim_att_known[[col]], tolerance = tol)
  expect_equivalent(sim_es[[col]], sim_es_known[[col]], tolerance = tol)
}
