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
# Never-treated variant
m3n = etwfe(
  lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  cgroup = "never",
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
# Conflicting column names variant (test for data.table scoping fix)
mpdta_conflict = mpdta
mpdta_conflict[["gvar"]] = mpdta_conflict[["first.treat"]]
m3_conflict = etwfe(
  lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta_conflict,
  cgroup = "never",
  vcov = ~countyreal
)

# Known outputs ----

# from m3 |> emfx(...) |> c() |> data.frame() |> dput()

simple_known = structure(
  list(
    term = ".Dtreat",
    contrast = "TRUE - FALSE",
    .Dtreat = TRUE,
    estimate = -0.0506270331228907,
    std.error = 0.0129994832517616,
    statistic = -3.89454197081489,
    p.value = 9.83844565099828e-05,
    s.value = 13.3112100682957,
    conf.low = -0.0761055521139752,
    conf.high = -0.0251485141318064
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
      0.0216379981422621,
      0.0281393736692518,
      0.0204296012374646,
      0.0151408126706727
    ),
    statistic = c(
      -0.981976340087138,
      -2.90873564678176,
      -2.16673790077932,
      -3.46297855516028
    ),
    p.value = c(
      0.326111504437516,
      0.00362893571910548,
      0.0302548449033547,
      0.000534230971793967
    ),
    s.value = c(
      1.61656275805676,
      8.10623778269441,
      5.04669000083016,
      10.8702487615729
    ),
    conf.low = c(
      -0.0636576992789293,
      -0.137002158209113,
      -0.0843068739429684,
      -0.0821077571174246
    ),
    conf.high = c(
      0.0211616948338275,
      -0.0266978403306166,
      -0.00422430865507717,
      -0.0227568620550523
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
    std.error = c(0.023830742628491, 0.0197723735242116, 0.018000166057259),
    statistic = c(-3.6770554004822, -1.07616482714346, -2.55300576620375),
    p.value = c(0.000235941812543894, 0.281853547079017, 0.010679772815401),
    s.value = c(12.0492812704068, 1.82698237122194, 6.54897523203581),
    conf.low = c(-0.13433435815628, -0.0600314729322272, -0.0812342049247752),
    conf.high = c(-0.0409195636029086, 0.017474807060429, -0.0106748505488393)
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
      0.0135262827624164,
      0.0179540214764249,
      0.0338651187581612,
      0.0322874622255034
    ),
    statistic = c(
      -2.45538292871095,
      -3.19402803439039,
      -4.07116206044978,
      -3.39263131304838
    ),
    p.value = c(
      0.014073458466042,
      0.0014030249175933,
      4.67791895195326e-05,
      0.000692247432244214
    ),
    s.value = c(
      6.15087928417919,
      9.47724365334572,
      14.3837736081779,
      10.496424582341
    ),
    conf.low = c(
      -0.0597232308427954,
      -0.0925348833971998,
      -0.20424479975902,
      -0.172821718479294
    ),
    conf.high = c(
      -0.00670117672471337,
      -0.0221564124542969,
      -0.0714959735626844,
      -0.0462571922509255
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
      0.0135262827624164,
      0.0179540214764249,
      0.0338651187581612,
      0.0322874622255034
    ),
    statistic = c(
      NA,
      NA,
      NA,
      NA,
      -2.45538292871095,
      -3.19402803439039,
      -4.07116206044978,
      -3.39263131304838
    ),
    p.value = c(
      NA,
      NA,
      NA,
      NA,
      0.014073458466042,
      0.0014030249175933,
      4.67791895195326e-05,
      0.000692247432244214
    ),
    s.value = c(
      NA,
      NA,
      NA,
      NA,
      6.15087928417919,
      9.47724365334572,
      14.3837736081779,
      10.496424582341
    ),
    conf.low = c(
      NA,
      NA,
      NA,
      NA,
      -0.0597232308427954,
      -0.0925348833971998,
      -0.20424479975902,
      -0.172821718479294
    ),
    conf.high = c(
      NA,
      NA,
      NA,
      NA,
      -0.00670117672471337,
      -0.0221564124542969,
      -0.0714959735626844,
      -0.0462571922509255
    )
  ),
  class = "data.frame",
  row.names = c(NA, -8L)
)

