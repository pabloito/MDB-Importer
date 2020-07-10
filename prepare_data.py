import pandas as pd
import sys


def remove_column(filename, keep_col):
    print('preparing '+ filename)
    df = pd.read_csv(filename)
    df = df[keep_col]
    df.to_csv(filename, index=False)


prepend = ''
if len(sys.argv) > 1:
    prepend = sys.argv[1]

filename = prepend + '/stop_times.txt'
keep_col = ['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence']
remove_column(filename, keep_col)


filename = prepend + '/trips.txt'
keep_col = ['route_id', 'service_id', 'trip_id', 'shape_id']
remove_column(filename, keep_col)

filename = prepend + '/shapes.txt'
keep_col = ['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence']
remove_column(filename, keep_col)

filename = prepend + '/stops.txt'
keep_col = ['stop_id', 'stop_lat', 'stop_lon']
remove_column(filename, keep_col)
