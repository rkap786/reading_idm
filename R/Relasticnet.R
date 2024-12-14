fnc_reg_elasticNet= function(f, vars.select, alpha=0) {
  library(tidymodels)
  library(caret)
  
  set.seed(123)
  #lambda <- 10^seq(-3, 3, length = 50)
  lambda= seq(0.0001,10, length=50)
  #alpha <- seq(0, 1, length=10)
  
  f= f |> na.omit()
  f = f[c(vars.select)]
  
  fsplit= f |> initial_split(prop=0.8, strata = pVal)
  
  train= training(fsplit)
  test= testing(fsplit)
  dim(f.train)
  dim(f.test)

  #cv_control=trainControl("cv", number = 10)
  # seeds <- vector(mode = "list", length = 11)
  # for(i in 1:50) seeds[[i]] <- sample.int(1000, 1)

  
  cv_control <- trainControl(
    method = "cv",
    number = 10,
    seeds=NULL
  )
    
  ridge.model.sparse <- caret::train(pVal~.,
                                     method='glmnet',
                                     family="gaussian",
                                     data= train,
                                     trControl = trainControl(
                                       method = "cv",
                                       number = 10),
                                     tuneGrid = expand.grid(alpha = alpha, lambda = lambda), #alpha=0 means Ridge, 1=Lasso
                                     preProcess = c('center', 'scale')
  )
  
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
  
  return(c(
    "rmse_train"= Metrics::rmse(train$pVal,y.train_hat),
    "rmse_test"= Metrics::rmse(test$pVal,y.test_hat),
    "rmse_ind"= Metrics::rmse(test$pVal,rep(mean(test$pVal),nrow(test))),
    "cor_train"= cor(train$pVal,y.train_hat),
    "cor_test"= cor(test$pVal,y.test_hat)
  ))
  
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