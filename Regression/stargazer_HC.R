stargazer_HC <- function(mod) {
  cov1 <- vcovHC(mod, type = "HC1")
  robust_se <- sqrt(diag(cov1))
  stargazer(mod,type="text",se=list(NULL, robust_se))
}