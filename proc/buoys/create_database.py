"""
Take buoy data from CEFAS, WCO and CCO and dump to a queryable SQLite database.

The easiest way to interrogate the data will be first by position, then by
time.

"""

import sqlite3
import csv
import sys
import os

import numpy as np

if __name__ == '__main__':

    noisy = True

    con = sqlite3.connect('./buoys.db')
    cur = con.cursor()

    bases = ('/users/modellers/pica/Data/WCO/',
            '/users/modellers/pica/Data/CCO/Waves',
            '/users/modellers/pica/Data/CEFAS/WaveNet')

    for base in bases:

        metaDataFile = (os.path.join(base, 'locations.csv'))

        # Read the metadata into a dict
        f = open(metaDataFile, 'rt')
        reader = csv.DictReader(f)

        # Create a new database and add the metadata to a field called Stations with
        # some of the metadata fields.
        try:
            with con:
                try:
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
                except:
                    pass

                # Now add the metadata.
                for row in reader:
                    if noisy:
                        print('Adding station {}'.format(row['name']))

                    try:
                        # Save the current site ID. Try lowercase first, then upper case.
                        try:
                            site = row['name'].replace(' ', '_').lower()
                            data = np.genfromtxt(os.path.join(base,
                                                              'formatted',
                                                              '{}.csv'.format(site.replace('_', '-'))),
                                                 delimiter=',',
                                                 skip_header=1)
                        except IOError:
                            site = row['name'].replace(' ', '_')
                            data = np.genfromtxt(os.path.join(base,
                                                              'formatted',
                                                              '{}.csv'.format(site.replace('_', '-'))),
                                                 delimiter=',',
                                                 skip_header=1)

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
                            break

                    except sqlite3.Error, e:
                        print 'Problem with row {}'.format(e.args[0])


        except sqlite3.Error, e:
            if con:

                con.rollback()

                print 'Error {}:'.format(e.args[0])
                break

    if con:
        con.commit()
        con.close()
    f.close()
