
runridge_years= function(df=f.with.embed, ability_mat= ability.mat) {
  #names(f)
  #f= f |> select(-pVal.irt, -nwea.ability)
  df= left_join(df, ability.mat)
  df$pVal.irt = getlogitdiff(pv=df$pVal, th.scale = df$ability)
  df= df |> dplyr::select(-ability) |>
    dplyr::rename(pVal.unadj=pVal)
  
  vars = names(df)
  vars.embed.bert = vars[grep("embed.bert", vars, fixed = TRUE)]
  vars.pca.bert = vars[grep("^bert\\.PC", vars)]
  vars.embed.llama = vars[grep("embed.llama", vars, fixed = TRUE)]
  vars.pca.llama = vars[grep("llama.PC", vars, fixed = TRUE)]
  vars.embed.mbert = vars[grep("embed.mbert", vars, fixed = TRUE)]
  vars.pca.mbert = vars[grep("mbert.PC", vars, fixed = TRUE)]
  
  
  ### 
  
  
  ### item characteristics
  vars.fe=c("state", "year", "grade")
  #vars.fe=c()
  vars.chars= c("ques_text_highlight_yn","ques_text_ref_yn", "ques_order","pass_highlight_yn")
  vars.outcome=c("pVal","pVal.cons", "pVal.irt", "pVal.unadj")
  vars.id=c("PassNumUnq", "QNoUnq")
  vars.lang= setdiff(names(f.with.embed),
                     c(vars.fe, vars.chars, vars.outcome, vars.id, vars.embed.bert, 
                       vars.embed.llama, vars.pca.bert, vars.pca.llama,
                       vars.embed.mbert, vars.pca.mbert))
  
  
  
  ## Unadjusted results
  
  df$pVal= df$pVal.unadj
  res_unadj= fnc_compile_models(f.input=df, vars.chars, vars.lang, 
                                vars.embed.bert, vars.embed.llama, 
                                vars.pca.bert, vars.pca.llama, vars.embed.mbert, vars.pca.mbert)
  res_unadj= bind_cols(type=rep("Unadj",nrow(res_unadj)),res_unadj)
  
  #res_pca_results= bind_rows(res_lang_item_pcaembed, res_lang_item_pcaembed2)
  
  ### IRT pvalues
  df$pVal= df$pVal.irt
  
  #Models with IRT pvalues
  res_irt= fnc_compile_models(f.input=df, vars.chars, vars.lang, 
                              vars.embed.bert, vars.embed.llama, 
                              vars.pca.bert, vars.pca.llama, 
                              vars.embed.mbert, vars.pca.mbert)
  
  res_irt= bind_cols(type=rep("IRT",nrow(res_irt)),res_irt)
  
  # 
  # #View(res_cons)
  # kable(res_unadj[,-1], format="latex")
  # kable(res_cons[,-1], format="latex")
  # kable(res_irt[,-1], format="latex")
  res= bind_rows(res_unadj, res_irt) 
  return(res)
}



