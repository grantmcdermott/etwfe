# "Baker" dataset ----

## Taken from: https://gist.github.com/grantmcdermott/60fcb75261ae99d43377b3ab0d71c590
set.seed(1234)
# Create the base dataset as a cross-join of 1,000 firms over 30 periods
baker = expand.grid(n = 1:30, id = 1:1000)
# Add additional columns
baker = baker |>
  within({
    year = n + 1980 - 1
    state = 1 + (id - 1) %/% 25
    firms = runif(id * year, 0, 5)
    grp = 1 + (state - 1) %/% 10
    treat_date = 1980 + grp * 6
    time_til = year - treat_date
    treat = time_til >= 0
    e = rnorm(id * year, 0, 0.5^2)
    te = rnorm(id * year, 10 - 2 * (grp - 1), 0.2^2)
    y = firms + n + treat * te * (year - treat_date + 1) + e
    y2 = firms + n + te * treat + e
  })

bmod_known = structure(
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
      "TRUE - FALSE"
    ),
    event = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17),
    estimate = c(
      8.02450804378465,
      15.9827570261535,
      24.0750003572724,
      32.0048328658599,
      40.0819376702021,
      47.9821913988498,
      63.2131945251307,
      71.8270779908461,
      81.0618772488699,
      90.055591307349,
      99.0817897674036,
      107.962866128519,
      130.375113846917,
      139.989417133701,
      149.986563615487,
      160.268524220376,
      170.142927273913,
      179.911466863814
    ),
    std.error = c(
      0.0885377057764578,
      0.135733856531768,
      0.191124441922262,
      0.24862994220276,
      0.307825782943785,
      0.363510705260489,
      0.318542245224716,
      0.368203049776727,
      0.412539424582113,
      0.454771303224358,
      0.497317975022003,
      0.536273105320642,
      0.139353629702236,
      0.142435844196679,
      0.142722480029991,
      0.146037053210451,
      0.149162398304267,
      0.142457857170807
    ),
    statistic = c(
      90.6337923872254,
      117.750702989958,
      125.965052481695,
      128.72477297911,
      130.209813118618,
      131.996639175911,
      198.44524697356,
      195.074641653295,
      196.494861869222,
      198.023909311887,
      199.232271391395,
      201.320679812883,
      935.570276321439,
      982.824358034483,
      1050.8965622232,
      1097.45109680771,
      1140.65561567901,
      1262.91010153339
    ),
    p.value = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    s.value = c(
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
      7.85097732918906,
      15.7167235558687,
      23.7004033345395,
      31.5175271336637,
      39.4786102221198,
      47.2697235085443,
      62.5888631969361,
      71.1054132742853,
      80.2533148344866,
      89.1642559318268,
      98.1070644474954,
      106.911790156212,
      130.101985751585,
      139.710248008968,
      149.706832694844,
      159.982296855675,
      169.850574345388,
      179.632254594444
    ),
    conf.high = c(
      8.19803875838038,
      16.2487904964387,
      24.4495973800054,
      32.4921385980551,
      40.6852651182851,
      48.6946592891549,
      63.837525853326,
      72.5487427074057,
      81.8704396632542,
      90.946926682871,
      100.05651508731,
      109.013942100823,
      130.648241942248,
      140.268586258434,
      150.26629453613,
      160.554751585076,
      170.435280202436,
      180.190679133184
    )
  ),
  class = "data.frame",
  row.names = c(NA, -18L)
)

bmod = emfx(
  etwfe(
    fml = y ~ 0,
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
