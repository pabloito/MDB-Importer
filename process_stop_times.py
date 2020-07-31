import datetime
import sys

import pandas as pd
import os


class gtfs_time:
    def __init__(self, h, m, s):
        self.hour = h
        self.min = m
        self.sec = s

    def __str__(self):
        return "{0:0=2d}:{1:0=2d}:{2:0=2d}".format(self.hour, self.min, self.sec)


def get_time(string):
    h, m, s = string.split(':')
    return gtfs_time(int(h), int(m), int(s))


def compare(time1, time2):
    return 3600*(time1.hour-time2.hour)+60*(time1.min-time2.min)+time1.sec-time2.sec


def increase(time):
    ret = gtfs_time(time.hour, time.min, time.sec)
    ret.sec += 1
    if ret.sec < 60:
        return ret
    ret.sec %= 60
    ret.min += 1
    if ret.min < 60:
        return ret
    ret.min %= 60
    ret.hour += 1
    return ret


def process_stop_times(path):
    filename = path + "/stop_times.txt"
    print('processing :  ' + filename)

    chunksize = 10 ** 6
    suffix = '-processed'
    header_flag = True

    # Get first Row
    chunk1 = pd.read_csv(filename, nrows=1)
    chunk1.to_csv(filename + suffix, index=False, header=True, mode='a')
    prev_time = get_time(chunk1['departure_time'][0])
    prev_trip = chunk1['trip_id'][0]

    skiprows = [1]
    for chunk in pd.read_csv(filename, skiprows=skiprows, chunksize=chunksize):
        for index, row in chunk.iterrows():
            arr_time = get_time(row['arrival_time'])
            dep_time = get_time(row['departure_time'])
            trip = row['trip_id']
            if (prev_trip == trip) & (compare(arr_time, prev_time) <= 0):
                arr_time = increase(prev_time)
                row['arrival_time'] = str(arr_time)
                if compare(dep_time, arr_time) <= 0:
                    dep_time = arr_time
                    row['departure_time'] = str(dep_time)
                chunk.loc[index] = row
            prev_time = dep_time
            prev_trip = row['trip_id']
        chunk.to_csv(filename + suffix, index=False, header=False, mode='a')
        skiprows = []

    os.remove(filename)
    os.rename(filename + suffix, filename)

process_stop_times(sys.argv[1])