runridge= function(df=f.with.embed, ny_ability_scale= tx_ability, tx_ability_scale= tx_ability) {
  grlist=sort(unique(df$grade))
  NY.ability.mat= data.frame(bind_cols(grade=grlist, state=rep("NY", 6),ability=ny_ability_scale))
  TX_ability_mat= data.frame(bind_cols(grade=grlist, state=rep("Texas", 6),ability=tx_ability_scale)) 
  ability.mat= bind_rows(NY.ability.mat,TX_ability_mat)
  #names(f)
  #f= f |> select(-pVal.irt, -nwea.ability)
  
  df= left_join(df, ability.mat)
  df$pVal.irt = getlogitdiff(pv=df$pVal, th.scale = df$ability)
  df= df |> dplyr::select(-ability) |>
    dplyr::rename(pVal.unadj=pVal)
  
  vars = names(df)
  vars.embed.bert = vars[grep("embed.bert", vars, fixed = TRUE)]
  vars.pca.bert = vars[grep("^bert\\.PC", vars)]
  vars.embed.llama = vars[grep("embed.llama", vars, fixed = TRUE)]
  vars.pca.llama = vars[grep("llama.PC", vars, fixed = TRUE)]
  vars.embed.mbert = vars[grep("embed.mbert", vars, fixed = TRUE)]
  vars.pca.mbert = vars[grep("mbert.PC", vars, fixed = TRUE)]
  
  
  ### 
  
  
  ### item characteristics
  vars.fe=c("state", "year", "grade")
  #vars.fe=c()
  vars.chars= c("ques_text_highlight_yn","ques_text_ref_yn", "ques_order","pass_highlight_yn")
  vars.outcome=c("pVal","pVal.cons", "pVal.irt", "pVal.unadj")
  vars.id=c("PassNumUnq", "QNoUnq")
  vars.lang= setdiff(names(f.with.embed),
                     c(vars.fe, vars.chars, vars.outcome, vars.id, vars.embed.bert, 
                       vars.embed.llama, vars.pca.bert, vars.pca.llama,
                       vars.embed.mbert, vars.pca.mbert))
  
  
  
  ## Unadjusted results
  
  df$pVal= df$pVal.unadj
  res_unadj= fnc_compile_models(f.input=df, vars.chars, vars.lang, 
                                vars.embed.bert, vars.embed.llama, 
                                vars.pca.bert, vars.pca.llama, vars.embed.mbert, vars.pca.mbert)
  res_unadj= bind_cols(type=rep("Unadj",nrow(res_unadj)),res_unadj)
  
  #res_pca_results= bind_rows(res_lang_item_pcaembed, res_lang_item_pcaembed2)
  
  ### IRT pvalues
  df$pVal= df$pVal.irt
  
  
  #Models
  res_irt= fnc_compile_models(f.input=df, vars.chars, vars.lang, 
                              vars.embed.bert, vars.embed.llama, 
                              vars.pca.bert, vars.pca.llama, 
                              vars.embed.mbert, vars.pca.mbert)
  
  res_irt= bind_cols(type=rep("IRT",nrow(res_irt)),res_irt)
  
  # 
  # #View(res_cons)
  # kable(res_unadj[,-1], format="latex")
  # kable(res_cons[,-1], format="latex")
  # kable(res_irt[,-1], format="latex")
  res= bind_rows(res_unadj, res_irt) 
  return(res)
}


fnc_reg_elasticNet= function(f, vars.select, alpha=0, rep=5, nfold=5) {
  library(tidymodels)
  library(caret)
  library(doParallel)
  
  set.seed(123)
  #lambda <- 10^seq(-3, 3, length = 50)
  lambda= seq(0.0001,10, length=50)
  #alpha <- seq(0, 1, length=10)
  
  f= f |> na.omit()
  f = f[c(vars.select)]
  
  fsplit= f |> initial_split(prop=0.8, strata = pVal)
  
  train= training(fsplit)
  test= testing(fsplit)
  # dim(f.train)
  # dim(f.test)
  
  # Set up parallel backend
  num_cores <- detectCores() - 1
  cl <- makeCluster(num_cores)
  registerDoParallel(cl)
  
  #cv_control=trainControl("cv", number = 10)
  # seeds <- vector(mode = "list", length = 11)
  # for(i in 1:11) seeds[[i]] <- 123+i
  
  # cv_control <- trainControl(
  #   method = "cv",
  #   number = 10,
  #   seeds=seeds
  # )
  #   
  
  # rep=5
  # nfold=5
  len=(rep*nfold)+1
  seeds <- vector(mode = "list", length = len)
  for(i in 1:len) seeds[[i]] <- 123+i

  cv_control <- trainControl(
    method = "repeatedcv",
    number = nfold,
    repeats = rep,
    seeds=seeds
  )
  
  ridge.model.sparse <- caret::train(pVal~.,
                                     method='glmnet',
                                     family="gaussian",
                                     data= train,
                                     trControl = cv_control,
                                     tuneGrid = expand.grid(alpha = alpha, lambda = lambda), #alpha=0 means Ridge, 1=Lasso
                                     preProcess = c('center', 'scale')
  )
  
  # Stop parallel backend
  stopCluster(cl)
  registerDoSEQ()
  
  
  ridge.model.sparse$bestTune
  
  ridge.model.sparse$results |> 
    mutate(alpha= round(alpha,3)) |>
    ggplot(aes(x=log(lambda), y=RMSE, col=factor(alpha))) + geom_line() + geom_point()+ 
    theme_minimal() +
    labs(title = "Ridge Regression (alpha = 0) - RMSE vs. Lambda")
  
  # c1=round(coef.glmnet(ridge.model.sparse$finalModel, s = ridge.model.sparse$bestTune$lambda),4)
  
  coef_ridge_sparse <- round(coef(ridge.model.sparse$finalModel, 
                                  ridge.model.sparse$bestTune$lambda),4)
  
  coef_ridge_sparse |>
    as.matrix() |> as.data.frame() |>
    mutate(vars= rownames(coef_ridge_sparse)) |>
    rename(est=s1) |>
    arrange(desc(est))
  
  y.test_hat <- predict(ridge.model.sparse, test)
  y.train_hat <- predict(ridge.model.sparse, train)
  
  # res_test= cbind(test, pval_pred=y.test_hat)
  # res_train= cbind(train, pval_pred=y.train_hat)
  # res_combined= bind_rows(res_train, res_test)
  
  
  return(c(
    "rmse_train"= Metrics::rmse(train$pVal,y.train_hat),
    "rmse_test"= Metrics::rmse(test$pVal,y.test_hat),
    "rmse_ind"= Metrics::rmse(test$pVal,rep(mean(test$pVal),nrow(test))),
    "cor_train"= cor(train$pVal,y.train_hat),
    "cor_test"= cor(test$pVal,y.test_hat)
  ))
  
}


