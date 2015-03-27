"""
Take the BODC current meter data and add it to a simple SQLite database.

"""

import os
import re
import csv
import sys
import sqlite3

import numpy as np


if __name__ == '__main__':

    noisy = True

    con = sqlite3.connect('./currents.db')
    cur = con.cursor()

    base = '/users/modellers/pica/Data/BODC/currents/2012/'
    metaDataFiles = (os.path.join(base, 'Moorinv.csv'))

    # Read the metadata into a dict
    f = open(metaDataFiles, 'rt')
    reader = csv.DictReader(f)

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
                    endDate TEXT COLLATE nocase \
                    )')
            cur.execute(meta)

            # Add each site and its associated metadata.
            for row in reader:

                row['name'] = os.path.splitext(row['Filename'].split('\\')[-1])[0].lower().strip()

                if noisy:
                    print('Adding station {}'.format(row['name']))

                try:
                    with open(os.path.join(base, 'formatted', '{}.lst'.format(row['name']))) as d:
                        rawdata = d.readlines()

                        dateval, timeval, dirval, speedval, flagval = [], [], [], [], []
                        for val in rawdata:
                            flag = False
                            line = filter(None, val.strip().split(' '))
                            # Skip a record if we're missing some aspect of the data.
                            if len(line) >= 5:
                                _, datestr, timestr, direction, speed = filter(None, val.strip().split(' '))[:5]
                            dateval.append(datestr.split('/'))
                            timeval.append(timestr.split('.'))
                            if speed[-1].isalpha():
                                speed = speed[:-1]
                                flag = True
                            if direction[-1].isalpha():
                                direction = direction[:-1]
                                flag = True
                            dirval.append(float(direction))
                            speedval.append(float(speed))
                            flagval.append(flag)

                    metadata = {}
                    metadata['start'] = dateval[0] + timeval[0]
                    metadata['end'] = dateval[-1] + timeval[-1]
                    metadata['lonDD'] = row['Longitude']
                    metadata['latDD'] = row['Latitude']

                    data = np.column_stack((dateval, timeval, speedval, dirval, flagval))

                    sYear, sMonth, sDay, sHour, sMin, sSec = np.array(metadata['start']).astype(int)
                    eYear, eMonth, eDay, eHour, eMin, eSec = np.array(metadata['end']).astype(int)

                    # Get the position for this site

                    cur.execute('INSERT INTO Stations VALUES( \
                            ?, ?, ?, ?, ?, ?, ?, ?)', (
                            float(metadata['latDD']),
                            float(metadata['lonDD']),
                            row['name'],
                            row['name'],
                            'BODC',
                            'British Oceanographic Data Centre',
                            '{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(
                                sYear, sMonth, sDay, sHour, sMin, sSec
                                ),
                            '{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(
                                eYear, eMonth, eDay, eHour, eMin, eSec
                                ),
                            )
                            )

                    # Create a table with all the possible data types we're likely
                    # to find from the BODC data. Some of these will be blank if we
                    # don't have any data for a given station.
                    query = re.sub(' +', ' ', 'CREATE TABLE {}(\
                            year INT, \
                            month INT, \
                            day INT, \
                            hour INT, \
                            minute INT, \
                            second INT, \
                            speed FLOAT(10), \
                            direction FLOAT(10), \
                            flag TEXT collate nocase)'.format(row['name']))

                    cur.execute(query)

                    try:
                        cur.executemany(
                                'INSERT INTO {} VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'.format(row['name']), data
                                )
                    except:
                        if noisy: print 'uh oh'
                        sys.exit(1)

                except sqlite3.Error, e:
                    print 'Problem with row {}'.format(e.args[0])
                    sys.exit(1)


    except sqlite3.Error, e:
        if con:

            con.rollback()

            print 'Error {}:'.format(e.args[0])
            sys.exit(1)

    finally:
        if con:
            con.commit()
            con.close()
        f.close()

