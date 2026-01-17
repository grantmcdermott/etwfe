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
    std.error = c(0.0343946845417874, 0.0281086484211582),
    statistic = c(-1.74448591132942, -1.59796294143939),
    p.value = c(0.0810743959800703, 0.110051224802928),
    s.value = c(3.62460981941067, 3.18375289325374),
    conf.low = c(-0.127413385569288, -0.100008517070528),
    conf.high = c(0.00741130035375201, 0.0101753600486091)
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
    std.error = c(0.02744238618225, 0.0274615288404309, 0.027020649953168),
    statistic = c(132.790836622104, 266.469667142229, 406.818460947032),
    p.value = c(0, 0, 0),
    s.value = c(Inf, Inf, Inf),
    conf.low = c(3.59031133148079, 7.26384084183869, 10.9395397269892),
    conf.high = c(3.69788350861489, 7.37148805681399, 11.0454587284834)
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
      0.0447115150406635,
      0.0445067299348428,
      0.0321696137609958,
      0.0324723140230891,
      0.0325316735534932,
      0.0324118325105882,
      0.0330143845572309,
      0.0331217875635463,
      0.0339437944292082,
      0.0361057892521513,
      0.0342322154018733,
      0.0339973477212171,
      0.0348219383031047,
      0.0374111364092086,
      0.0361956419627852,
      0.0603199817041965,
      0.0563667868072388,
      0.064199264131474,
      0.0579602524526515,
      0.0582900147149009,
      0.058845732943283,
      0.0604134329813464,
      0.0596751581774167,
      0.0616558009488072,
      0.0618022616604452,
      0.0643945756737671,
      0.0620651164898513,
      0.0643568507261837,
      0.070869383917821,
      0.0641514884699945
    ),
    statistic = c(
      -0.970103248760218,
      0.210844054274731,
      -0.73822596976097,
      29.4829241640752,
      60.8896293368043,
      91.0554510618115,
      62.3746621041565,
      120.998691157098,
      177.282410814365,
      81.9824640352876,
      173.819654924333,
      265.033934283565,
      113.78680272141,
      213.41069563258,
      331.598231675661,
      82.3634210107173,
      176.944302389586,
      233.251971755497,
      103.483077851625,
      206.014088115972,
      305.396828640573,
      115.937627585442,
      235.416681674553,
      341.399401131919,
      128.73701064897,
      247.243819337368,
      386.091083313382,
      138.971997585213,
      253.265334567133,
      421.089086881683
    ),
    p.value = c(
      0.33199502981194,
      0.833008960844001,
      0.460377144168898,
      4.76641469781476e-191,
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
      1.59076645126498,
      0.263596079853959,
      1.11911188351254,
      632.235361646055,
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
      -0.13100774517186,
      -0.0778476083599698,
      -0.0867997286836627,
      0.893734205794841,
      1.91708063585646,
      2.8877480045978,
      1.99455407663003,
      3.9427754332444,
      5.95110909401736,
      2.88927552226256,
      5.88313795915035,
      8.94381724465709,
      3.89402727912651,
      7.91061216551178,
      11.9314687145806,
      4.84993505677316,
      9.86330489748297,
      14.8487766983866,
      5.8843053095155,
      11.8943178982574,
      17.855964702696,
      6.88578194132356,
      13.931566555732,
      20.9284103709339,
      7.83510821049359,
      15.794949785071,
      23.8411426685215,
      8.81766299412939,
      17.8098567884281,
      26.887757094975
    ),
    conf.high = c(
      0.0442581731759824,
      0.0966155671239154,
      0.0393028400525689,
      1.0210233377547,
      2.04460245289978,
      3.01480005338519,
      2.12396808603789,
      4.07261045470068,
      6.08416632317712,
      3.03080761539778,
      6.01732577774773,
      9.07708439886403,
      4.03052676901843,
      8.05726112547731,
      12.0733530238693,
      5.08638504014984,
      10.0842586416158,
      15.1004331894499,
      6.1115053241996,
      12.1228105572564,
      18.0866357371214,
      7.12259824697528,
      14.165488877331,
      21.1700966695292,
      8.07736862452878,
      16.0473718833116,
      24.0844334545543,
      9.06993721329287,
      18.087659668599,
      27.1392263088866
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
