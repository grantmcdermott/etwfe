data("mpdta", package = "did")
# Add exponeniated employment outcome (for Poisson)
mpdta$emp = exp(mpdta$lemp)

# Known outputs ----

# from etwfe(...) |> fixest::coeftable() |> dput()

m1_known =
  structure(
    c(-0.0193723636759116, -0.0783190990620529, -0.136078114440309, 
      -0.104707471576594, 0.00251386194191313, -0.0391927355917248, 
      -0.0431060328087001, 0.0223952764912568, 0.030506236091693, 0.0354768817979489, 
      0.0338947465597152, 0.0199448451562706, 0.0240232361043774, 0.0184422693090335, 
      -0.865020071686749, -2.56731439521572, -3.83568418485349, -3.08919470432157, 
      0.126040684809366, -1.63145112596148, -2.33734970932159, 0.387443428108348, 
      0.010539223223148, 0.000141260031324757, 0.0021189122536199, 
      0.899750485829418, 0.103426076960745, 0.0198154873775247), 
    dim = c(7L, 4L), 
    dimnames = list(
      c(".Dtreat:first.treat::2004:year::2004", ".Dtreat:first.treat::2004:year::2005", 
        ".Dtreat:first.treat::2004:year::2006", ".Dtreat:first.treat::2004:year::2007", 
        ".Dtreat:first.treat::2006:year::2006", ".Dtreat:first.treat::2006:year::2007", 
        ".Dtreat:first.treat::2007:year::2007"), 
      c("Estimate", "Std. Error", "t value", "Pr(>|t|)")), 
    type = "Clustered (countyreal)"
    )

m2_known =
  structure(
    c(
      -0.0105032462209509, -0.0704231581031381, -0.137258738889396,
      -0.100811363085397, -0.00376929367371485, 0.00275081875051886,
      -0.00459460695286396, -0.041224471546218, 0.00330635669251332,
      0.033813012275807, 0.0310871193896906, -0.0260544107191967, 0.0233633078987137,
      0.0311343819027016, 0.0366116000064794, 0.0345251351219756, 0.0314933678411734,
      0.0196530028296998, 0.0178409306056071, 0.0203268606975245, 0.0245699429153858,
      0.0212312006908406, 0.0179638358765074, 0.0167358589135634, -0.449561606022801,
      -2.26190962528879, -3.74905054313674, -2.9199411596576, -0.119685315737715,
      0.139969386579531, -0.257531798897304, -2.02807861772962, 0.13456916460489,
      1.59260951691698, 1.73053904541321, -1.55680152741257, 0.653221784531605,
      0.0241324067083723, 0.000198289769460991, 0.00365931411401919,
      0.904780603080407, 0.888740655516229, 0.796874436233205, 0.0430829502415971,
      0.89300678247844, 0.111881039660844, 0.0841522334691531, 0.120151588094448
    ),
    dim = c(12L, 4L), dimnames = list(
      c(
        ".Dtreat:first.treat::2004:year::2004",
        ".Dtreat:first.treat::2004:year::2005", ".Dtreat:first.treat::2004:year::2006",
        ".Dtreat:first.treat::2004:year::2007", ".Dtreat:first.treat::2006:year::2003",
        ".Dtreat:first.treat::2006:year::2004", ".Dtreat:first.treat::2006:year::2006",
        ".Dtreat:first.treat::2006:year::2007", ".Dtreat:first.treat::2007:year::2003",
        ".Dtreat:first.treat::2007:year::2004", ".Dtreat:first.treat::2007:year::2005",
        ".Dtreat:first.treat::2007:year::2007"
      ),
      c("Estimate", "Std. Error", "t value", "Pr(>|t|)")
    ),
    type = "Clustered (countyreal)"
  )

m3_known =
  structure(
    c(
      -0.0212480022225683, -0.0818499992698808, -0.137870386660868,
      -0.109539455365126, 0.00253680638188832, -0.0450934722536976,
      -0.0459545277368081, 0.00462780039739583, 0.0251130755098716,
      0.0507345526391868, 0.0112496795427372, 0.0389351822929274, 0.0380597297024117,
      -0.0198351447054595, 0.0217284164954528, 0.0273749202444809,
      0.0307945949147437, 0.0323218247953842, 0.0188828504979244, 0.0219870929884107,
      0.0179750857100353, 0.0175839214621387, 0.0179038751608142, 0.0210701784906966,
      0.0266171630014453, 0.0164719149306058, 0.0224769776020937, 0.0161981905657635,
      -0.97789004675122, -2.98996302231721, -4.47709693998471, -3.38902447676063,
      0.134344461508455, -2.05090651490245, -2.55656793397943, 0.263183636674009,
      1.40266145090399, 2.40788433100309, 0.422647580515112, 2.36373138502455,
      1.69327613241321, -1.22452842031523, 0.328602549290842, 0.00292787135593646,
      9.38510017460495e-06, 0.000756941845663804, 0.893184364098569,
      0.0407977270154514, 0.0108659604982013, 0.79251767702749, 0.161339659397767,
      0.0164070673315563, 0.672734468598401, 0.0184741567835475, 0.0910270288499264,
      0.221330723900604
    ),
    dim = c(14L, 4L),
    dimnames = list(
      c(
        ".Dtreat:first.treat::2004:year::2004", ".Dtreat:first.treat::2004:year::2005",
        ".Dtreat:first.treat::2004:year::2006", ".Dtreat:first.treat::2004:year::2007",
        ".Dtreat:first.treat::2006:year::2006", ".Dtreat:first.treat::2006:year::2007",
        ".Dtreat:first.treat::2007:year::2007", ".Dtreat:first.treat::2004:year::2004:lpop_dm",
        ".Dtreat:first.treat::2004:year::2005:lpop_dm", ".Dtreat:first.treat::2004:year::2006:lpop_dm",
        ".Dtreat:first.treat::2004:year::2007:lpop_dm", ".Dtreat:first.treat::2006:year::2006:lpop_dm",
        ".Dtreat:first.treat::2006:year::2007:lpop_dm", ".Dtreat:first.treat::2007:year::2007:lpop_dm"
      ),
      c("Estimate", "Std. Error", "t value", "Pr(>|t|)")
    ),
    type = "Clustered (countyreal)"
  )

