### sampling

set.seed(7)
sample_A = sample(which(aggregated_summary$cluster == 'A'), 3)
sample_B = sample(which(aggregated_summary$cluster == 'B'), 3)
sample_C = sample(which(aggregated_summary$cluster == 'C'), 3)
sample_D = sample(which(aggregated_summary$cluster == 'D'), 3)

cluster_samples_norm = aggregated_summary_data_scaling[c(sample_A, sample_B, sample_C, sample_D)]
cluster_samples = aggregated_summary[c(sample_A, sample_B, sample_C, sample_D)]

write.csv(cluster_samples, 'cluster_samples.csv')
write.csv(cluster_samples_norm, 'cluster_samples_norm.csv')

########################################################################################

tidy_dt <- aggregated_summary[, !'group_key',with=F]
tidy_norm_dt <- aggregated_summary_data_scaling

names(tidy_dt)
names(tidy_norm_dt)

View(tidy_dt[, lapply(.SD, mean), by=cluster])

# 
# library(PerformanceAnalytics)
# mydata <- data.frame(dt)[,-20]
# chart.Correlation(mydata, histogram=TRUE, pch=19)
# 
# 
# library(rpart)
# fit=rpart(factor(cluster)~., dt)
# plot(fit)
# text(fit)

require(randomForest)
dt = tidy_dt[,!cols,with=F]
fit=randomForest(factor(cluster)~., data=dt)
(VI_F=importance(fit))
varImpPlot(fit,type=2)

# View(tmp)

library(ggplot2)
dt = tidy_norm_dt
dt$cluster = as.factor(dt$cluster)
tmp =  melt(dt)
ggplot(tmp, aes(x=variable, y=value)) +
               geom_bar(stat='identity', aes(fill=cluster), position = "dodge")


range(summary_dt$c_16)
range(summary_dt$c_15)
range(summary_dt$c_14)