fnc_compile_models= function(f.input, vars.chars, vars.lang, 
                             vars.embed.bert, vars.embed.llama, 
                             vars.pca.bert, vars.pca.llama, vars.embed.mbert, 
                             vars.pca.mbert){
  
  #Models
  res_fe= fnc_reg_elasticNet(f.input,
                             c("pVal", c("state", "grade", "year"))) # without language
  
  res_item= fnc_reg_elasticNet(f.input,
                               c("pVal", c(vars.chars))) # without language metrics
  res_lang= fnc_reg_elasticNet(f.input, 
                               c("pVal",c(vars.lang))) ## everything except embedding
  res_item_lang= fnc_reg_elasticNet(f.input, 
                                       c("pVal",c(vars.chars, vars.lang))) ## everything except embedding
  res_all_features= fnc_reg_elasticNet(f.input, 
                                       c("pVal",c("state", "grade", "year", vars.chars, vars.lang))) ## everything except embedding
  res_item_embed_bert= fnc_reg_elasticNet(f.input, 
                                          c("pVal",c(vars.embed.bert))) ## embeddings only
  res_item_embed_llama= fnc_reg_elasticNet(f.input, 
                                           c("pVal",c(vars.embed.llama))) ## embeddings only
  
  res_item_embed_mbert= fnc_reg_elasticNet(f.input,
                                c("pVal",c(vars.embed.mbert))) ## embeddings only
  
  # res_item_embed_pca= fnc_reg_elasticNet(f.input,
  #                               c("pVal",c(vars.fe,vars.embed.pca))) ## embeddings only
  
  res_item_all_bert= fnc_reg_elasticNet(f.input, 
                                        c("pVal",c(vars.chars,
                                                   vars.lang, vars.embed.bert)))
  
  res_item_all_pca_bert= fnc_reg_elasticNet(f.input, 
                                            c("pVal",c(vars.chars,
                                                       vars.lang, vars.pca.bert)))
  
  
  res_item_all_llama= fnc_reg_elasticNet(f.input, 
                                         c("pVal",c(vars.chars,
                                                    vars.lang, vars.embed.llama)))
  
  res_item_all_pca_llama= fnc_reg_elasticNet(f.input, 
                                             c("pVal",c(vars.chars,
                                                        vars.lang, vars.pca.llama)))
  
  res_item_all_mbert= fnc_reg_elasticNet(f.input,
                                c("pVal",c(vars.chars,
                                           vars.lang, vars.embed.mbert)))
  
  res_item_all_pca_mbert= fnc_reg_elasticNet(f.input, 
                                             c("pVal",c(vars.chars,
                                                        vars.lang, vars.pca.mbert)))
  
  res_item_all_bert_fe= fnc_reg_elasticNet(f.input, 
                                        c("pVal",c("state", "grade", "year",vars.chars,
                                                   vars.lang, vars.embed.bert)))
  
  res_item_all_pca_bert_fe= fnc_reg_elasticNet(f.input, 
                                            c("pVal",c("state", "grade", "year",vars.chars,
                                                       vars.lang, vars.pca.bert)))
  
  
  res_item_all_llama_fe= fnc_reg_elasticNet(f.input, 
                                         c("pVal",c("state", "grade", "year",vars.chars,
                                                    vars.lang, vars.embed.llama)))
  
  res_item_all_pca_llama_fe= fnc_reg_elasticNet(f.input, 
                                             c("pVal",c("state", "grade", "year",vars.chars,
                                                        vars.lang, vars.pca.llama)))
  
  res_item_all_mbert_fe= fnc_reg_elasticNet(f.input,
                                         c("pVal",c("state", "grade", "year",vars.chars,
                                                    vars.lang, vars.embed.mbert)))
  
  res_item_all_pca_mbert_fe= fnc_reg_elasticNet(f.input, 
                                             c("pVal",c("state", "grade", "year",vars.chars,
                                                        vars.lang, vars.pca.mbert)))
  
  res= bind_rows(res_fe, res_item, res_lang, res_item_lang, res_all_features, res_item_embed_bert, res_item_embed_llama, res_item_embed_mbert,
                     res_item_all_bert, res_item_all_pca_bert, res_item_all_llama, res_item_all_pca_llama,
                 res_item_all_mbert, res_item_all_pca_mbert, 
                 res_item_all_bert_fe, res_item_all_pca_bert_fe, res_item_all_llama_fe, res_item_all_pca_llama_fe, 
                 res_item_all_mbert_fe, res_item_all_pca_mbert_fe)
  
  
  res= round(res,2)
  res= bind_cols(model=c("Linguistic features", "Assessment features", "Context features: State, Grade, Year",  
                         "Linguistic and Assessment features", "Linguistic, Assessment and Context features",
                                                           "LLM embeddings: BERT", 
                                                           "LLM embeddings: LlAMA", 
                                                            "LLM embeddings: ModernBERT", 
                                                           "Assessment characteristics, text analysis metrics, & BERT embeddings", 
                                                           "Assessment characteristics, text analysis metrics, & PCA on BERT embeddings",
                                                           "Assessment characteristics, text analysis metrics, & LlAMA embeddings", 
                                                           "Assessment characteristics, text analysis metrics, & PCA on LlAMA embeddings",
                                                          "Assessment characteristics, text analysis metrics, & ModernBERT embeddings", 
                                                           "Assessment characteristics, text analysis metrics, & PCA on ModernBERT embeddings",
                         "Assessment characteristics, text analysis metrics, context, & BERT embeddings", 
                         "Assessment characteristics, text analysis metrics, context, & PCA on BERT embeddings",
                         "Assessment characteristics, text analysis metrics, context, & LlAMA embeddings", 
                         "Assessment characteristics, text analysis metrics, context, & PCA on LlAMA embeddings",
                         "Assessment characteristics, text analysis metrics, context, & ModernBERT embeddings", 
                         "Assessment characteristics, text analysis metrics, context, & PCA on ModernBERT embeddings"
                         
                         ), res)
  return(res)
}


