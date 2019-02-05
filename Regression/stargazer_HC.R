stargazer_HC <- function(mod, type_in = "text") {
  cov1 <- vcovHC(mod, type = "HC1")
  robust_se <- sqrt(diag(cov1))
  stargazer(mod,type=type_in,se=list(NULL, robust_se))
}