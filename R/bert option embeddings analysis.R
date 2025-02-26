library(readr)
library(readxl)
library(tidyverse)
library(dplyr)

RowVar <- function(x) {
  rowSums((x - rowMeans(x))^2)/(3)
}

setwd('/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/Data/')
#setwd("G:/My Drive/0. Projects - Stanford/Item generation/Data")

f= read_csv("Data/Datacombined_clean.csv")

option_embed= read_csv("Embeddings/options_embed_cos_sim.csv")
names(option_embed)= c("id", "sim1", "sim2", "sim3", "PassNumUnq", "QNoUnq")
option_embed= option_embed |> select(-id)

## embeddings are very similar
v=apply(option_embed[, c("sim1", "sim2", "sim3")], 1, var)
hist(v)
# 
#   mutate(m= rowMeans(.),
#     v= sum((sim1- m)^2 + sum(sim2- m)^2 + sum(sim3- m)^2)


f |> filter(!is.na(PerOption1)) |> select(starts_with("PerOption")) |> summary()

### Embeddings characteristics



## Percent difference between correct answer and distractors

### Change from option1-4 to distractors
f_options= f |> select(CorrectOptionNum, "CorrectOption",contains("Unq"), starts_with("PerOption"), Option1, Option2, Option3, Option4) |>
  filter(!is.na(PerOption1))

f_options$per_option_correct_ans=rep(NA, nrow(f_options))
f_options$per_option_distractor1= rep(NA, nrow(f_options))
f_options$per_option_distractor2= rep(NA, nrow(f_options))
f_options$per_option_distractor3= rep(NA, nrow(f_options))


for (r in 1:nrow(f_options)) {
  c=1
  for (i in 1:4) {
    varname= paste0("PerOption",i)
    if(i==f_options$CorrectOptionNum[r]) {
      f_options$per_option_correct_ans[r] = f_options[[varname]][r]
    }
    if(i!=f_options$CorrectOptionNum[r]) {
      varnamey= paste0("per_option_distractor",c)
      f_options[[varnamey]][r] = f_options[[varname]][r]
      c=c+1
    }
  }
}

f_options= f_options |> dplyr::select(-starts_with("PerOption"))
f_options= f_options |> dplyr::select(-CorrectOption)

f_options= inner_join(f_options, option_embed)
f_options$diff1= abs(f_options$per_option_correct_ans - f_options$per_option_distractor1)/100
f_options$diff2= abs(f_options$per_option_correct_ans - f_options$per_option_distractor2)/100
f_options$diff3= abs(f_options$per_option_correct_ans - f_options$per_option_distractor3)/100



