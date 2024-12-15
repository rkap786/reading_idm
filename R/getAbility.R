
getlogitdiff= function(pv, th.scale) {
  b= th.scale  - log(pv/ (1-pv))
  return(b)
}

getlinearscale= function(th.scale, f, state="Texas", start=0.3, end=0.7){
  
  #th.scale=c(1467, 1552, 1592, 1634, 1669, 1698) #meets grade level performance
  range= end-start
  th.scale = (th.scale-1398.5930)/143.7195
  growth= th.scale- lag(th.scale)
  growth= growth[-1]
  totalgr= th.scale[length(th.scale)]-th.scale[1]
  growth= growth/totalgr
  nr=length(growth) #length of growth matrix
  
  f.state= f |> filter(state==(!!state))
  grlist=sort(unique(f$grade))
  pval.state.grade= f.state |> group_by(grade) |> summarize(mean.pv= mean(pVal))
  pval.state.grade= pval.state.grade[,2]
  
  b.cons= data.frame(start)
  for (i in 1:nr) {
    x= b.cons[i,] + range* growth[i]  
    b.cons= rbind(b.cons,x)
  }
  adj = pval.state.grade-b.cons
  adj.mat= data.frame(bind_cols(grade=grlist, adj.cons=adj, state= rep(state,nr+1)))
  return(adj.mat)
}

getpc= function(embeddings) {
  ###  PCA embeddings
  pca_embeddings <- prcomp(embeddings, center = TRUE, scale = TRUE) #
  explained_variance <- summary(pca_embeddings)$importance[3, ]
  num_components <- which(cumsum(explained_variance) >= 0.80)[1]
  pca_embeddings_80 <- as.data.frame(pca_embeddings$x[, 1:num_components])
  return(pca_embeddings_80)
}