import pandas as pd

def remove_column(filename, delete_col):
	df=pd.read_csv(filename)
	keep_col = []
	for col in df:
		if not col in delete_col:
			keep_col.append(col)
	df = df[keep_col]
	df.to_csv(filename, index=False)


filename = 'stop_times.txt'
delete_col= ['shape_dist_traveled','stop_headsign']
remove_column(filename,delete_col)

filename = 'trips.txt'
delete_col= ['trip_short_name']
remove_column(filename,delete_col)

filename = 'agency.txt'
delete_col= ['agency_fare_url']
remove_column(filename,delete_col)

filename = 'routes.txt'
delete_col= ['agency_id']
remove_column(filename,delete_col)

filename = 'shapes.txt'
delete_col= ['shape_dist_traveled']
remove_column(filename,delete_col)

filename = 'stops.txt'
delete_col= ['wheelchair_boarding']
remove_column(filename,delete_col)

df = pd.read_csv('stops.txt')
df['parent_station'] = df['parent_station'].astype('Int64')
df.to_csv('stops.txt', index=False)