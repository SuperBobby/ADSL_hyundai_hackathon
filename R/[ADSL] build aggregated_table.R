library(Rtsne)
library(data.table)
library(base)
require(bit64)

## summary 파일의 위치를 모두 저장 
summary_path = dir("../data/", "summary",recursive=T)

## 각 운전자별 aggregated table을 담을 빈 리스트 생성 
dt_list = list(NULL)

## summary 파일의 위치를 모두 참조하여 불러들여
## 각 운전자의 aggreagted table 생성 후 
## dt_list안에 append 해서 저장해두는 루프   
for(path in summary_path){
        dt = fread(paste0('../data/', path))
        dt[, ':='(V1 = NULL, 
                  c_1 = NULL, c_2 = NULL, c_3 = NULL, c_4 = NULL, c_5 = NULL, 
                  c_27 = NULL)]
        print(paste(path, ':', nrow(dt)))
        
        agg_table <- dt[, .(group_key           = unique(c_0),          # 그룹키값
                            driving_duration    = sum(c_7) / sum(c_17), # 운행시간값
                            idel_duration       = sum(c_8) / sum(c_17), # 공회전시간수
                            heat_duration       = sum(c_9) / sum(c_17), # 예열시간수
                            
                            med_speed           = median(c_10),         # 속도의 중간값 
                            peak_speed          = quantile(c_11, 0.90), # 속도의 90th percentile값 
                            
                            speed1 = sum(c_12) / sum(c_17), # 저속운행초수
                            speed2 = sum(c_13) / sum(c_17), # 중저속운행초수
                            speed3 = sum(c_14) / sum(c_17), # 중속운행초수
                            speed4 = sum(c_15) / sum(c_17), # 중고속운행초수
                            speed5 = sum(c_16) / sum(c_17), # 고속운행초수
                            
                            acc1 = sum(c_18) / sum(c_6), # 급가속 7~10
                            acc2 = sum(c_19) / sum(c_6), # 급가속 11~13
                            acc3 = sum(c_20) / sum(c_6), # 급가속 14~17
                            acc4 = sum(c_21) / sum(c_6), # 급가속 18~
                            
                            ret1 = sum(c_22) / sum(c_6), # 급감속 ~ 21
                            ret2 = sum(c_23) / sum(c_6), # 급감속 18~21
                            ret3 = sum(c_24) / sum(c_6), # 급감속 14~17
                            ret4 = sum(c_25) / sum(c_6), # 급감속 11~13
                            ret5 = sum(c_26) / sum(c_6), # 급감속 7~10
                            total_duration = sum(c_17),
                            total_distance = sum(c_6)) 
                        ]  
        
        print(agg_table)
        dt_list = append(dt_list, list(agg_table))
}

### Build aggregated table ---#
aggregated_summary = dt_list[[2]]
for(i in 3:91){
        aggregated_summary = rbind(aggregated_summary, dt_list[[i]])
}

### Add extra features & normalizing by total_distance & total_duraton 
aggregated_summary = merge(aggregated_summary, extra_features, by='group_key')

aggregated_summary[, ':='(weekday_driving_ratio = weekday_driving_ratio,
                          hvac_on_ratio = hvac_on_mean/total_duration,
                          energy_eff_mean = energy_eff_mean, 
                          large_steering_angle_diff_mean = large_steering_angle_diff_sum/total_distance), by=group_key]

aggregated_summary[, ':='(total_duration = NULL, total_distance = NULL, 
                          large_steering_angle_diff_sum = NULL,
                          hvac_on_mean = NULL)]

### Scaling non-normalized extra features 
group_key = aggregated_summary$group_key
aggregated_summary_data_scaling = aggregated_summary[, !'group_key', with=F]
aggregated_summary_data_scaling <- aggregated_summary_data_scaling[, lapply(.SD, scale)]

### check scaling result
apply(aggregated_summary_data_scaling, 2, mean)
apply(aggregated_summary_data_scaling, 2, sd)

### Set clustering data 
clustering_data = aggregated_summary[,!'group_key',with=F]
clustering_data$med_speed = scale(clustering_data$med_speed)
clustering_data$peak_speed = scale(clustering_data$peak_speed)

# names(clustering_data)
# dim(clustering_data)
# summary(clustering_data)

### RtSNE -------------------------------------- ###
data_label = "hyundai hackathon"
perplexity = 5
max_iter = 2000

# using Rtsne
set.seed(1) # for reproducibility
ptm <- proc.time()
Rtsne_output <- Rtsne(clustering_data, verbose=TRUE, 
#                       initial_dims = initial_dims,
                      perplexity   = perplexity, 
                      max_iter     = max_iter)
Rtsne_elapsed_time = proc.time() - ptm

# visualizing t-sne 
plot_title = paste(
#                 '[',data_label,']', ": RtSNE", 
#                    "/initial_dims:",initial_dims, 
                   "/perplexity:", perplexity,
                   "/max_iter:", max_iter, "/elapsed:", round(Rtsne_elapsed_time[3],2))

map_dt = Rtsne_output$Y
plot(Rtsne_output$Y, main=plot_title)


### hierarchical clustering ----------------------### --> 4 clusters 
d <- dist(as.matrix(map_dt))   # find distance matrix 
hc <- hclust(d)                # apply hirarchical clustering 
plot(hc, main=paste(data_label, '- hierarchical clustering'))  

## Look for a bend or elbow in the sum of squared error (SSE) scree plot -----### --> 4 clusters 
mydata <- data.frame(map_dt)
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(mydata,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares", main='hyundai hackathon : k-means (Within groups sum of squares)')

### Label each cluster 
n_cluster= 4
set.seed(1)
mydata <- data.frame(map_dt)
k <- kmeans(mydata, centers=n_cluster, nstart=25, algorithm='MacQueen')
plot(map_dt, col=(k$cluster +1), 
     main=paste0("K-Means Clustering from t-SNE(",plot_title,")"), xlab="", ylab="", pch=20, cex=2)

aggregated_summary_data_scaling = cbind(aggregated_summary_data_scaling, cluster = LETTERS[k$cluster])
aggregated_summary = cbind(aggregated_summary, cluster = LETTERS[k$cluster])

## Save tidy data
write.csv(aggregated_summary_data_scaling, 'aggregated_summary_norm(tidy4).csv')
write.csv(aggregated_summary, 'aggregated_summary(tidy4).csv')
