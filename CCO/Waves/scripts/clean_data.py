from __future__ import print_function

import os
import sys
import csv
import glob

import numpy as np
import pandas as pd

meta = open('locations.csv', 'w')
meta.write('latDD,lonDD,name\n')

for buoy in glob.glob('clean/*.txt'):
    base, fname = os.path.split(buoy)
    site = os.path.splitext(fname)[0]

    print('Working on site {}... '.format(site), end='')
    sys.stdout.flush()

    fout = os.path.join('formatted', '{}.csv'.format(site))
    data = pd.read_table(buoy,
            parse_dates=[0],
            skipinitialspace=True,
            na_values=[9999])

    # Find the keys for the data we're interested in. This is because one file
    # (ONE!) has a different header format.
    keys = {}
    if 'Longitude' in data:
        keys['date'] = 'Date/Time (GMT)'
        keys['lon'] = 'Longitude'
        keys['lat'] = 'Latitude'
        keys['temp'] = 'SST (deg C)'
    elif 'Long' in data:
        keys['date'] = 'Date/Time (GMT)'
        keys['lon'] = 'Long'
        keys['lat'] = 'Lat'
        keys['temp'] = 'SST'

    # Save the data to file with the format expected by the create_database.py
    # script.
    year = [i.year for i in data[keys['date']]]
    month = [i.month for i in data[keys['date']]]
    day = [i.day for i in data[keys['date']]]
    hour = [i.hour for i in data[keys['date']]]
    minute = [i.minute for i in data[keys['date']]]
    second = [i.second for i in data[keys['date']]]
    temp = data[keys['temp']].values
    out = np.column_stack((year, month, day, hour, minute, second, temp))
    if np.sum(np.isnan(out[:, -1])) == len(temp):
        print('skipping (no valid temperature data).')
        continue

    # Save the median location for the current data set to a metadata file.
    meta.write('{},{},{:s}\n'.format(
        data[keys['lat']].median(), data[keys['lon']].median(), site
        ))

    with open(fout, 'w') as f:
        f.write('yyyy,mm,dd,HH,MM,SS,temperature\n')
        for line in out:
            if not np.isnan(line[-1]):
                f.write(
                        '{:04d},{:02d},{:02d},{:02d},{:02d},{:02d},{:.2f}\n'.format(
                            int(line[0]),
                            int(line[1]),
                            int(line[2]),
                            int(line[3]),
                            int(line[4]),
                            int(line[5]),
                            line[6]))

    print('done.')

meta.close()
