import pandas as pd
import numpy as np
import json


def get_cos_sim(vec1, vec2):
	dot_val = np.dot(vec1,vec2)
	vec1_size = np.sqrt(vec1.dot(vec1))
	vec2_size = np.sqrt(vec2.dot(vec2))
	cos_sim = dot_val/(vec1_size * vec2_size)
	return round(cos_sim*50 + 50, 2)


driver_id = 3

data_path = 'C:/developments/pythonprac/hackathon/data/twelve_cars.csv'
my_data_path = 'C:/developments/pythonprac/hackathon/data/my_car.csv'
norm_data_path = 'C:/developments/pythonprac/hackathon/data/twelve_cars_norm.csv'
norm_my_data_path = 'C:/developments/pythonprac/hackathon/data/my_car_norm.csv'

my_data = pd.read_csv(my_data_path)
norm_my_data = pd.read_csv(norm_my_data_path)
data = pd.read_csv(data_path)
norm_data = pd.read_csv(norm_data_path)


my_vec = my_data.ix[0,1:24].values.astype(float)
norm_my_vec = norm_my_data.ix[0,1:24].values.astype(float)
your_vec = data.ix[driver_id-1,1:24].values.astype(float)
norm_your_vec = norm_data.ix[driver_id-1,1:24].values.astype(float)


resp = {}

resp['my_vec'] = my_vec.tolist()
resp['norm_my_vec'] = norm_my_vec.tolist()
resp['your_vec'] = your_vec.tolist()
resp['norm_your_vec'] = norm_your_vec.tolist()
resp['my_type'] = my_data.ix[0,24]
resp['your_type'] = data.ix[driver_id-1,24]
resp['cos_sim'] = get_cos_sim(norm_my_vec, norm_your_vec)

print len(my_vec.tolist())
print len(norm_my_vec.tolist())
print len(your_vec.tolist())
print len(norm_your_vec.tolist())
print get_cos_sim(norm_my_vec, norm_your_vec)

print resp
print json.dumps(resp)
