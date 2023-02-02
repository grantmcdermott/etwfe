# "Baker" dataset ----

## Taken from: https://gist.github.com/grantmcdermott/60fcb75261ae99d43377b3ab0d71c590
set.seed(1234)
# Create the base dataset as a cross-join of 1,000 firms over 30 periods
baker <- expand.grid(n = 1:30, id = 1:1000)
# Add additional columns
baker <-
  baker |>
  within({
    year       = n + 1980 - 1
    state      = 1 + (id-1) %/% 25
    firms      = runif(id*year, 0, 5)
    grp        = 1 + (state-1) %/% 10
    treat_date = 1980 + grp*6
    time_til   = year - treat_date
    treat      = time_til>=0
    e          = rnorm(id*year, 0, 0.5^2)
    te         = rnorm(id*year, 10-2*(grp-1), 0.2^2)
    y          = firms + n + treat*te*(year - treat_date + 1) + e 
    y2         = firms + n + te*treat + e
  })

bmod_known <-
  structure(list(type = c(
    "response", "response", "response", "response",
    "response", "response", "response", "response", "response", "response",
    "response", "response", "response", "response", "response", "response",
    "response", "response"
  ), term = c(
    ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat",
    ".Dtreat", ".Dtreat", ".Dtreat"
  ), contrast = c(
    "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)",
    "mean(TRUE) - mean(FALSE)", "mean(TRUE) - mean(FALSE)"
  ), event = c(
    0,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
  ), estimate = c(
    8.02450804378463,
    15.9827570261535, 24.0750003572724, 32.0048328658599, 40.0819376702021,
    47.9821913988497, 63.2131945251307, 71.8270779908461, 81.0618772488699,
    90.055591307349, 99.0817897674036, 107.962866128519, 130.375113846917,
    139.989417133701, 149.986563615487, 160.268524220376, 170.142927273913,
    179.911466863814
  ), std.error = c(
    0.0700264615385886, 0.0710038869542059,
    0.0704679216673054, 0.0710268461205943, 0.0705561608542587, 0.0684357636888592,
    0.0953356490103743, 0.0926117378493487, 0.0932011123447119, 0.0935750633693525,
    0.0928244145512079, 0.0935570891242416, 0.139533985174089, 0.142620188759097,
    0.142907195564741, 0.146226058561055, 0.149355448566298, 0.142642230223049
  ), statistic = c(
    114.592510709151, 225.096930770305, 341.644819197816,
    450.601914824148, 568.085581541145, 701.127434143924, 663.059361123685,
    775.57207821418, 869.752250907221, 962.388782488859, 1067.41087726165,
    1153.97846533197, 934.360999467297, 981.554002639557, 1049.53821970104,
    1096.03257994852, 1139.18125456527, 1261.2777196661
  ), p.value = c(
    0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ), conf.low = c(
    7.88725870120422,
    15.8435919649609, 23.9368857687391, 31.865622805528, 39.9436501360404,
    47.8480597667651, 63.0263400866276, 71.6455623201158, 80.8792064253552,
    89.872187553294, 98.8998572579972, 107.779497603337, 130.101632261356,
    139.709886700265, 149.706470659049, 159.981926411995, 169.850195973828,
    179.631893229903
  ), conf.high = c(
    8.16175738636504, 16.1219220873461,
    24.2131149458057, 32.1440429261917, 40.2202252043639, 48.1163230309344,
    63.4000489636338, 72.0085936615765, 81.2445480723846, 90.238995061404,
    99.26372227681, 108.146234653701, 130.648595432477, 140.268947567137,
    150.266656571926, 160.555122028757, 170.435658573998, 180.191040497726
  )), row.names = c(NA, -18L), class = c(
    "marginaleffects.summary",
    "data.frame"
  ), conf_level = 0.95, FUN = "mean", type = structure("response", names = NA_character_), model_type = "etwfe")

bmod = emfx(
  etwfe(
    fml  = y ~ 0,
    tvar = year,
    gvar = treat_date,
    data = baker,
    vcov = ~id
  ),
  type = "event"
)

for (col in c("estimate", "std.error", "conf.low", "conf.high", "event")) {
  expect_equivalent(bmod[[col]], bmod_known[[col]], tolerance = 1e-6)
}
