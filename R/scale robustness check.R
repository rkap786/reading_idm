library(readr)
library(tidyverse)
library(dplyr)
library(caret)
library(glmnet)
library(knitr)
setwd("/Users/radhika/Library/CloudStorage/GoogleDrive-rkap786@stanford.edu/My Drive/0. Projects - Stanford/Item generation/")
source("Code/reading_idm/R/getAbility.R")
source("Code/reading_idm/R/Relasticnet.R")



f.with.embed= read_csv("Data/Data/Processed/file-allitems_allembed.csv")
f.with.embed= f.with.embed |> na.omit()

### Scale 0: Different scales for NY & Texas
tx_ability=c(1467, 1552, 1592, 1634, 1669, 1698) #meets grade level performance
tx_ability = (tx_ability-1398.5930)/143.7195
nwea_ny_ability=c(200.74, 204.83, 210.98, 215.36, 216.81, 220.93)
#vg= c(0, 0.6921, 0.6641, 1.4135, 1.2939, 1.9002)
nwea_ny_ability= (nwea_ny_ability-200)/10 ## following scale conversion


res= runridge(df=f.with.embed, ny_ability_scale= nwea_ny_ability, tx_ability_scale= tx_ability)
write_csv(res, "Results/elasticnet_bert_oneset2.csv")
#write_csv(res, "Results/elasticnet_bert_oneset.csv")

### Scale 1: Meets grade level Texas 2022-23

tx_ability=c(1467, 1552, 1592, 1634, 1669, 1698) #meets grade level performance
#vg= c(0, 0.6921, 0.6641, 1.4135, 1.2939, 1.9002)
tx_ability = (tx_ability-1398.5930)/143.7195
### Get pval IRT directly for each item
res= runridge(df=f.with.embed, ny_ability_scale= tx_ability, tx_ability_scale= tx_ability)
write_csv(res, "Results/robust_elasticnet_txscale.csv")

# Scale 2: Texas approaches grade level performance 2022-23
tx_ability=c(1345, 1414, 1471, 1535, 1564, 1592) 
tx_ability = ((tx_ability-1398.5930)/143.7195)
res= runridge(df=f.with.embed, ny_ability_scale= tx_ability, tx_ability_scale= tx_ability)
write_csv(res, "Results/robust_elasticnet_txscale_approachgrlevel.csv")


# Scale 3: Texas masters grade level performance
tx_ability=c(1596, 1663, 1700, 1749, 1771, 1803) 
tx_ability = ((tx_ability-1398.5930)/143.7195)
res= runridge(df=f.with.embed, ny_ability_scale= tx_ability, tx_ability_scale= tx_ability)
write_csv(res, "Results/robust_elasticnet_txscale_mastergrlevel.csv")


# Scale 4: Texas standard 2017-18 academic readiness
tx_ability=c(1386, 1473, 1508, 1554, 1603, 1625) 
tx_ability = ((tx_ability-1398.5930)/143.7195)
res= runridge(df=f.with.embed, ny_ability_scale= tx_ability, tx_ability_scale= tx_ability)
write_csv(res, "Results/robust_elasticnet_readiness2018.csv")




## Scale 5: NWEA Spring 
nwea_ny_ability=c(200.74, 204.83, 210.98, 215.36, 216.81, 220.93)
nwea_ny_ability= (nwea_ny_ability-200)/10 ## following scale conversion
res= runridge(f.with.embed, ny_ability_scale = nwea_ny_ability, tx_ability_scale= nwea_ny_ability)
write_csv(res, "Results/robust_elasticnet_nwea_spring_scale.csv")


## Scale 6: NWEA 2015 reading literary text
nwea_ny_ability=c(192.4, 201.2, 207.9, 212.3, 216.3, 220.0)
nwea_ny_ability= (nwea_ny_ability-200)/10 ## following scale conversion
res= runridge(f.with.embed, ny_ability_scale = nwea_ny_ability, tx_ability_scale= nwea_ny_ability)
write_csv(res, "Results/robust_elasticnet_nwea_2015_literary.csv")


