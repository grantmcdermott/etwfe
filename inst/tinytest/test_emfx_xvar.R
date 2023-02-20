set.seed(123)
tol <- 5e-4
data("mpdta", package = "did")
mpdta$xvar = rep(sample(1:3, size = 500, replace = TRUE), each = 5) # a categorical var for every id
mpdta$emp = exp(mpdta$lemp)

# We'll continue with model 3 from the etwfe tests...
x3   = etwfe(lemp ~ lpop, tvar = year, gvar = first.treat, data = mpdta, vcov = ~countyreal)
x3x  = etwfe(lemp ~ lpop, tvar = year, gvar = first.treat, xvar = xvar, data = mpdta, vcov = ~countyreal)
x3xi = etwfe(lemp ~ lpop, tvar = year, gvar = first.treat, ivar = countyreal, xvar = xvar, data = mpdta, vcov = ~countyreal)

# Poisson version
x3xp = etwfe(emp ~ lpop, tvar = year, gvar = first.treat, xvar = xvar, data = mpdta, vcov = ~countyreal, family = "poisson")

# Known outputs ----

# from m3 |> emfx(...) |> c() |> data.frame() |> dput()
simple_known = structure(list(
  type = c("response", "response", "response"),
  term = c(".Dtreat", ".Dtreat", ".Dtreat"), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ),
  .Dtreat = c(TRUE, TRUE, TRUE), xvar = 1:3, estimate = c(
    -0.00435892925830217,
    -0.0773947714895238, -0.121365807493048
  ), std.error = c(
    0.0562814968939525,
    0.0195453352369493, 0.0570436863668803
  ), statistic = c(
    -0.077448708702887,
    -3.95975666578558, -2.12759404629771
  ), p.value = c(
    0.938266593173213,
    7.5026170940551e-05, 0.0333707562896293
  ), conf.low = c(
    -0.114668636166452,
    -0.115702924619706, -0.233169378317532
  ), conf.high = c(
    0.105950777649848,
    -0.0390866183593415, -0.00956223666856447
  )
), row.names = c(
  NA,
  -3L
), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

