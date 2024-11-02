data("mpdta", package = "did")
tol <- 5e-4
# Add exponeniated employment outcome (for Poisson)
mpdta$emp = exp(mpdta$lemp)

# We'll continue with model 3 from the etwfe tests...
m3 = etwfe(lemp ~ lpop, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal)
# Poisson version
m3p = etwfe(emp ~ lpop, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal, family = "poisson")

# Known outputs ----

# from m3 |> emfx(...) |> c() |> data.frame() |> dput()

simple_known =
  structure(
    list(
      type = "response", term = ".Dtreat", contrast = "mean(TRUE) - mean(FALSE)", 
      .Dtreat = TRUE, estimate = -0.0506270331230485, std.error = 0.0124997858367792, 
      statistic = -4.05023204270301, p.value = 5.11668721668786e-05,
      conf.low = -0.0751261631775997, conf.high = -0.0261279030684973
      ), 
    row.names = c(NA, -1L), 
    class = c("marginaleffects.summary", "data.frame"), 
    conf_level = 0.95, 
    FUN = "mean", 
    type = structure("response", names = NA_character_), 
    model_type = "etwfe"
    )

calendar_known =
  structure(
    list(
      type = c("response", "response", "response", "response"), 
      term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"), 
      contrast = c("mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"), 
      year = 2004:2007,
      estimate = c(-0.0212480022221406, -0.0818499992694122, -0.0442655912992566, -0.0524323095864956), 
      std.error = c(0.0217284164985588, 0.0273749205550772, 0.0173768795442279, 0.0150188665423779), 
      statistic = c(-0.977890046591753, -2.98996298837593, -2.54738436706033, -3.49109631133284),
      p.value = c(0.328128708472153, 0.00279011252351069, 0.0108533815862891, 0.000481042811674095), 
      conf.low = c(-0.0638349160004017, -0.135503857637009, -0.078323649369634, -0.0818687470981699), 
      conf.high = c(0.0213389115561204, -0.0281961409018157, -0.0102075332288792, -0.0229958720748214)
      ), row.names = c(NA, -4L), 
    class = c("marginaleffects.summary", "data.frame"), 
    conf_level = 0.95, 
    FUN = "mean", 
    type = structure("response", names = NA_character_), 
    model_type = "etwfe"
    )

group_known =
  structure(
    list(
      type = c("response", "response", "response"), 
      term = c(".Dtreat", ".Dtreat", ".Dtreat"), 
      contrast = c("mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"), 
      first.treat = c(2004, 2006, 2007), 
      estimate = c(-0.0876269608794944, -0.0212783329360811, -0.0459545277371075), 
      std.error = c(0.0230520757698713, 0.0185949856745256, 0.0179750856581946), 
      statistic = c(-3.80126118594584, -1.14430488458142, -2.5565679413693), 
      p.value = c(0.000143961451107563, 0.252497218285087, 0.010571042540403), 
      conf.low = c(-0.132808199157331, -0.0577238351511894, -0.0811850482461914), 
      conf.high = c(-0.0424457226016582, .0151671692790273, -0.0107240072280236)
      ), 
    row.names = c(NA, -3L), 
    class = c("marginaleffects.summary", "data.frame"), 
    conf_level = 0.95, 
    FUN = "mean", 
    type = structure("response", names = NA_character_), 
    model_type = "etwfe"
    )

event_known =
  structure(
    list(
      type = c("response", "response", "response", "response"), 
      term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"), 
      contrast = c("mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"),
      event = c(0, 1, 2, 3), 
      estimate = c(-0.0332122037840197, -0.0573456479255145, -0.137870386660577, -0.109539455365848), 
      std.error = c(0.013368671117722, 0.0171531166703277, 0.030794594509294, 0.0323218247068719),
      statistic = c(-2.48433097736935, -3.34316200534645, -4.4770969989219, -3.38902448606371), 
      p.value = c(0.0129795111476838, 0.000828295236610263, 7.56648975457471e-06, 0.000701417491255723),
      conf.low = c(-0.0594143176959156, -0.0909651388219705, -0.198226682817308, -0.172889067705934),
      conf.high = c(-0.00701008987212372, -0.0237261570290585, -0.0775140905038458, -0.046189843025762)
      ), 
    row.names = c(NA, -4L), 
    class = c("marginaleffects.summary", "data.frame"), 
    conf_level = 0.95, 
    FUN = "mean", 
    type = structure("response", names = NA_character_), 
    model_type = "etwfe"
    )