## Scale 7: NWEA 2015 reading informational text
nwea_ny_ability=c(191.6, 200.7, 207.4, 212.1, 216.1, 220.0)
nwea_ny_ability= (nwea_ny_ability-200)/10 ## following scale conversion
res= runridge(f.with.embed, ny_ability_scale = nwea_ny_ability, tx_ability_scale= nwea_ny_ability)
write_csv(res, "Results/robust_elasticnet_nwea_2015_info.csv")


## Scale 8: NWEA 2015 reading informational text and NWEA 2020
grlist=sort(unique(f.with.embed$grade))
yearlist=sort(unique(f.with.embed$year))
nwea_ny_ability_2015=c(191.6, 200.7, 207.4, 212.1, 216.1, 220.0)
nwea_ny_ability_2015= (nwea_ny_ability_2015-200)/10
nwea_ny_ability_2020=c(192.4, 201.2, 207.9, 212.3, 216.3, 220.0)
nwea_ny_ability_2020= (nwea_ny_ability-200)/10 ## following scale conversion

NY.ability.mat.2018= bind_cols(grade=grlist, state=rep("NY", 6),ability=nwea_ny_ability_2015, year=rep(2018,6))
NY.ability.mat.2019= bind_cols(grade=grlist, state=rep("NY", 6),ability=nwea_ny_ability_2015, year=rep(2019,6))
NY.ability.mat.2021= bind_cols(grade=grlist, state=rep("NY", 6),ability=nwea_ny_ability_2020, year=rep(2021,6))
NY.ability.mat.2022= bind_cols(grade=grlist, state=rep("NY", 6),ability=nwea_ny_ability_2020, year=rep(2022,6))
NY.ability.mat.2023= bind_cols(grade=grlist, state=rep("NY", 6),ability=nwea_ny_ability_2020, year=rep(2023,6))

TX.ability.mat.2018= bind_cols(grade=grlist, state=rep("Texas", 6),ability=nwea_ny_ability_2015, year=rep(2018,6))
TX.ability.mat.2019= bind_cols(grade=grlist, state=rep("Texas", 6),ability=nwea_ny_ability_2015, year=rep(2019,6)) 
TX.ability.mat.2021= bind_cols(grade=grlist, state=rep("Texas", 6),ability=nwea_ny_ability_2020, year=rep(2021,6))
TX.ability.mat.2022= bind_cols(grade=grlist, state=rep("Texas", 6),ability=nwea_ny_ability_2020, year=rep(2022,6))
TX.ability.mat.2023= bind_cols(grade=grlist, state=rep("Texas", 6),ability=nwea_ny_ability_2020, year=rep(2023,6))

ability.mat= bind_rows(NY.ability.mat.2018, NY.ability.mat.2019, NY.ability.mat.2021, NY.ability.mat.2022, NY.ability.mat.2023,
                       TX.ability.mat.2018, TX.ability.mat.2019, TX.ability.mat.2021, TX.ability.mat.2022, TX.ability.mat.2023)

res= runridge_years(df=f.with.embed, ability_mat= ability.mat)
write_csv(res, "Results/robust_elasticnet_nwea_time.csv")


### Plot results
res0= read_csv("Results/elasticnet_bert_oneset2.csv")
res0= cbind(scale="Texas 2022-23 & NWEA 2020", res0)
res1= read_csv("Results/robust_elasticnet_txscale.csv")
res1= cbind(scale="Texas 2022-23: Meets grade level", res1)
res2= read_csv("Results/robust_elasticnet_txscale_approachgrlevel.csv")
res2= cbind(scale=" Texas 2022-23: Approaches grade level", res2)
res3= read_csv("Results/robust_elasticnet_txscale_mastergrlevel.csv")
res3= cbind(scale="Texas 2022-23:Masters grade level", res3)
res4= read_csv("Results/robust_elasticnet_readiness2018.csv")
res4= cbind(scale="Texas 2017-18: Academic readiness standard", res4)
res5= read_csv("Results/robust_elasticnet_nwea_spring_scale.csv")
res5= cbind(scale="NWEA 2020: Spring", res5)
res6= read_csv("Results/robust_elasticnet_nwea_2015_literary.csv")
res6= cbind(scale="NWEA 2015: literary text", res6)
res7= read_csv("Results/robust_elasticnet_nwea_2015_info.csv")
res7= cbind(scale="NWEA 2015: informational text", res7)
res8= read_csv("Results/robust_elasticnet_nwea_time.csv")
res8= cbind(scale="NWEA 2015, 2020", res8)

