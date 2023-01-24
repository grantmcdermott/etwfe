set.seed(123)
data("mpdta", package = "did")
mpdta$xvar <- rep(sample(1:3, size = 500, replace = T), each = 5) # a categorical var for every id
mpdta$emp <- exp(mpdta$lemp)

# We'll continue with model 3 from the etwfe tests...
x3 <- etwfe(lemp ~ lpop, tvar = year, gvar = first.treat, xvar = xvar, data = mpdta, vcov = ~countyreal)
# Poisson version
x3p <- etwfe(emp ~ lpop, tvar = year, gvar = first.treat, xvar = xvar, data = mpdta, vcov = ~countyreal, family = "poisson")

# Known outputs ----

# from m3 |> emfx(...) |> summary() |> dput()
simple_known <-
  structure(list(
    type = "response", term = ".Dtreat", contrast = "mean(TRUE) - mean(FALSE)",
    .Dtreat = TRUE, estimate = -0.0503754407421413, std.error = 0.0141280076533273,
    statistic = -3.56564364758659, p.value = 0.000362964287092016,
    conf.low = -0.0780658269159691, conf.high = -0.0226850545683135
  ), row.names = c(
    NA,
    -1L
  ), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

calendar_known <-
  structure(list(
    type = c("response", "response", "response", "response"), term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"), contrast = c(
      "mean(TRUE) - mean(FALSE)",
      "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
    ), year = 2004:2007, estimate = c(
      -0.0197793761885192, -0.0799594646181729,
      -0.0432598883150108, -0.0527166656593119
    ), std.error = c(
      0.0261348878733163,
      0.0319709211532094, 0.0200128342561683, 0.0161199199005293
    ),
    statistic = c(
      -0.756818865433663, -2.50100596836091, -2.1616072846692,
      -3.27028086892546
    ), p.value = c(
      0.449158388798187, 0.0123841091342915,
      0.030648459485416, 0.00107440748446871
    ), conf.low = c(
      -0.0710028151602117,
      -0.142621318631033, -0.0824843226856702, -0.0843111280980199
    ), conf.high = c(
      0.0314440627831733, -0.0172976106053127,
      -0.00403545394435143, -0.0211222032206039
    )
  ), row.names = c(
    NA,
    -4L
  ), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

group_known <-
  structure(list(
    type = c("response", "response", "response"),
    term = c(".Dtreat", ".Dtreat", ".Dtreat"), contrast = c(
      "mean(TRUE) - mean(FALSE)",
      "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
    ),
    first.treat = c(2004, 2006, 2007), estimate = c(
      -0.0859666225119282,
      -0.0212314182544491, -0.0464382442339915
    ), std.error = c(
      0.0276476828663129,
      0.0221123040323683, 0.0190823521720057
    ), statistic = c(
      -3.10936084327969,
      -0.960163093966609, -2.43357023365901
    ), p.value = c(
      0.00187492581073191,
      0.336973138012079, 0.0149507346161953
    ), conf.low = c(
      -0.140155085185887,
      -0.0645707377730908, -0.0838389672314324
    ), conf.high = c(
      -0.0317781598379698,
      0.0221079012641926, -0.00903752123655055
    )
  ), row.names = c(
    NA,
    -3L
  ), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

event_known <-
  structure(list(type = c("response", "response", "response", "response"), term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ), event = c(0, 1, 2, 3), estimate = c(
    -0.033334712931385, -0.0568295016874698,
    -0.135383032371474, -0.108744616869547
  ), std.error = c(
    0.0144788008740078,
    0.0196075281029238, 0.0345495349364405, 0.03534184619549
  ), statistic = c(
    -2.30231171914431,
    -2.89835115314692, -3.9185196738692, -3.07693650942955
  ), p.value = c(
    0.0213175994086243,
    0.00375130322649493, 8.90944584226838e-05, 0.00209139841592033
  ), conf.low = c(
    -0.0617126411837673, -0.0952595505950574, -0.203098876529505,
    -0.178013362559862
  ), conf.high = c(
    -0.00495678467900273, -0.0183994527798822,
    -0.0676671882134418, -0.0394758711792328
  )), row.names = c(
    NA,
    -4L
  ), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

event_pre_known <-
  structure(list(type = c("response", "response", "response", "response"), term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ), event = c(0, 1, 2, 3), estimate = c(
    -0.033334712931385, -0.0568295016874698,
    -0.135383032371474, -0.108744616869547
  ), std.error = c(
    0.0144788008740078,
    0.0196075281029238, 0.0345495349364405, 0.03534184619549
  ), statistic = c(
    -2.30231171914431,
    -2.89835115314692, -3.9185196738692, -3.07693650942955
  ), p.value = c(
    0.0213175994086243,
    0.00375130322649493, 8.90944584226838e-05, 0.00209139841592033
  ), conf.low = c(
    -0.0617126411837673, -0.0952595505950574, -0.203098876529505,
    -0.178013362559862
  ), conf.high = c(
    -0.00495678467900273, -0.0183994527798822,
    -0.0676671882134418, -0.0394758711792328
  )), row.names = c(
    NA,
    -4L
  ), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")
event_pois_known <-
  structure(list(
    type = c("response", "response", "response", "response"), term = c(".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"), contrast = c(
      "mean(TRUE) - mean(FALSE)",
      "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
    ), event = c(0, 1, 2, 3), estimate = c(
      -29.7194026243483, -13.8327481361202,
      -112.828099594961, -117.306925992267
    ), std.error = c(
      20.2024635892912,
      53.2410676909672, 37.4920056717972, 47.9716052691938
    ), statistic = c(
      -1.47107814316774,
      -0.259813499917228, -3.00939087075392, -2.44534084973801
    ), p.value = c(
      0.141269985193111,
      0.795007637044144, 0.00261772100961016, 0.0144715302779283
    ),
    conf.low = c(
      -69.3155036583408, -118.183323308875, -186.311080419854,
      -211.329544600458
    ), conf.high = c(
      9.87669840964425, 90.5178270366345,
      -39.3451187700667, -23.2843073840751
    )
  ), row.names = c(
    NA,
    -4L
  ), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

# Tests ----

expect_equal(summary(emfx(x3)), simple_known)
expect_equal(summary(emfx(x3, type = "simple")), simple_known)
expect_equal(summary(emfx(x3, type = "calendar")), calendar_known)
expect_equal(summary(emfx(x3, type = "group")), group_known)
expect_equal(summary(emfx(x3, type = "event")), event_known)
expect_equal(summary(emfx(x3, type = "event", post_only = FALSE)), event_pre_known)
expect_equal(summary(emfx(x3p, type = "event")), event_pois_known)