event_pre_known =
  structure(
    list(
      type = c("response", "response", "response", "response", "response", "response", "response", "response"), 
      term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"), 
      contrast = c("mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"), 
      estimate = c(0, 0, 0, 0, -0.0332122037837577, -0.057345647925759, -0.137870386660868, -0.109539455365126), 
      std.error = c(NA, NA, NA, NA, 0.0133686711625469, 0.017153116591293, 0.0307945949146719, 0.0323218247953089), 
      statistic = c(NA, NA, NA, NA, -2.48433096901983, -3.34316202076467, -4.47709693999516, -3.38902447676853), 
      p.value = c(NA, NA, NA, NA, 0.0129795111476838, 0.000828295236610263, 7.56648975457471e-06, 0.000701417491255723), 
      conf.low = c(NA, NA, NA, NA, -0.0594143177835088, -0.0909651386673097, -0.198226683612125, -0.172889067878545), 
      conf.high = c(NA, NA, NA, NA, -0.00701008978400652, -0.0237261571842083, -0.0775140897096109, -0.0461898428517068), 
      event = c(-4, -3, -2, -1, 0, 1, 2, 3), 
      predicted = c(8.58422618817666, 8.55899805002257, 8.59601363947542, 8.59460357323378, 8.55577814211513, 6.00937159256964, 5.31227368284963, 5.38860968779881), 
      predicted_hi = c(8.58422618817666, 8.55899805002257, 8.59601363947542, 8.59460357323378, 8.55577814211513, 6.00937159256964, 5.31227368284963, 5.38860968779881), 
      predicted_lo = c(8.58422618817666, 8.55899805002257, 8.59601363947542, 8.59460357323378, 8.65009313385245, 6.07321374319202, 5.48092092928689, 5.50497348262897)
      ), 
    class = "data.frame", row.names = c(NA, -8L)
    )

event_pois_known =
  structure(
    list(
      type = c("response", "response", "response", "response"),
      term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"),
      contrast = c("mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"),
      event = c(0, 1, 2, 3),
      estimate = c(-25.3497484355617, 1.09175116987649, -75.1246321555113, -101.823979345012),
      std.error = c(15.9023512157895, 41.8416889332186, 22.2960121026089, 28.1041995554813),
      statistic = c(-1.59408807487485, 0.0260924259443489, -3.36942013709802, -3.62308768637932),
      p.value = c(0.110916309493442, 0.979183618228332, 0.000753265162517243, 0.000291107080688969),
      conf.low = c(-56.5177840880158, -80.91645219156, -118.824012875494, -156.907198288082),
      conf.high = c(5.81828721689249, 83.099954531313, -31.4252514355288, -46.7407604019416)
    ),
    row.names = c(NA, -4L),
    class = c("marginaleffects.summary", "data.frame"),
    conf_level = 0.95,
    FUN = "mean",
    type = structure("response", names = NA_character_),
    model_type = "etwfe"
  )

event_pois_link_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c("mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"),
    event = c(0, 1, 2, 3),
    estimate = c(-0.0325653634932165, -0.0675071047000078, -0.13297134493384, -0.117022779216551),
    std.error = c(0.012852983394089, 0.018400421028425, 0.0237301206925325, 0.0225051243923356),
    statistic = c(-2.53368128587118, -3.6687804369108, -5.60348371829748, -5.19982814475821),
    p.value = c(0.0112871339541832, 0.000243710265677802, 2.10085859293411e-08, 1.99472873101063e-07),
    s.value = c(6.46917698842941, 12.002545357333, 25.5044457004379, 22.2573041007391),
    conf.low = c(-0.0577567480395224, -0.103571267216094, -0.179481526839992, -0.161132012493123),
    conf.high = c(-0.00737397894691056, -0.0314429421839213, -0.0864611630276877, -0.0729135459399795),
    predicted_lo = c(8.59999694263988, 6.24569002837391, 5.68530511263303, 5.70993143759263),
    predicted_hi = c(8.53326519229116, 6.15518645002986, 5.52751652841592, 5.57772190861547),
    predicted = c(8.53326519229116, 6.15518645002986, 5.52751652841592, 5.57772190861547)
  ),
  row.names = c(NA, -4L),
  class = c("slopes", "marginaleffects", "data.frame")
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
e3 = e3[order(e3$year),]
e4 = e4[order(e4$first.treat),]

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