# fnc_reg_elasticNet_irt= function(train, test, alpha=0) {
#   set.seed(123)
#   #lambda <- 10^seq(-3, 3, length = 50)
#   lambda= seq(0.0001,10, length=50)
#   #alpha <- seq(0, 1, length=10)
#   
#   
#   ridge.model.sparse <- caret::train(pVal.irt~.,
#                                      method='glmnet',
#                                      family="gaussian",
#                                      data= train,
#                                      trControl = trainControl("cv", number = 10),
#                                      tuneGrid = expand.grid(alpha = alpha, lambda = lambda), #alpha=0 means Ridge, 1=Lasso
#                                      preProcess = c('center', 'scale')
#   )
#   
#   ridge.model.sparse$bestTune
#   
#   ridge.model.sparse$results |> 
#     mutate(alpha= round(alpha,3)) |>
#     ggplot(aes(x=log(lambda), y=RMSE, col=factor(alpha))) + geom_line() + geom_point()+ 
#     theme_minimal() +
#     labs(title = "Ridge Regression (alpha = 0) - RMSE vs. Lambda")
#   
#   # c1=round(coef.glmnet(ridge.model.sparse$finalModel, s = ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse <- round(coef(ridge.model.sparse$finalModel, 
#                                   ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse |>
#     as.matrix() |> as.data.frame() |>
#     mutate(vars= rownames(coef_ridge_sparse)) |>
#     rename(est=s1) |>
#     arrange(desc(est))
#   
#   y.test_hat <- predict(ridge.model.sparse, test)
#   y.train_hat <- predict(ridge.model.sparse, train)
#   
#   return(c(
#     "rmse_test"= Metrics::rmse(test$pVal.irt,y.test_hat),
#     "rmse_ind"= Metrics::rmse(test$pVal.irt,rep(mean(test$pVal.irt),nrow(test))),
#     "cor_test"= cor(test$pVal.irt,y.test_hat),
#     "rmse_train"= Metrics::rmse(train$pVal.irt,y.train_hat),
#     "cor_train"= cor(train$pVal.irt,y.train_hat)
#   ))
#   
# }
# 
# fnc_reg_elasticNet_linear= function(train, test, alpha=0) {
#   set.seed(123)
#   #lambda <- 10^seq(-3, 3, length = 50)
#   lambda= seq(0.0001,10, length=50)
#   #alpha <- seq(0, 1, length=10)
#   
#   
#   ridge.model.sparse <- caret::train(pVal.cons~.,
#                                      method='glmnet',
#                                      family="gaussian",
#                                      data= train,
#                                      trControl = trainControl("cv", number = 10),
#                                      tuneGrid = expand.grid(alpha = alpha, lambda = lambda), #alpha=0 means Ridge, 1=Lasso
#                                      preProcess = c('center', 'scale')
#   )
#   
#   ridge.model.sparse$bestTune
#   
#   ridge.model.sparse$results |> 
#     mutate(alpha= round(alpha,3)) |>
#     ggplot(aes(x=log(lambda), y=RMSE, col=factor(alpha))) + geom_line() + geom_point()+ 
#     theme_minimal() +
#     labs(title = "Ridge Regression (alpha = 0) - RMSE vs. Lambda")
#   
#   # c1=round(coef.glmnet(ridge.model.sparse$finalModel, s = ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse <- round(coef(ridge.model.sparse$finalModel, 
#                                   ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse |>
#     as.matrix() |> as.data.frame() |>
#     mutate(vars= rownames(coef_ridge_sparse)) |>
#     rename(est=s1) |>
#     arrange(desc(est))
#   
#   y.test_hat <- predict(ridge.model.sparse, test)
#   y.train_hat <- predict(ridge.model.sparse, train)
#   
#   return(c(
#     "rmse_test"= Metrics::rmse(test$pVal.cons,y.test_hat),
#     "rmse_ind"= Metrics::rmse(test$pVal.cons,rep(mean(test$pVal.cons),nrow(test))),
#     "cor_test"= cor(test$pVal.cons,y.test_hat),
#     "rmse_train"= Metrics::rmse(train$pVal.cons,y.train_hat),
#     "cor_train"= cor(train$pVal.cons,y.train_hat)
#   ))
#   
# }
# 
# 
# fnc_reg_elasticNet2= function(train, test, alpha=0) {
#   
#   
#   set.seed(123)
#   #lambda <- 10^seq(-3, 3, length = 50)
#   lambda= seq(0.0001,10, length=50)
#   #alpha <- seq(0, 1, length=10)
#   
#   #f= f |> na.omit()
#   
#   ridge.model.sparse <- caret::train(pVal~.,
#                               method='glmnet',
#                               family="gaussian",
#                               data= train,
#                               trControl = trainControl("cv", number = 10),
#                               tuneGrid = expand.grid(alpha = alpha, lambda = lambda), #alpha=0 means Ridge, 1=Lasso
#                               preProcess = c('center', 'scale')
#                               )
#   
#   ridge.model.sparse$bestTune
#   
#   ridge.model.sparse$results |> 
#     mutate(alpha= round(alpha,3)) |>
#     ggplot(aes(x=log(lambda), y=RMSE, col=factor(alpha))) + geom_line() + geom_point()+ 
#     theme_minimal() +
#     labs(title = "Ridge Regression (alpha = 0) - RMSE vs. Lambda")
#   
#   # c1=round(coef.glmnet(ridge.model.sparse$finalModel, s = ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse <- round(coef(ridge.model.sparse$finalModel, 
#                                   ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse |>
#     as.matrix() |> as.data.frame() |>
#     mutate(vars= rownames(coef_ridge_sparse)) |>
#     rename(est=s1) |>
#     arrange(desc(est))
#   
#   y.test_hat <- predict(ridge.model.sparse, test)
#   y.train_hat <- predict(ridge.model.sparse, train)
#   
#   return(c(
#     "rmse_train"= Metrics::rmse(train$pVal,y.train_hat),
#     "rmse_test"= Metrics::rmse(test$pVal,y.test_hat),
#     "rmse_ind"= Metrics::rmse(test$pVal,rep(mean(test$pVal),nrow(test))),
#     "cor_train"= cor(train$pVal,y.train_hat),
#     "cor_test"= cor(test$pVal,y.test_hat)
#   ))
#   
# }
# 
# 
# fnc_reg_elasticNet_irt= function(train, test, alpha=0) {
#   set.seed(123)
#   #lambda <- 10^seq(-3, 3, length = 50)
#   lambda= seq(0.0001,10, length=50)
#   #alpha <- seq(0, 1, length=10)
#   
#   
#   ridge.model.sparse <- caret::train(pVal.irt~.,
#                               method='glmnet',
#                               family="gaussian",
#                               data= train,
#                               trControl = trainControl("cv", number = 10),
#                               tuneGrid = expand.grid(alpha = alpha, lambda = lambda), #alpha=0 means Ridge, 1=Lasso
#                               preProcess = c('center', 'scale')
#                               )
#   
#   ridge.model.sparse$bestTune
#   
#   ridge.model.sparse$results |> 
#     mutate(alpha= round(alpha,3)) |>
#     ggplot(aes(x=log(lambda), y=RMSE, col=factor(alpha))) + geom_line() + geom_point()+ 
#     theme_minimal() +
#     labs(title = "Ridge Regression (alpha = 0) - RMSE vs. Lambda")
#   
#   # c1=round(coef.glmnet(ridge.model.sparse$finalModel, s = ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse <- round(coef(ridge.model.sparse$finalModel, 
#                                   ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse |>
#     as.matrix() |> as.data.frame() |>
#     mutate(vars= rownames(coef_ridge_sparse)) |>
#     rename(est=s1) |>
#     arrange(desc(est))
#   
#   y.test_hat <- predict(ridge.model.sparse, test)
#   y.train_hat <- predict(ridge.model.sparse, train)
#   
#   return(c(
#     "rmse_test"= Metrics::rmse(test$pVal.irt,y.test_hat),
#     "rmse_ind"= Metrics::rmse(test$pVal.irt,rep(mean(test$pVal.irt),nrow(test))),
#     "cor_test"= cor(test$pVal.irt,y.test_hat),
#     "rmse_train"= Metrics::rmse(train$pVal.irt,y.train_hat),
#     "cor_train"= cor(train$pVal.irt,y.train_hat)
#   ))
#   
# }
# 
# fnc_reg_elasticNet_linear= function(train, test, alpha=0) {
#   set.seed(123)
#   #lambda <- 10^seq(-3, 3, length = 50)
#   lambda= seq(0.0001,10, length=50)
#   #alpha <- seq(0, 1, length=10)
#   
#   
#   ridge.model.sparse <- caret::train(pVal.cons~.,
#                               method='glmnet',
#                               family="gaussian",
#                               data= train,
#                               trControl = trainControl("cv", number = 10),
#                               tuneGrid = expand.grid(alpha = alpha, lambda = lambda), #alpha=0 means Ridge, 1=Lasso
#                               preProcess = c('center', 'scale')
#                               )
#   
#   ridge.model.sparse$bestTune
#   
#   ridge.model.sparse$results |> 
#     mutate(alpha= round(alpha,3)) |>
#     ggplot(aes(x=log(lambda), y=RMSE, col=factor(alpha))) + geom_line() + geom_point()+ 
#     theme_minimal() +
#     labs(title = "Ridge Regression (alpha = 0) - RMSE vs. Lambda")
#   
#   # c1=round(coef.glmnet(ridge.model.sparse$finalModel, s = ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse <- round(coef(ridge.model.sparse$finalModel, 
#                                   ridge.model.sparse$bestTune$lambda),4)
#   
#   coef_ridge_sparse |>
#     as.matrix() |> as.data.frame() |>
#     mutate(vars= rownames(coef_ridge_sparse)) |>
#     rename(est=s1) |>
#     arrange(desc(est))
#   
#   y.test_hat <- predict(ridge.model.sparse, test)
#   y.train_hat <- predict(ridge.model.sparse, train)
#   
#   return(c(
#     "rmse_test"= Metrics::rmse(test$pVal.cons,y.test_hat),
#     "rmse_ind"= Metrics::rmse(test$pVal.cons,rep(mean(test$pVal.cons),nrow(test))),
#     "cor_test"= cor(test$pVal.cons,y.test_hat),
#     "rmse_train"= Metrics::rmse(train$pVal.cons,y.train_hat),
#     "cor_train"= cor(train$pVal.cons,y.train_hat)
#   ))
#   
# }