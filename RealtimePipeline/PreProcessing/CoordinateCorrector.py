import pandas as pd

reader = pd.read_csv(r'/home/juangod/Documents/positions.csv', chunksize=10000)

output_path = 'positions_coordinates_inverted.csv'

header_flag = True

for i, chunk in enumerate(reader):
    for idx, val in enumerate(chunk["latitude"]):
        if (val > 0):
            chunk["latitude"][i*10000+idx] = chunk["latitude"][i*10000+idx]*-1
        #chunk["latitude"][i*10000+idx] = round(chunk["latitude"][i*10000+idx], 5)

    for idx, val in enumerate(chunk["longitude"]):
        if (val > 0):
            chunk["longitude"][i*10000+idx] = chunk["longitude"][i*10000+idx]*-1
        #chunk["longitude"][i*10000+idx] = round(chunk["longitude"][i*10000+idx], 5)
    chunk.to_csv(output_path, index=False, header=header_flag, mode='a')
    header_flag = False