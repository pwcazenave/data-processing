"""
Take the CTD cast data from the BODC archive within the area I'm interested in
and add it to a simple SQLite database. The easiest way to interrogate the data
will be first by position, then by time. Each cast is stored as a separate
record (with the variable axis being depth).

"""

import sqlite3
import csv
import sys
import os
import re

import numpy as np

def readTimeseries(file, noisy=False):
    """ Read a raw data file into a NumPy array. """


if __name__ == '__main__':

    noisy = True

    con = sqlite3.connect('./buoys.db')
    cur = con.cursor()

    base = '/users/modellers/pica/Data/CEFAS/WaveNet'
    metaDataFiles = (os.path.join(base, 'locations.csv'))

    # Read the metadata into a dict
    f = open(metaDataFiles, 'rt')
    reader = csv.DictReader(f)

    # Create a new database and add the metadata to a field called Stations with
    # some of the metadata fields.
    try:
        with con:
            cur.execute('\
                    CREATE TABLE Stations(\
                    Name TEXT COLLATE nocase, \
                    Latitude FLOAT(10), \
                    Longitude FLOAT(10), \
                    StartDate TEXT COLLATE nocase, \
                    yearStart INT, \
                    monthStart INT, \
                    dayStart INT, \
                    hourStart INT, \
                    minuteStart INT, \
                    secondStart INT, \
                    EndDate TEXT COLLATE nocase, \
                    yearEnd INT, \
                    monthEnd INT, \
                    dayEnd INT, \
                    hourEnd INT, \
                    minuteEnd INT, \
                    secondEnd INT);')

            # Now add the metadata.
            for row in reader:
                if noisy:
                    print('Adding station {}'.format(row['name']))

                try:
                    # Save the current site ID.
                    site = row['name'].replace(' ', '_').lower()

                    data = np.genfromtxt(os.path.join(base, 'formatted', site.replace('_', '-') + '.csv'), delimiter=',', skip_header=1)

                    sYear, sMonth, sDay, sHour, sMin, sSec = data[0, 0:6].astype(int)
                    eYear, eMonth, eDay, eHour, eMin, eSec = data[-1, 0:6].astype(int)

                    # Get the position for this site

                    cur.execute('\
                            INSERT INTO Stations VALUES(\
                            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', (\
                            site, \
                            float(row['latDD']), \
                            float(row['lonDD']), \
                            '{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(sYear, sMonth, sDay, sHour, sMin, sSec), \
                            int(sYear), \
                            int(sMonth), \
                            int(sDay), \
                            int(sHour), \
                            int(sMin), \
                            int(sSec), \
                            '{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(eYear, eMonth, eDay, eHour, eMin, eSec), \
                            int(eYear), \
                            int(eMonth), \
                            int(eDay), \
                            int(eHour), \
                            int(eMin), \
                            int(eSec)))

                    # Create a table with all the possible data types we're likely
                    # to find from the BODC data. Some of these will be blank if we
                    # don't have any data for a given station.
                    query = 'CREATE TABLE {}(\
                            year INT, \
                            month INT, \
                            day INT, \
                            hour INT, \
                            minute INT, \
                            second INT, \
                            temperature FLOAT(10))'.format(site)

                    cur.execute(query)

                    # I can't get the 'safe' way to work, so we'll have to be 'unsafe'. Ho hum.
                    #cur.execute('INSERT INTO ? (?) VALUES (?)', (site, ','.join(s), ','.join([str(i) for i in v.tolist()])))
                    try:
                        cur.executemany('INSERT INTO {} VALUES (?, ?, ?, ?, ?, ?, ?)'.format(site), data)
                    except:
                        if noisy: print 'uh oh'
                        sys.exit(1)

                except sqlite3.Error, e:
                    print 'Problem with row {}'.format(e.args[0])


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
