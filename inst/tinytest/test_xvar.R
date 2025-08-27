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
    estimate = c(-0.0636770215654198, -0.0472387691288175),
    std.error = c(0.0376166873566355, 0.0271278425487133),
    statistic = c(-1.69278652747149, -1.74133895992618),
    p.value = c(0.0904961080287808, 0.0816241808542006),
    s.value = c(3.46600044231166, 3.61485958132102),
    conf.low = c(-0.137404374002129, -0.100408363502569),
    conf.high = c(0.010050330871289, 0.00593082524493384)
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
    estimate = c(3.64409742004773, 7.31766444932623, 10.9924992277362),
    std.error = c(0.0274422524246475, 0.0274615615784503, 0.0270204728159514),
    statistic = c(132.791483864304, 266.46934947314, 406.821127913307),
    p.value = c(0, 0, 0),
    s.value = c(Inf, Inf, Inf),
    conf.low = c(3.59031159364077, 7.26384077767323, 10.9395400741717),
    conf.high = c(3.6978832464547, 7.37148812097922, 11.0454583813007)
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
      -0.0433747859989123,
      0.00938397938099142,
      -0.0237484443165878,
      0.957378771775375,
      1.98084154437872,
      2.9512740289921,
      2.05926108133395,
      4.00769294397253,
      6.01763770859722,
      2.96004156883153,
      5.9502318684504,
      9.01045082176193,
      3.96227702406939,
      7.98393664549141,
      12.0024108692218,
      4.96816004845664,
      9.97378176954449,
      14.9746049439134,
      5.99790531685596,
      12.0085642277554,
      17.9713002199072,
      7.00419009415115,
      14.0485277165333,
      21.0492535202333,
      7.95623841751102,
      15.9211608341911,
      23.9627880615377,
      8.94380010371856,
      17.948758228521,
      27.0134917019382
    ),
    std.error = c(
      0.0447114979963977,
      0.0445067142434795,
      0.0321695984411709,
      0.0324722949054028,
      0.0325316573159661,
      0.032411768475619,
      0.0330144002498528,
      0.0331217838637407,
      0.0339439859130358,
      0.0361057401025226,
      0.034232215401911,
      0.0339972859900763,
      0.0348218757487561,
      0.0374089034390226,
      0.0361958592384628,
      0.0603200118395114,
      0.0563667872394156,
      0.0641992764497802,
      0.0579602502730396,
      0.0582897749677052,
      0.0588452021454363,
      0.0604134315799277,
      0.0596748726125742,
      0.0616556510447104,
      0.0618027223284135,
      0.0643952700190317,
      0.0620650959703741,
      0.0643564903580635,
      0.070868217510473,
      0.0641515423172217
    ),
    statistic = c(
      -0.970103618590611,
      0.210844128588222,
      -0.738226321351727,
      29.4829415218228,
      60.8896597286654,
      91.0556309573828,
      62.3746324558215,
      120.998704673025,
      177.281410733977,
      81.9825756355211,
      173.819654924181,
      265.034415523406,
      113.787007129015,
      213.423434303692,
      331.59624116528,
      82.3633798626403,
      176.944301032828,
      233.251926999945,
      103.483081743108,
      206.014935456666,
      305.399583393238,
      115.937630274892,
      235.417808224581,
      341.400231180256,
      128.736051063129,
      247.241153418345,
      386.091210959797,
      138.972775767564,
      253.269503016194,
      421.088733429973
    ),
    p.value = c(
      0.331994845486515,
      0.83300890285383,
      0.460376930551276,
      4.76397327599315e-191,
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
      1.59076725225724,
      0.263596180287615,
      1.11911255293142,
      632.23610080321,
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
      -0.131007711766687,
      -0.0778475776064442,
      -0.0867996986583986,
      0.893734243265422,
      1.91708066768203,
      2.88774813010463,
      1.99455404587304,
      3.94277544049588,
      5.95110871871594,
      2.88927561859542,
      5.88313795915164,
      8.94381736564927,
      3.8940274017277,
      7.91061654204979,
      11.931468288725,
      4.84993499770417,
      9.86330489663101,
      14.8487766742383,
      5.88430531378587,
      11.8943183681517,
      17.8559657430391,
      6.88578194407202,
      13.9315671154306,
      20.9284106647423,
      7.8351073076008,
      15.7949484241791,
      23.8411427087388,
      8.81766370044535,
      17.8098590745519,
      26.8877569894438
    ),
    conf.high = c(
      0.044258139768862,
      0.096615536368427,
      0.039302810025223,
      1.02102330028533,
      2.04460242107542,
      3.01479992787956,
      2.12396811679485,
      4.07261044744918,
      6.08416669847851,
      3.03080751906764,
      6.01732577774916,
      9.07708427787459,
      4.03052664641108,
      8.05725674893303,
      12.0733534497187,
      5.08638509920911,
      10.084258642458,
      15.1004332135885,
      6.11150531992604,
      12.122810087359,
      18.0866346967752,
      7.12259824423029,
      14.1654883176359,
      21.1700963757243,
      8.07736952742124,
      16.0473732442032,
      24.0844334143367,
      9.06993650699176,
      18.0876573824901,
      27.1392264144327
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
