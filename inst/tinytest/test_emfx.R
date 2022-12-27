data("mpdta", package = "did")

# We'll continue with model 3 from the etwfe tests...
m3 = etwfe(lemp ~ lpop, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal)

# Known outputs ----

# from m3 |> emfx(...) |> dput()

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


# Tests ----

expect_equal(summary(emfx(m3)), simple_known)
expect_equal(summary(emfx(m3, type = "simple")), simple_known)
expect_equal(summary(emfx(m3, type = "calendar")), calendar_known)
expect_equal(summary(emfx(m3, type = "group")), group_known)
expect_equal(summary(emfx(m3, type = "event")), event_known)
