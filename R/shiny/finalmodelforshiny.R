### This runs and saves a model for the shiny app. 
### Model runs L2 ridge regularization. Inputs are only BERT embeddings

library(readr)
library(tidyverse)
library(dplyr)
library(caret)
library(glmnet)
library(knitr)
library(tidymodels)

setwd("/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/")
source("Code/reading_idm/R/getAbility.R")
source("Code/reading_idm/R/Relasticnet.R")

### Import & process file
f= read_csv("Data/Data/Processed/data_qual_info.csv")
# glimpse(f)

f= f |> dplyr::select(-pdfname,-starts_with("PerOption"), 
                      -CorrectOptionNum,
                      -QuestionNo) #-DESWC
f= f |> mutate(pVal= ifelse(pVal==0, pVal+0.001, pVal))

f.names = names(f)

vars.yn= f.names[grepl("yn", f.names)]
for (vars in c(vars.yn, "year")) {
  f[[vars]]= as.factor(f[[vars]])
}

f =f |>
  select(-pass_text_underline_yn,-pass_text_italics_yn,
         -pass_text_bold_yn, -pass_text_fn_yn,-numPara,  -Passage, -starts_with("option_"), -QuestionText)

### Scales
nwea_ability=c(198.32, 205.00, 210.19, 214.19, 216.47, 218.74)
grlist=sort(unique(f$grade))
nwea_ability= (nwea_ability-200)/10 ## following scale conversion


# ## IRT scale
# nwea.ability.mat= data.frame(bind_cols(grade=grlist, state=rep("NY", 6),ability=nwea_ability))
# tx_ability_mat= data.frame(bind_cols(grade=grlist, state=rep("Texas", 6),ability=nwea_ability)) 
# ability.mat= bind_rows(nwea.ability.mat,tx_ability_mat)
# names(f)
# #f= f |> select(-pVal.irt, -nwea.ability)
# f= left_join(f, ability.mat)
# f$pVal.irt = getlogitdiff(pv=f$pVal, th.scale = f$ability)
# 
# f= f |> dplyr::select(-ability)


### Linear adjustment
ny.adj.mat= getlinearscale(nwea_ability,f, state="NY", start=0.3, end=0.7)
tx.adj.mat= getlinearscale(nwea_ability,f, state="Texas", start=0.3, end=0.7)
adj.states = bind_rows(ny.adj.mat, tx.adj.mat)

f= left_join(f, adj.states)
f$pVal.cons= f$pVal - f$mean.pv
f =f |> dplyr::select(-mean.pv)

##

#Rename
f= f |> dplyr::rename(pVal.unadj= pVal)

#### PCA embeddings
embed.bert= read_csv("Data/Embeddings/question_alldistractors_embed.csv")
names(embed.bert)= c("id",paste0("embed.bert", 1:768), "PassNumUnq", "QNoUnq")
embed.bert = embed.bert |> select(-id)

### Join
f.with.embed= left_join(f, embed.bert) #f.embed.merged.tag

### Run model
vars = names(f.with.embed)
vars.embed = vars[grep("embed", vars)]
#length(vars.embed)
### item characteristics
#vars.fe=c("state", "year", "grade")
#vars.fe=c()
#vars.chars= c("ques_text_highlight_yn","ques_text_ref_yn", "ques_order","pass_highlight_yn")
vars.outcome=c("pVal.cons", "pVal.unadj") #"pVal.cons", "pVal.irt"
vars.id=c("PassNumUnq", "QNoUnq")
# vars.lang= setdiff(names(f.with.embed),
#                    c(vars.fe, vars.embed,vars.chars, vars.outcome, vars.id, vars.embed.pca))



f.input= f.with.embed
f.input$pVal= f.input$pVal.cons
vars.select=c("pVal",c(vars.embed))

set.seed(123)
#lambda <- 10^seq(-3, 3, length = 50)
lambda= seq(0.0001,10, length=50)
alpha=0
#alpha <- seq(0, 1, length=10)

f.input = f.input[c(vars.select)]
f.input= f.input |> na.omit()
fsplit= f.input |> initial_split(prop=0.8, strata = pVal)

train= training(fsplit)
test= testing(fsplit)
# dim(f.train)
# dim(f.test)

#cv_control=trainControl("cv", number = 10)
seeds <- vector(mode = "list", length = 11)
for(i in 1:11) seeds[[i]] <- 123+i

cv_control <- trainControl(
  method = "cv",
  number = 10,
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

saveRDS(ridge.model.sparse, "Code/reading_idm/R/shiny/model.rds")