m3p_known =
  structure(
    c(
      -0.0309556552922347, -0.066224038695174, -0.13297134493384,
      -0.11702277921655, -0.00904940559845884, -0.068148637702423,
      -0.0399915656291698, 0.011879798018537, 0.0209935307380962, 0.0409103313958613,
      0.0250348138421319, 0.0375837523433764, 0.0453804253079838, -0.0109675422749757,
      0.0176243272329323, 0.025588515668558, 0.0237301210935417, 0.0225051241893553,
      0.0244262550699582, 0.0251164210108884, 0.0168283375820888, 0.0071299812847054,
      0.0119274550952194, 0.00957331401532464, 0.0112896079763864,
      0.0136210418697861, 0.0164548820527518, 0.00722709675882192,
      -1.75641628092288, -2.58803752249479, -5.60348362360566, -5.19982819165694,
      -0.370478633443433, -2.71331005611347, -2.3764418460285, 1.66617520357599,
      1.76010142737913, 4.27337193059513, 2.2175095800045, 2.75924211251005,
      2.75786998426978, -1.5175585219041, 0.079017354894062, 0.00965244655611395,
      2.10085974119339e-08, 1.99472822770963e-07, 0.711025893819209,
      0.00666147454550643, 0.0174805166119171, 0.0956785232823045,
      0.0783906108215875, 1.92538892714901e-05, 0.0265882891378619,
      0.00579355941970147, 0.00581793329083424, 0.129125729929418
    ),
    dim = c(14L, 4L),
    dimnames = list(
      c(
        ".Dtreat:first.treat::2004:year::2004",
        ".Dtreat:first.treat::2004:year::2005", ".Dtreat:first.treat::2004:year::2006",
        ".Dtreat:first.treat::2004:year::2007", ".Dtreat:first.treat::2006:year::2006",
        ".Dtreat:first.treat::2006:year::2007", ".Dtreat:first.treat::2007:year::2007",
        ".Dtreat:first.treat::2004:year::2004:lpop_dm", ".Dtreat:first.treat::2004:year::2005:lpop_dm",
        ".Dtreat:first.treat::2004:year::2006:lpop_dm", ".Dtreat:first.treat::2004:year::2007:lpop_dm",
        ".Dtreat:first.treat::2006:year::2006:lpop_dm", ".Dtreat:first.treat::2006:year::2007:lpop_dm",
        ".Dtreat:first.treat::2007:year::2007:lpop_dm"
      ),
      c("Estimate", "Std. Error", "z value", "Pr(>|z|)")
    ), 
    type = "Clustered (countyreal)"
  )


# Tests ----

# No controls
m1  = etwfe(lemp ~ 0, tvar=year  , gvar=first.treat  , data=mpdta, vcov=~countyreal)
m1a = etwfe(lemp ~ 0, tvar="year", gvar="first.treat", data=mpdta, vcov=~countyreal)         # chars instead of nse
m1r = etwfe(lemp ~ 0, tvar="year", gvar="first.treat", data=mpdta, vcov=~countyreal, gref=0) # with explicit ref

expect_equal(fixest::coeftable(m1), m1_known)
expect_equal(fixest::coeftable(m1a), m1_known)
expect_equal(fixest::coeftable(m1r), m1_known)

# With never-treated control group
m2 = etwfe(lemp ~ 0, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal, 
             cgroup="never")

expect_equal(fixest::coeftable(m2), m2_known)

# With control
m3 = etwfe(lemp ~ lpop, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal)
expect_equal(fixest::coeftable(m3), m3_known)

expect_error(
  etwfe(lemp ~ 0, tvar=NULL, gvar=first.treat, data=mpdta)
)

# Poisson version
m3p = etwfe(emp ~ lpop, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal, family = "poisson")
expect_equal(fixest::coeftable(m3p), m3p_known)
