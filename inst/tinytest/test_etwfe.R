data("mpdta", package = "did")

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
    c(-0.0105032462209508, -0.0704231581031381, -0.137258738889396, 
      -0.100811363085397, 0.00652011242423345, 0.00376929367371445, 
      -0.000825313279149046, -0.0374551778725034, 0.0305066555832941, 
      0.0277807626971777, -0.00330635669251181, -0.0293607674117096, 
      0.0233633078987138, 0.0311343819027021, 0.03661160000648, 0.034525135121976, 
      0.0234394425345873, 0.0314933678411741, 0.0337989168305776, 0.0358971277993021, 
      0.0151061523485228, 0.0196384071353136, 0.0245699429153835, 0.0265612837709354, 
      -0.449561606022795, -2.26190962528876, -3.74905054313666, -2.91994115965757, 
      0.27816840842577, 0.1196853157377, -0.024418335158078, -1.04340319598582, 
      2.01948549699866, 1.41461384855509, -0.134569164604842, -1.10539715116622, 
      0.653221784531609, 0.0241324067083743, 0.000198289769461048, 
      0.00365931411401953, 0.78099830710542, 0.904780603080419, 0.980528684828749, 
      0.297266808791989, 0.0439708498912579, 0.157805418693096, 0.893006782478479, 
      0.269520209895151), 
      dim = c(12L, 4L), 
    dimnames = list(
      c(".Dtreat:first.treat::2004:year::2004", ".Dtreat:first.treat::2004:year::2005", 
        ".Dtreat:first.treat::2004:year::2006", ".Dtreat:first.treat::2004:year::2007", 
        ".Dtreat:first.treat::2006:year::2004", ".Dtreat:first.treat::2006:year::2005", 
        ".Dtreat:first.treat::2006:year::2006", ".Dtreat:first.treat::2006:year::2007", 
        ".Dtreat:first.treat::2007:year::2004", ".Dtreat:first.treat::2007:year::2005", 
        ".Dtreat:first.treat::2007:year::2006", ".Dtreat:first.treat::2007:year::2007"), 
      c("Estimate", "Std. Error", "t value", "Pr(>|t|)")), 
    type = "Clustered (countyreal)"
    )

m3_known =
  structure(
    c(-0.0212480022225683, -0.0818499992698808, -0.137870386660868, 
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
      0.221330723900604), 
    dim = c(14L, 4L), 
    dimnames = list(
      c(".Dtreat:first.treat::2004:year::2004", ".Dtreat:first.treat::2004:year::2005", 
        ".Dtreat:first.treat::2004:year::2006", ".Dtreat:first.treat::2004:year::2007", 
        ".Dtreat:first.treat::2006:year::2006", ".Dtreat:first.treat::2006:year::2007", 
        ".Dtreat:first.treat::2007:year::2007", ".Dtreat:first.treat::2004:year::2004:lpop_dm", 
        ".Dtreat:first.treat::2004:year::2005:lpop_dm", ".Dtreat:first.treat::2004:year::2006:lpop_dm",
        ".Dtreat:first.treat::2004:year::2007:lpop_dm", ".Dtreat:first.treat::2006:year::2006:lpop_dm",
        ".Dtreat:first.treat::2006:year::2007:lpop_dm", ".Dtreat:first.treat::2007:year::2007:lpop_dm"),
      c("Estimate", "Std. Error", "t value", "Pr(>|t|)")), 
    type = "Clustered (countyreal)"
    )

# Tests ----

m1  = etwfe(lemp ~ 0, tvar=year  , gvar=first.treat  , data=mpdta, vcov=~countyreal)
m1a = etwfe(lemp ~ 0, tvar="year", gvar="first.treat", data=mpdta, vcov=~countyreal)
m1r = etwfe(lemp ~ 0, tvar="year", gvar="first.treat", data=mpdta, vcov=~countyreal, gref=0)

expect_equal(fixest::coeftable(m1), m1_known)
expect_equal(fixest::coeftable(m1a), m1_known)
expect_equal(fixest::coeftable(m1r), m1_known)

m2 = etwfe(lemp ~ 0, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal, 
             cgroup="never")

expect_equal(fixest::coeftable(m2), m2_known)

m3 = etwfe(lemp ~ lpop, tvar=year, gvar=first.treat, data=mpdta, vcov=~countyreal)
expect_equal(fixest::coeftable(m3), m3_known)

expect_error(
  etwfe(lemp ~ 0, tvar=NULL, gvar=first.treat, data=mpdta)
)