event_never_window_known = structure(
  list(
    term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"),
    contrast = c(
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE",
      "TRUE - FALSE"
    ),
    event = c(-2, -1, 0, 1, 2, 3),
    estimate = c(
      0.0234649547538384,
      0,
      -0.0211467366918433,
      -0.0533558653415615,
      -0.141080104628566,
      -0.107544274673025
    ),
    std.error = c(
      0.0144561133050532,
      NA,
      0.0114925426876228,
      0.0163093913795821,
      0.0348711755822492,
      0.0327704795245811
    ),
    statistic = c(
      1.62318558651834,
      NA,
      -1.84003986468701,
      -3.27148108103889,
      -4.04575131961946,
      -3.28174247777963
    ),
    p.value = c(
      0.104549738061554,
      NA,
      0.0657623848537577,
      0.00106985746444132,
      5.21555772189475e-05,
      0.00103167779232963
    ),
    s.value = c(
      3.25773864747704,
      NA,
      3.92659357089044,
      9.86836568340137,
      14.2268189398913,
      9.92079181776706
    ),
    conf.low = c(
      -0.00486850668049626,
      NA,
      -0.0436717064503732,
      -0.0853216850553103,
      -0.209426352868347,
      -0.171773234297312
    ),
    conf.high = c(
      0.051798416188173,
      NA,
      0.00137823306668666,
      -0.0213900456278126,
      -0.0727338563887856,
      -0.0433153150487391
    )
  ),
  class = "data.frame",
  row.names = c(NA, -6L)
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
      22.9464538281836,
      52.5298619412076,
      26.1231658910049,
      39.7575867661742
    ),
    statistic = c(
      -1.10473490262683,
      0.0207834387861714,
      -2.87578590086897,
      -2.56112072253844
    ),
    p.value = c(
      0.269274475068775,
      0.98341840882077,
      0.00403022975699104,
      0.0104335094078306
    ),
    s.value = c(
      1.89285061379258,
      0.0241227333572091,
      7.95492219781377,
      6.58263168640566
    ),
    conf.low = c(
      -70.3239715116606,
      -101.864886347527,
      -126.325096463948,
      -179.747417518896
    ),
    conf.high = c(
      19.6244746406417,
      104.048388687729,
      -23.9241678468783,
      -23.9005411710413
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
      0.0128836401592657,
      0.0188097704891731,
      0.02774529811699,
      0.0250857256527609
    ),
    statistic = c(
      -2.5276523630614,
      -3.58893824563127,
      -4.79257221795124,
      -4.66491505315699
    ),
    p.value = c(
      0.0114827987909728,
      0.00033202747310551,
      1.64656471243406e-06,
      3.08744555253739e-06
    ),
    s.value = c(
      6.44438186572848,
      11.5564097594434,
      19.2121093562229,
      18.3051548744979
    ),
    conf.low = c(
      -0.0578168341953356,
      -0.104373577416384,
      -0.187351129983889,
      -0.166189898022395
    ),
    conf.high = c(
      -0.00731389279146613,
      -0.0306406319838961,
      -0.0785915598846338,
      -0.0678556604114668
    )
  ),
  class = "data.frame",
  row.names = c(NA, -4L)
)

# Tests ----

mod_default = emfx(m3)
mod_simple = emfx(m3, type = "simple")
mod_calendar = emfx(m3, type = "calendar")
mod_group = emfx(m3, type = "group")
mod_event = emfx(m3, type = "event")
mod_event_pre = emfx(m3, type = "event", post_only = FALSE)
mod_event_never_window = emfx(m3n, type = "event", window = c(2, 3))
mod_pois_event = emfx(m3p, type = "event")
mod_pois_event_link = emfx(m3p, type = "event", predict = "link")
mod_event_conflict = emfx(m3_conflict, type = "event", window = c(2, 3))


# match order
mod_calendar = mod_calendar[order(mod_calendar$year), ]
mod_group = mod_group[order(mod_group$first.treat), ]

for (col in c("estimate", "std.error", "conf.low", "conf.high")) {
  expect_equivalent(mod_default[[col]], simple_known[[col]], tolerance = tol)
  expect_equivalent(mod_simple[[col]], simple_known[[col]], tolerance = tol)
  expect_equivalent(mod_calendar[[col]], calendar_known[[col]], tolerance = tol)
  expect_equivalent(mod_group[[col]], group_known[[col]], tolerance = tol)
  expect_equivalent(mod_event[[col]], event_known[[col]], tolerance = tol)
  expect_equivalent(
    mod_event_pre[[col]],
    event_pre_known[[col]],
    tolerance = tol
  )
  expect_equivalent(
    mod_event_never_window[[col]],
    event_never_window_known[[col]],
    tolerance = tol
  )
  expect_equivalent(
    mod_pois_event[[col]],
    event_pois_known[[col]],
    tolerance = tol
  )
  expect_equivalent(
    mod_pois_event_link[[col]],
    event_pois_link_known[[col]],
    tolerance = tol
  )
  expect_equivalent(mod_event_conflict[[col]],
    event_never_window_known[[col]],
    tolerance = tol
  )

}

# Unconditional standard errors (default) ----

mod_uncond = emfx(m3)
mod_uncond_cl = emfx(
  m3,
  vcov = marginaleffects::vcovUnconditional(cluster = ~countyreal)
)
expect_equivalent(mod_uncond$estimate, simple_known$estimate, tolerance = tol)
# inherits the model's cluster variable
expect_equivalent(mod_uncond$std.error, mod_uncond_cl$std.error)
# string and bare function forms are equivalent
expect_equivalent(
  emfx(m3, vcov = "unconditional")$std.error,
  mod_uncond$std.error
)
expect_equivalent(
  emfx(m3, vcov = marginaleffects::vcovUnconditional)$std.error,
  mod_uncond$std.error
)
# compressed data fall back to the model vcov (with a warning)
expect_warning(mod_compress <- emfx(m3, compress = TRUE), "compressed data")
expect_silent(mod_compress_cond <- emfx(m3, compress = TRUE, vcov = TRUE))
expect_equivalent(mod_compress$std.error, mod_compress_cond$std.error)
# multiway clustering falls back to the model vcov (with a warning)
m3_2way = etwfe(
  lemp ~ lpop,
  tvar = year,
  gvar = first.treat,
  data = mpdta,
  vcov = ~ countyreal + year
)
expect_warning(mod_2way <- emfx(m3_2way), "one-way clustering")
expect_equivalent(mod_2way$std.error, emfx(m3_2way, vcov = TRUE)$std.error)
