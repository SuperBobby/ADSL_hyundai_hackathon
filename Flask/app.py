from flask import Flask, request, abort, render_template, flash, url_for
import pandas as pd
import numpy as np
import json

app = Flask(__name__)

@app.route("/")
@app.route("/home")
def home():
	return render_template('index.html')


@app.route("/recommend")
def recommend():
	return render_template('recommend.html', )


@app.route("/handle_match_request", methods = ['POST'])
def handle_match_request():
	driver_id = int(request.form['driver_id'])
	

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
	return json.dumps(resp)


@app.route('/show_match/<int:driver_id>')
def show_match(driver_id):
	return render_template('show_match.html', driver_id=driver_id)


def get_cos_sim(vec1, vec2):
	dot_val = np.dot(vec1,vec2)
	vec1_size = np.sqrt(vec1.dot(vec1))
	vec2_size = np.sqrt(vec2.dot(vec2))
	cos_sim = dot_val/(vec1_size * vec2_size)
	return round(cos_sim*50 + 50, 2)


if __name__ == "__main__":
    app.run(debug=True)