calendar_known = structure(list(type = c(
  "response", "response", "response", "response",
  "response", "response", "response", "response", "response", "response",
  "response", "response"
), term = c(
  ".Dtreat", ".Dtreat", ".Dtreat",
  ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
  ".Dtreat", ".Dtreat", ".Dtreat"
), contrast = c(
  "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
), year = c(
  2004L,
  2004L, 2004L, 2005L, 2005L, 2005L, 2006L, 2006L, 2006L, 2007L,
  2007L, 2007L
), xvar = c(
  1L, 2L, 3L, 1L, 2L, 3L, 1L, 2L, 3L, 1L,
  2L, 3L
), estimate = c(
  0.0297449113971338, -0.034271003750594,
  -0.0787299577386582, 0.00129925058550562, -0.115067166224145,
  -0.160822626695699, 0.0174004166189512, -0.0893685084965101,
  -0.145954538817452, -0.0321191666762202, -0.0712294044863038,
  -0.106032996794025
), std.error = c(
  0.0751990761596778, 0.0335914585691411,
  0.0841916485006435, 0.0853217834254711, 0.0348288084703906, 0.0859101470752094,
  0.0648818450431097, 0.0237557836911019, 0.0623970349913735, 0.0555521585932018,
  0.0218796416820106, 0.0577985559584028
), statistic = c(
  0.395548893898289,
  -1.02022970154911, -0.935127879555137, 0.0152276538691965, -3.30379278757034,
  -1.87198639707727, 0.268186217691401, -3.76196843928936, -2.33912619145493,
  -0.578180353196046, -3.25551055732638, -1.83452674614114
), p.value = c(
  0.692437845127517,
  0.307619534353968, 0.349722400298595, 0.987850559620626, 0.000953863072144048,
  0.0612084854722056, 0.788555983229734, 0.000168581324606551,
  0.0193289035310584, 0.563142361697557, 0.00113188688241009, 0.0665758413151017
), conf.low = c(
  -0.117642569546519, -0.10010905273428, -0.243742556598975,
  -0.165928372025144, -0.183330376450555, -0.329203420869649, -0.109765662916052,
  -0.135928988955594, -0.268250480142629, -0.140999396782353, -0.114112714177686,
  -0.219316084830917
), conf.high = c(
  0.177132392340787, 0.0315670452330919,
  0.0862826411216587, 0.168526873196155, -0.0468039559977362, 0.00755816747825003,
  0.144566496153955, -0.0428080280374265, -0.0236585974922742,
  0.0767610634299126, -0.0283460947949217, 0.00725009124286739
)), row.names = c(
  NA,
  -12L
), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

group_known = structure(list(
  type = c(
    "response", "response", "response", "response",
    "response", "response", "response", "response", "response"
  ),
  term = c(
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"
  ), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ),
  first.treat = c(
    2004, 2004, 2004, 2006, 2006, 2006, 2007,
    2007, 2007
  ), xvar = c(1L, 2L, 3L, 1L, 2L, 3L, 1L, 2L, 3L),
  estimate = c(
    -0.023443813191955, -0.115193593030453, -0.14508535869795,
    0.0554422451375567, -0.0185554686187475, -0.110769854727957,
    -0.0476217423154131, -0.0438780910673637, -0.0476795082036201
  ), std.error = c(
    0.0817545295083345, 0.0296715893385384,
    0.0833652799392775, 0.0723220787270028, 0.0289402405489588,
    0.0750252628818444, 0.0702349264115441, 0.0195236463892834,
    0.084183831966556
  ), statistic = c(
    -0.286758584911983, -3.88228590373606,
    -1.74035712233713, 0.76660193005288, -0.641164975369048,
    -1.47643407664437, -0.678035056751847, -2.24743319933558,
    -0.566373697773248
  ), p.value = c(
    0.774297176131585, 0.000103479111297221,
    0.0817963295621704, 0.443318227599585, 0.5214155027696, 0.139827400371041,
    0.497749465877656, 0.024612355266436, 0.571139770869708
  ),
  conf.low = c(
    -0.183679746601308, -0.173348839498051, -0.308478304940034,
    -0.0863064244544392, -0.0752772977986323, -0.257816667907022,
    -0.18527966853886, -0.0821437348372547, -0.212676786938642
  ), conf.high = c(
    0.136792120217398, -0.0570383465628549,
    0.0183075875441329, 0.197190914729553, 0.0381663605611374,
    0.0362769584511076, 0.0900361839080343, -0.00561244729747274,
    0.117317770531401
  )
), row.names = c(NA, -9L), class = c(
  "marginaleffects.summary",
  "data.frame"
), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

event_known = structure(list(
  type = c(
    "response", "response", "response", "response",
    "response", "response", "response", "response", "response"
  ),
  term = c(
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat"
  ), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ),
  first.treat = c(
    2004, 2004, 2004, 2006, 2006, 2006, 2007,
    2007, 2007
  ), xvar = c(1L, 2L, 3L, 1L, 2L, 3L, 1L, 2L, 3L),
  estimate = c(
    -0.023443813191955, -0.115193593030453, -0.14508535869795,
    0.0554422451375567, -0.0185554686187475, -0.110769854727957,
    -0.0476217423154131, -0.0438780910673637, -0.0476795082036201
  ), std.error = c(
    0.0817545295083345, 0.0296715893385384,
    0.0833652799392775, 0.0723220787270028, 0.0289402405489588,
    0.0750252628818444, 0.0702349264115441, 0.0195236463892834,
    0.084183831966556
  ), statistic = c(
    -0.286758584911983, -3.88228590373606,
    -1.74035712233713, 0.76660193005288, -0.641164975369048,
    -1.47643407664437, -0.678035056751847, -2.24743319933558,
    -0.566373697773248
  ), p.value = c(
    0.774297176131585, 0.000103479111297221,
    0.0817963295621704, 0.443318227599585, 0.5214155027696, 0.139827400371041,
    0.497749465877656, 0.024612355266436, 0.571139770869708
  ),
  conf.low = c(
    -0.183679746601308, -0.173348839498051, -0.308478304940034,
    -0.0863064244544392, -0.0752772977986323, -0.257816667907022,
    -0.18527966853886, -0.0821437348372547, -0.212676786938642
  ), conf.high = c(
    0.136792120217398, -0.0570383465628549,
    0.0183075875441329, 0.197190914729553, 0.0381663605611374,
    0.0362769584511076, 0.0900361839080343, -0.00561244729747274,
    0.117317770531401
  )
), row.names = c(NA, -9L), class = c(
  "marginaleffects.summary",
  "data.frame"
), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

event_known = structure(list(
  type = c(
    "response", "response", "response", "response",
    "response", "response", "response", "response", "response", "response",
    "response", "response"
  ), term = c(
    ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat"
  ), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ), event = c(
    0,
    0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3
  ), xvar = c(
    1L, 2L, 3L, 1L, 2L,
    3L, 1L, 2L, 3L, 1L, 2L, 3L
  ), estimate = c(
    0.0250108418126098,
    -0.0238160653500197, -0.076457711048568, 0.00963719225225557,
    -0.0794395011147682, -0.139699334474095, -0.0581085231182055,
    -0.185437915760917, -0.188945410431479, -0.0667108916322539,
    -0.125998286386154, -0.151843439925966
  ), std.error = c(
    0.0436590594694561,
    0.015919635481548, 0.0471729996000754, 0.059520874193763, 0.0240702213294394,
    0.0601483637197164, 0.0943423621214483, 0.0367160243098084, 0.0872431481579155,
    0.0827173401472563, 0.0474933135796206, 0.0861547110338919
  ),
  statistic = c(
    0.572867169300965, -1.49601825856027, -1.62079392230224,
    0.161912814332714, -3.30032283573598, -2.32257913324252,
    -0.615932459306048, -5.05059900266432, -2.16573352086603,
    -0.806492224163553, -2.65296895267, -1.76245080627377
  ), p.value = c(
    0.566734635309001,
    0.134648897206455, 0.105061842395579, 0.871374511595225,
    0.000965736663406906, 0.0202017727738227, 0.537939097405591,
    4.40426770261406e-07, 0.0303315559600833, 0.419959089762297,
    0.00797872094250529, 0.0779931610270766
  ), conf.low = c(
    -0.0605593423464165,
    -0.0550179775408598, -0.168915091307438, -0.107021577495859,
    -0.126616268020377, -0.257587961093755, -0.24301615509268,
    -0.257400001063639, -0.359938838718886, -0.228833899217825,
    -0.219083470508677, -0.32070357065085
  ), conf.high = c(
    0.110581025971636,
    0.0073858468408204, 0.0159996692103021, 0.126295962000371,
    -0.032262734209159, -0.021810707854435, 0.126799108856269,
    -0.113475830458196, -0.0179519821440731, 0.0954121159533175,
    -0.0329131022636306, 0.0170166907989175
  )
), row.names = c(
  NA,
  -12L
), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

event_pre_known = structure(list(
  type = c(
    "response", "response", "response", "response",
    "response", "response", "response", "response", "response", "response",
    "response", "response"
  ), term = c(
    ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat"
  ), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ), event = c(
    0,
    0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3
  ), xvar = c(
    1L, 2L, 3L, 1L, 2L,
    3L, 1L, 2L, 3L, 1L, 2L, 3L
  ), estimate = c(
    0.0250108418126098,
    -0.0238160653500197, -0.076457711048568, 0.00963719225225557,
    -0.0794395011147682, -0.139699334474095, -0.0581085231182055,
    -0.185437915760917, -0.188945410431479, -0.0667108916322539,
    -0.125998286386154, -0.151843439925966
  ), std.error = c(
    0.0436590594694561,
    0.015919635481548, 0.0471729996000754, 0.059520874193763, 0.0240702213294394,
    0.0601483637197164, 0.0943423621214483, 0.0367160243098084, 0.0872431481579155,
    0.0827173401472563, 0.0474933135796206, 0.0861547110338919
  ),
  statistic = c(
    0.572867169300965, -1.49601825856027, -1.62079392230224,
    0.161912814332714, -3.30032283573598, -2.32257913324252,
    -0.615932459306048, -5.05059900266432, -2.16573352086603,
    -0.806492224163553, -2.65296895267, -1.76245080627377
  ), p.value = c(
    0.566734635309001,
    0.134648897206455, 0.105061842395579, 0.871374511595225,
    0.000965736663406906, 0.0202017727738227, 0.537939097405591,
    4.40426770261406e-07, 0.0303315559600833, 0.419959089762297,
    0.00797872094250529, 0.0779931610270766
  ), conf.low = c(
    -0.0605593423464165,
    -0.0550179775408598, -0.168915091307438, -0.107021577495859,
    -0.126616268020377, -0.257587961093755, -0.24301615509268,
    -0.257400001063639, -0.359938838718886, -0.228833899217825,
    -0.219083470508677, -0.32070357065085
  ), conf.high = c(
    0.110581025971636,
    0.0073858468408204, 0.0159996692103021, 0.126295962000371,
    -0.032262734209159, -0.021810707854435, 0.126799108856269,
    -0.113475830458196, -0.0179519821440731, 0.0954121159533175,
    -0.0329131022636306, 0.0170166907989175
  )
), row.names = c(
  NA,
  -12L
), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

event_pois_known = structure(list(type = c(
  "response", "response", "response", "response",
  "response", "response", "response", "response", "response", "response",
  "response", "response"
), term = c(
  ".Dtreat", ".Dtreat", ".Dtreat",
  ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
  ".Dtreat", ".Dtreat", ".Dtreat"
), contrast = c(
  "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
  "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
), event = c(
  0,
  0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3
), xvar = c(
  1L, 2L, 3L, 1L, 2L,
  3L, 1L, 2L, 3L, 1L, 2L, 3L
), estimate = c(
  35.6283159093406, -19.3207674073577,
  -83.9479303651376, 0.234798346655339, -45.4355780181916, -133.959684243576,
  -25.7651664318558, -47.9303149698262, -239.828939425586, -50.8648539871449,
  -41.6797689677772, -171.589087528592
), std.error = c(
  40.8166606957855,
  9.05453441543421, 45.1007970567342, 56.012919787291, 12.2236486926572,
  65.9231526454179, 50.2882479843613, 11.0169897218439, 112.775146113242,
  54.8010377953563, 11.8457959710159, 130.739372139042
), statistic = c(
  0.8728865934155,
  -2.13382229509492, -1.86134028317806, 0.0041918605126636, -3.71702256507787,
  -2.03205822033584, -0.512349653538702, -4.35058179956296, -2.12661164885359,
  -0.928173188564234, -3.51852835130358, -1.31245151878277
), p.value = c(
  0.382724894392288,
  0.0328573301433289, 0.0626961378629304, 0.99665538901099, 0.000201584445011219,
  0.0421477623160634, 0.608406320107726, 1.35776791144922e-05,
  0.0334523638151901, 0.353317739775761, 0.000433947445193013,
  0.189367833768993
), conf.low = c(
  -44.3708690235906, -37.0673287583872,
  -172.343868270387, -109.548507105366, -69.3934892154699, -263.166689175932,
  -124.328321326823, -69.5232180426881, -460.864164158782, -158.272914381461,
  -64.897102439178, -427.833548282493
), conf.high = c(
  115.627500842272,
  -1.57420605632825, 4.44800754011139, 110.018103798677, -21.4776668209133,
  -4.75267931122062, 72.7979884631113, -26.3374118969642, -18.7937146923893,
  56.5432064071716, -18.4624354963763, 84.6553732253099
)), row.names = c(
  NA,
  -12L
), class = c("marginaleffects.summary", "data.frame"), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

# Tests ----

expect_warning(emfx(x3, by_xvar = TRUE))

e1 = emfx(x3x, collapse = TRUE)
e2 = emfx(x3x, collapse = TRUE, by_xvar = TRUE)
e3 = emfx(x3x, type = "calendar", collapse = TRUE)
e4 = emfx(x3x, type = "group", collapse = TRUE)
e5 = emfx(x3x, type = "event", collapse = TRUE)
e6 = emfx(x3x, type = "event", post_only = FALSE, collapse = TRUE)
e7 = emfx(x3xp, type = "event", collapse = TRUE)

for (col in c("estimate", "std.error", "conf.low", "conf.high")) {
  expect_equivalent(e1[[col]], simple_known[[col]], tolerance = tol)
  expect_equivalent(e2[[col]], simple_known[[col]], tolerance = tol)
  expect_equivalent(e3[[col]], calendar_known[[col]], tolerance = tol)
  expect_equivalent(e4[[col]], group_known[[col]], tolerance = tol)
  expect_equivalent(e5[[col]], event_known[[col]], tolerance = tol)
  expect_equivalent(e6[[col]], event_pre_known[[col]], tolerance = tol)
  expect_equivalent(e7[[col]], event_pois_known[[col]], tolerance = tol)
}
