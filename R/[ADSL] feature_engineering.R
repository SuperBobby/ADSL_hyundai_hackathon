library(stringr)
library(timeDate)

file_path = dir("../data/drive/" ,recursive=T)

summary_index = which(grepl(x = file_path, 'summary'))

drive_path = file_path[-summary_index]

group_keys = character(0)
weekday_driving = numeric(0) # 주중비율 
hvac_on_count = numeric(0) # 에어컨 켠 비율 
energy_efficiency = numeric(0) # 연료 소모율 평균 
large_steering_angle_diff = numeric(0) # 큰 각도 꺾은 수 

total_driving_duration = numeric(0)

for(path in drive_path) {
                
        dt = fread(paste0('../data/drive/', path))
        
        group_key_string = substr(path, 3, 34)
        
        print(path)
        
        group_keys = c(group_keys, group_key_string)
        weekday_driving = c(weekday_driving, isWeekday(dt$c_1[1]))
        hvac_on_count = c(hvac_on_count, sum(dt$c_8 == 1))
        energy_efficiency = c(energy_efficiency, mean(dt$c_5))
        large_steering_angle_diff = c(large_steering_angle_diff, sum(diff(dt$c_12)>60))
}

features_raw = data.table(group_key = group_keys, weekday_driving, hvac_on_count, energy_efficiency, large_steering_angle_diff)
extra_features = features_raw[, .(weekday_driving_ratio = mean(weekday_driving),
                                  hvac_on_mean = mean(hvac_on_count),
                                  energy_eff_mean = mean(energy_efficiency),
                                  large_steering_angle_diff_sum = sum(large_steering_angle_diff)), by=group_key]