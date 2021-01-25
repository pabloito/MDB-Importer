import pandas as pd
import os


def remove_column(filename, keep_col):
    print('preparing '+ filename)

    chunksize = 10 ** 6
    suffix = '-processed'
    header_flag = True

    for chunk in pd.read_csv(filename, chunksize=chunksize):
        df = chunk[keep_col]
        df.to_csv(filename+suffix, index=False, header=header_flag, mode='a')
        header_flag = False

    os.remove(filename)
    os.rename(filename+suffix, filename)


def prepare_data(path):
    filename = path + '/stop_times.txt'
    keep_col = ['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence']
    remove_column(filename, keep_col)

    filename = path + '/trips.txt'
    keep_col = ['route_id', 'service_id', 'trip_id', 'shape_id']
    remove_column(filename, keep_col)

    filename = path + '/shapes.txt'
    keep_col = ['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence']
    remove_column(filename, keep_col)

    filename = path + '/stops.txt'
    keep_col = ['stop_id', 'stop_lat', 'stop_lon']
    remove_column(filename, keep_col)

prepare_data('.')