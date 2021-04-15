stargazer_HC <- function(..., type_out = "text", type_HC = "HC1",omit.stat = NULL,out = NULL) {
  # the first inputs are n_mod models which are to be displayed
  # type_out carries through to the stargazer function, default: "text", other; "latex", "html"
  # type_HC carries through tothe vcovHC function, default: "HC1" (or Stata equivalent)
  # omit_stat (default = NULL) will be handed through to stargazer, specify which stats you 
  #      don't want to see. see ?stargazer help for more help
  mod_all <- list(...)  # model collection should be a list of models
  n_mod <- length(mod_all)
  rep_se <- list(NULL)  # use this to replace se
  i <- 1        # count the number of models 

  if (length(mod_all) == 1) {
    cov1 <- vcovHC(mod_all[[1]], type = type_HC) # calculate next rob se
    robust_se <- sqrt(diag(cov1))
    print(robust_se)
    stargazer(mod_all[[1]],
              type=type_out,
              se=list(robust_se),
              omit.stat = omit.stat,
              notes="Robust standard errors in parenthesis",
              out = out)
  } else {
    for (mod_i in mod_all){
      covi <- vcovHC(mod_i, type = type_HC) # calculate next rob se
      robust_se <- sqrt(diag(covi))
      rep_se[[i]] <- robust_se  # add next robust standard error to rep_se list
      i <- i + 1
    }

    
    stargazer(mod_all, 
              type =type_out, 
              se=rep_se, 
              omit.stat = omit.stat,
              notes="Robust standard errors in parenthesis",
              out = out)
  }
}