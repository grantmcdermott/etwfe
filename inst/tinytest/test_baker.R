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
      0.0700264602691546,
      0.0710038855448996,
      0.0704679193589678,
      0.0710268470165146,
      0.0705561617718485,
      0.0684357623144868,
      0.0953356487909659,
      0.0926117389518237,
      0.0932011112149289,
      0.0935750634579356,
      0.0928244155305954,
      0.0935570888128866,
      0.139533985805187,
      0.142620189667287,
      0.142907194715239,
      0.146226056769938,
      0.149355448469947,
      0.142642228495734
    ),
    statistic = c(
      114.592512786475,
      225.096935238096,
      341.644830389172,
      450.601909140334,
      568.085574153136,
      701.127448224431,
      663.059362649671,
      775.572068981561,
      869.752261450349,
      962.388781577811,
      1067.41086599943,
      1153.97846917238,
      934.360995241278,
      981.553996389133,
      1049.53822593995,
      1096.03259337377,
      1139.18125530017,
      1261.27773493945
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
      7.88725870369228,
      15.8435919677231,
      23.9368857732634,
      31.8656228037721,
      39.9436501342419,
      47.8480597694588,
      63.0263400870576,
      71.645562317955,
      80.8792064275695,
      89.8721875531204,
      98.8998572560777,
      107.779497603947,
      130.101632260119,
      139.709886698485,
      149.706470660714,
      159.981926415505,
      169.850195974017,
      179.631893233288
    ),
    conf.high = c(
      8.16175738387701,
      16.1219220845839,
      24.2131149412815,
      32.1440429279477,
      40.2202252061623,
      48.1163230282407,
      63.4000489632037,
      72.0085936637373,
      81.2445480701703,
      90.2389950615776,
      99.2637222787296,
      108.146234653091,
      130.648595433714,
      140.268947568917,
      150.266656570261,
      160.555122025246,
      170.435658573809,
      180.19104049434
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
