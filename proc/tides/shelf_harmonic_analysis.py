#!/usr/bin/env python

"""
Extract all the data from the SQL database of tides and use tappy.py to
calculate the tidal constituents for each station.

"""

import numpy as np
import csv
import subprocess
import sys
import os

from PyFVCOM.tide_tools import getObservedData, addHarmonicResults, parseTAPPyXML


if __name__ == '__main__':

    # Be verbose
    noisy = True

    # Shouldn't have a header. Don't do the SHOM data (it's too crappy)
    metaDataFiles = ['../../NTSLF/shelf_stations_sql.csv',\
                     '../../NSTD/shelf_stations_single_years_sql.csv',\
                     '../../NTSLF/BPR/shelf_stations_sql.csv',\
                     '../../REFMAR/shelf_stations_sql.csv']

    # TAPPY format definition file
    formatFile = '/users/modellers/pica/Data/proc/tides/sparse.def'

    for file in metaDataFiles:

        fileHandle = csv.reader(open(file, 'r'))
        for row in fileHandle:

            # Set the skip flag to True so we don't skip by default. Only
            # change to False if we have to skip this station.
            doStation = True

            # Tables in the SQL database are named by the shortName value.
            # This should be the third column in the current line
            tableName = row[2]

            # Check if the XML file for the current station already exists, and
            # if so, move along to the next station.
            try:
                f = open('./harmonics/' + tableName + '.xml', 'r')
                f.close()
                print 'Analysis already completed for {}. Skipping.'.format(tableName)
                sys.stdout.flush()
            except:
                # Use getObservedData() to extract all the data for each table
                currData = getObservedData('./tides.db', tableName,
                        1960, 2013, noisy=noisy)

                # Check we have some data
                if len(currData) != 0:
                    # Convert to a NumPy array and separate the quality out.
                    # Throw away the residuals. This isn't pretty, but I
                    # haven't found a better way to convert mixed data types
                    # like numbers and letters.

                    obsData = []
                    obsFlags = []
                    for rowData in currData:
                        obsData.append(rowData[0:-2])
                        obsFlags.append(rowData[-1])

                    obsData = np.asarray(obsData, dtype=float)
                    obsFlags = np.asarray(obsFlags, dtype=str)

                    # Remove NaN and unlikely (anything below -9999) values.
                    obsData = obsData[obsFlags == 'P']
                    obsData = obsData[obsData[:,6] > -9999]
                    # Strip out impossible time values too.
                    obsData = obsData[np.logical_and(obsData[:,3] < 24, obsData[:,4] < 60), :]

                    # Sort the data so that times are always increasing
                    # (apparently some of the SHOM data aren't in the right
                    # order).
                    #obsData = np.sort(obsData, 0)

                    # Until I can figure out how to get tappy to read the
                    # results from the numpy array I've created, dump it to a
                    # file and then use that in the call to tappy. This is not
                    # ideal.
                    if noisy:
                        print 'Saving station {} to /tmp/data_{}.txt...'.format(row[3].title(), tableName),
                        sys.stdout.flush()
                    np.savetxt('/tmp/data_' + tableName + '.txt', obsData, fmt='%4i/%02i/%02i %02i:%02i:%02i %.3f')
                    if noisy:
                        print 'done.'
                        sys.stdout.flush()

                    if noisy:
                        print 'Running TAPPy on the data...',
                        sys.stdout.flush()

                    # This is a bit of a hack. It ought to be possible to
                    # import tappy and use the data directly with the imported
                    # library, but I can't figure out how to do it. So,
                    # instead, we'll do this the hard way:
                    #   1. Run TAPPY on the saved file and output to XML
                    #   2. Parse the XML and add the relevant values to an SQL
                    #   database.

                    subprocess.call(['/usr/bin/tappy.py', 'analysis', '--def_filename=' + formatFile, '--outputxml=./harmonics/' + tableName + '.xml', '--quiet', '/tmp/data_' + tableName + '.txt'])

                else:
                    print 'No observed data for the time period selected for analysis...',
                    sys.stdout.flush()
                    doStation = False

                # Remove the temporary file we created upon which to run TAPPy
                try:
                    os.remove('/tmp/data_' + tableName + '.txt')
                except:
                    if doStation:
                        print 'Unable to remove /tmp/data_{}.txt. File may be locked or you don\'t have permissions.'.format(tableName)
                        sys.stdout.flush()

                if noisy:
                    print 'done.'
                    sys.stdout.flush()


            # Now I need to read in the xml file and add the results to an SQL
            # database.
            if doStation:
                if noisy:
                    print 'Adding station ' + tableName + ' harmonics to database: ',
                    sys.stdout.flush()

                try:
                    [cName, cSpeed, cPhase, cAmplitude, cInference] = parseTAPPyXML('./harmonics/' + tableName + '.xml')
                except IOError:
                    print 'Unable to open constituent XML file. Skipping {}.'.format(tableName)
                    sys.stdout.flush()
                    continue

                # Now add all those values to the database
                addHarmonicResults('harmonics.db',\
                        tableName,\
                        cName,\
                        cPhase,\
                        cAmplitude,\
                        cSpeed,\
                        cInference,\
                        noisy=noisy)

                if noisy:
                    print 'done.'
                    sys.stdout.flush()

            else:
                print 'Skipping ' + tableName + '.'
                sys.stdout.flush()