res= bind_rows(res0, res1, res2, res3, res4, res5, res6, res7, res8)

library(ggplot2)

g=res |> 
  filter(type == "IRT" & model == "Assessment characteristics, text analysis metrics, context, & PCA on ModernBERT embeddings") |>
  mutate(scale = factor(scale, levels = unique(scale))) |>
  select(scale, rmse_test, cor_test) |>
  pivot_longer(cols = c(rmse_test, cor_test), names_to = "metric", values_to = "value") |>
  mutate(metric= ifelse(metric == "rmse_test", "RMSE (Test)", 
                        "Correlation: True vs Predicted (Test)")) |> 
  ggplot(aes(x = value, y = scale)) +
  geom_point(aes(color = ifelse(scale == "NWEA 2020: Spring", "NWEA 2020: Spring", "other")), size = 3) +
  geom_segment(aes(x = 0, xend = value, y = scale, yend = scale), 
               color = "gray60") +
  geom_text(aes(label = round(value, 2)), 
            hjust = 1, vjust = 2, size = 3, color = "black") +
  geom_vline(xintercept=0,  linetype = 'dashed', color="black") +
  facet_wrap(~metric, scales = "free", ncol = 2) +  # Allow columns to adjust
  theme_classic() +
  theme(
    legend.position = "none",  # Adjust facet label size if needed
    plot.margin = margin(10, 50, 10, 10),
    axis.title.x = element_blank(),
    panel.margin.x = unit(0, "lines")
  ) +
  scale_color_manual(values = c("NWEA 2020: Spring" = "red", "other" = "black"))  # Specify color for different points
ggsave("Code/reading_idm/R/plots/scale_robustness_cor_diff.png", g)


# 
# g1= res |> 
#   filter(type == "IRT" & model == "Assessment characteristics, text analysis metrics, context, & PCA on ModernBERT embeddings") |>
#   mutate(scale = factor(scale, levels = unique(scale))) |>
#   ggplot(aes(x = rmse_test, y = scale, color = scale)) +
#   geom_point(size = 3) +
#   geom_text(aes(label = round(rmse_test, 2)), 
#             hjust = 1, vjust=2, size = 3, color = "black") +
#   geom_segment(aes(x = 0, xend = rmse_test, y = scale, yend = scale), 
#                color = "gray60") +
#   scale_x_continuous(expand = c(0, 0)) +
#   geom_vline(xintercept=0.59,  linetype = 'dashed', color="black") +
#   theme_classic() +
#   theme(
#     legend.position = "none",
#     axis.title.y = element_blank(),
#     axis.text.y = element_text(hjust = 1, lineheight = 0.9, size=14), # Wraps long y-axis labels
#     #axis.text = element_text(face="bold")
#   ) +
#   scale_color_viridis_d() +
#   labs(color = "Scale", x = "RMSE (Test)", y = "Scale") 
# ggsave("Code/reading_idm/R/plots/scale_robustness_rmse.png", g1)

# 
# g2= res |> 
#   filter(type == "IRT" & model == "Assessment characteristics, text analysis metrics, context, & PCA on ModernBERT embeddings") |>
#   mutate(scale = factor(scale, levels = unique(scale))) |>
#   ggplot(aes(x = cor_test, y = scale, color = scale)) +
#   geom_point(size = 3) +
#   geom_text(aes(label = round(cor_test, 2)), 
#             vjust=2, hjust = 1, size = 3, color = "black") +
#   geom_segment(aes(x = 0, xend = cor_test, y = scale, yend = scale)) +
#   scale_x_continuous(expand = c(0, 0), limits = c(0,1)) +
#   geom_vline(xintercept=0.77,  linetype = 'dashed', color="black") +
#   theme_classic() +
#   theme(
#     legend.position = "none",
#     axis.title.y = element_blank(),
#     axis.text.y = element_blank() #element_text(hjust = 1, lineheight = 0.9, size=14) # Wraps long y-axis labels
#     #text = element_text(size = 14)
#   ) +
#   scale_color_viridis_d() +
#   labs(color = "Scale", x = "Correlation: True vs Predicted difficulty (Test)", y = "Scale")
#   


