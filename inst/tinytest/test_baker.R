# "Baker" dataset ----
 
## Taken from: https://gist.github.com/grantmcdermott/60fcb75261ae99d43377b3ab0d71c590
set.seed(1234)
# Create the base dataset as a cross-join of 1,000 firms over 30 periods
baker = expand.grid(n = 1:30, id = 1:1000)
# Add additional columns
baker = 
  baker |>
  within({
    year       = n + 1980 - 1
    state      = 1 + (id-1) %/% 25
    firms      = runif(id*year, 0, 5)
    group      = 1 + (state-1) %/% 10
    treat_date = 1980 + group*6
    time_til   = year - treat_date
    treat      = time_til>=0
    e          = rnorm(id*year, 0, 0.5^2)
    te         = rnorm(id*year, 10-2*(group-1), 0.2^2)
    y          = firms + n + treat*te*(year - treat_date + 1) + e 
    y2         = firms + n + te*treat + e
  })

bmod_known = 
  structure(
    list(
      type = c("response", "response", "response", "response", 
               "response", "response", "response", "response", "response", "response", 
               "response", "response", "response", "response", "response", "response", 
               "response", "response"), 
      term = c(".Dtreat", ".Dtreat", ".Dtreat", 
               ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", 
               ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", ".Dtreat", 
               ".Dtreat", ".Dtreat", ".Dtreat"), 
      contrast = c("mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", 
                   "mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", 
                   "mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", 
                   "mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", "mean(dY/dX)", 
                   "mean(dY/dX)", "mean(dY/dX)"), 
      event = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17), 
      estimate = c(8.02450804378907, 15.9827570261465, 24.0750003572524, 
                   32.0048328658373, 40.0819376702088, 47.9821913988114, 
                   63.2131945251047, 71.8270779908181, 81.0618772488425, 
                   90.0555913074186, 99.08178976751, 107.962866128517, 
                   130.37511384681, 139.989417133677, 149.986563615414, 
                   160.268524220442, 170.142927273957, 179.9114668637), 
      std.error = c(0.0700264498141906, 0.0710039140956521, 0.07046791247896, 
                    0.0710268563054412, 0.0705561521299963, 0.068435790682685, 
                    0.0953356619737727, 0.0926118112872795, 0.0932011282544412, 
                    0.0935750172534272, 0.092824266948099, 0.0935569676272568, 
                    0.13953409585941, 0.142620301892549, 0.142907308925861, 
                    0.146225758955408, 0.149355142548778, 0.142642343373986), 
      statistic = c(114.592529895224, 225.096844726271, 341.644863744767, 
                    450.60185021008, 568.085651784975, 701.127157590529, 
                    663.059270962999, 775.571463212314, 869.752102437448, 
                    962.389256776977, 1067.41257459011, 1153.97996393657, 
                    934.360258285342, 981.553224022379, 1049.53738715509, 
                    1096.03482563777, 1139.18358866278, 1261.27671915766), 
      p.value = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 
      conf.low = c(7.88725872418805,  15.8435919117577, 23.936885786728, 
                   31.8656227855436, 39.9436501531463, 47.8480597138198, 
                   63.0263400611938, 71.645562176152, 80.8792063941453, 
                   89.8721876437491, 98.8998575474004, 107.779497841465, 
                   130.10163204431, 139.709886478503, 149.706470436792, 
                   159.981926999277, 169.850196573656, 179.631893008017), 
      conf.high = c(8.16175736339008, 16.1219221405354, 24.2131149277769, 
                    32.1440429461311, 40.2202251872714, 48.1163230838029, 
                    63.4000489890155, 72.0085938054842, 81.2445481035397, 
                    90.238994971088, 99.2637219876196, 108.146234415569, 
                    130.64859564931, 140.26894778885, 150.266656794036, 
                    160.555121441606, 170.435657974259, 180.191040719384)
      ), 
    row.names = c(NA, -18L), 
    class = c("marginaleffects.summary", "data.frame"), 
    conf_level = 0.95, 
    FUN = "mean", 
    type = structure("response", names = NA_character_), 
    model_type = "etwfe"
    )

bmod = emfx(
  etwfe(
  fml  = y ~ 0,
  tvar = year, 
  gvar = treat_date,
  data = baker,
  vcov = ~id
  ), 
  "event"
  )

expect_equal(bmod, bmod_known)
