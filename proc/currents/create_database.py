"""
Take the BODC current meter data and add it to a simple SQLite database.

"""

import os
import re
import sys
import pandas
import sqlite3

import numpy as np

from datetime import datetime


if __name__ == '__main__':

    noisy = True

    con = sqlite3.connect('./currents.db')
    cur = con.cursor()

    base = '/users/modellers/pica/Data/BODC/currents/2015/'
    metaDataFiles = (os.path.join(base, 'metadata', 'bodc_series_metadata_summary.csv'))

    # Read the metadata into a pandas dataframe.
    metadata = pandas.read_csv(metaDataFiles, header=23, parse_dates={'start_time':[9], 'end_time':[10]}, na_values=[-99, -999])

    # Create a new database and add the metadata to a field called Stations with
    # some of the metadata fields.
    try:
        with con:
            meta = re.sub(' +', ' ', 'CREATE TABLE Stations(\
                    latDD FLOAT(10), \
                    lonDD FLOAT(10), \
                    shortName TEXT COLLATE nocase, \
                    longName TEXT COLLATE nocase, \
                    originatorName TEXT COLLATE nocase, \
                    originatorLongName TEXT COLLATE nocase, \
                    startDate TEXT COLLATE nocase, \
                    endDate TEXT COLLATE nocase, \
                    depth FLOAT(10) \
                    )')
            cur.execute(meta)

            # Add each site and its associated metadata.
            for row in metadata.iterrows():

                _, currsite = row
                start, end = currsite['start_time'], currsite['end_time']
                site = 'b{:07d}'.format(currsite['BODC reference'])

                if noisy:
                    print('Adding station {}'.format(site))

                try:
                    # This is probably more robustly done with a pandas
                    # dataframe, but I'd already written this so it stays
                    # unless something horrible breaks.
                    datafile = os.path.join(base, 'formatted', '{}.csv'.format(site))
                    with open(datafile) as d:
                        rawdata = d.readlines()

                        dateval, timeval, dirval, speedval, flagval = [], [], [], [], []
                        for line in rawdata:
                            datestr, timestr, direction, speed, flag = line.strip().split(',')
                            dateval.append(datestr.split('/'))
                            timeval.append(timestr.split(':'))
                            dirval.append(direction)
                            speedval.append(speed)
                            flagval.append(flag[0])

                    data = np.column_stack((dateval, timeval, speedval, dirval, flagval))

                except IOError:
                    print('WARNING: Unable to open data file {}'.format(datafile))
                    continue

                # Find dodgy end times if the metadata didn't have the correct
                # end time.
                if pandas.isnull(end):
                    times = np.column_stack((dateval, timeval)).astype(int)
                    end = [datetime(*i) for i in times][-1]

                try:
                    # Do the SQLite stuff.

                    # Get the position for this site and add it to the Stations table.
                    cur.execute(re.sub(' +', ' ', 'INSERT INTO Stations VALUES(\
                            ?, ?, ?, ?, ?, ?, ?, ?, ?)'), (
                            float(currsite['Latitude A']),
                            float(currsite['Longitude A']),
                            site,
                            str(currsite['BODC reference']),
                            ''.join([i[0] for i in currsite['Organisation'].split(' ') if i if i[0].isupper()]),
                            currsite['Organisation'],
                            '{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(
                                start.year, start.month, start.day,
                                start.hour, start.minute, start.second
                                ),
                            '{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(
                                end.year, end.month, end.day,
                                end.hour, end.minute, end.second
                                ),
                            currsite['Series depth minimum (m)']
                            )
                            )

                    # Create new table for this site in the database.
                    query = re.sub(' +', ' ', 'CREATE TABLE {}(\
                            year INT, \
                            month INT, \
                            day INT, \
                            hour INT, \
                            minute INT, \
                            second INT, \
                            speed FLOAT(10), \
                            direction FLOAT(10), \
                            flag TEXT collate nocase)'.format(site))

                    cur.execute(query)

                    # Populate the table with the time series.
                    cur.executemany(
                            'INSERT INTO {} VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'.format(site), data
                            )

                except Exception:
                    raise Exception('Error adding site {} table.'.format(site))

    except sqlite3.Error, e:
        if con:

            con.rollback()

            print 'Error {}:'.format(e.args[0])
            sys.exit(1)

    finally:
        if con:
            con.commit()
            con.close()

