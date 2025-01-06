stargazer_HAC <- function(..., type_out = "text", omit.stat = NULL, out = NULL, keep= NULL) {
  # the first inputs are n_mod models which are to be displayed
  # type_out carries through to the stargazer function, default: "text", other; "latex", "html"
  # omit_stat (default = NULL) will be handed through to stargazer, specify which stats you 
  #      don't want to see. see ?stargazer help for more help
  # Author: Ralf Becker, based on Marek Hlavac's stargazer package
  # https://CRAN.R-project.org/package=stargazer
  
  mod_all <- list(...)  # model collection should be a list of models
  n_mod <- length(mod_all)
  rep_se <- list(NULL)  # use this to replace se
  i <- 1        # count the number of models 
  
  if (length(mod_all) == 1) {
    cov1 <- vcovHAC(mod_all[[1]]) # calculate next rob se
    robust_se <- sqrt(diag(cov1))
    stargazer(mod_all[[1]],
              type=type_out,
              se=list(robust_se),
              omit.stat = omit.stat,
              notes="Newey-West standard errors in parenthesis",
              out = out)
  } else {
    for (mod_i in mod_all){
      covi <- vcovHAC(mod_i) # calculate next rob se
      robust_se <- sqrt(diag(covi))
      rep_se[[i]] <- robust_se  # add next robust standard error to rep_se list
      i <- i + 1
    }
    
    stargazer(mod_all, 
              type =type_out, 
              se=rep_se, 
              omit.stat = omit.stat,
              notes="Newey-West standard errors in parenthesis",
              out = out)
  }
}