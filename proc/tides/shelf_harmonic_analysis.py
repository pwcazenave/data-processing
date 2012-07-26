#!/usr/bin/env python

"""
Extract all the data from the SQL database of tides and use tappy.py to
calculate the tidal constituents for each station.

"""

import numpy as np
import csv
import subprocess

import tappy

from read_observed_data import getObservedData

# Be verbose
noisy = True

# Shouldn't have a header
metaDataFiles = ['../../NTSLF/shelf_stations_sql.csv', '../../SHOM/shelf_stations_sql_edited.csv', '../../NSTD/shelf_station_single_years_sql.csv', '../../NTSLF/BPR/shelf_staions_sql.csv']

# TAPPY format definition file
formatFile = '/users/modellers/pica/Work/data/proc/tides/sparse.def'

for file in metaDataFiles:

    fileHandle = csv.reader(open(file, 'r'))
    for row in fileHandle:
        # Tables in the SQL database are named by the shortName value.
        # This should be the third column in the current line
        tableName = row[2]

        # Use getObservedData() to extract all the data for each table
        currData = getObservedData('../../NTSLF/tides.db', tableName, 1990, 2012, noisy=noisy)

        # Convert to a NumPy array and separate the quality out. Throw away the
        # residuals. This isn't pretty, but I haven't found a better way to
        # convert mixed data types like numbers and letters.
        obsData = []
        obsFlags = []
        for rowData in currData:
            obsData.append(rowData[0:-2])
            obsFlags.append(rowData[-1])

        obsData = np.asarray(obsData, dtype=float)
        obsFlags = np.asarray(obsFlags)

        # Remove NaN values too
        obsData = obsData[np.logical_and(obsFlags == 'P', obsData[:,6] > -9999), :]

        # Until I can figure out how to get tappy to read the results from the
        # numpy array I've created, dump it to a file and then use that in the
        # call to tappy. This is not ideal.
        if noisy:
            print 'Saving station {} to /tmp/data.txt...'.format(row[3].title()),
        np.savetxt('/tmp/data.txt', obsData, fmt='%4i/%02i/%02i %02i:%02i:%02i %.3f')
        if noisy:
            print 'done.'

        if noisy:
            print 'Running TAPPY on the data...',
        # This is a bit of a hack. It ought to be possible to import tappy and
        # use the data directly with the imported library, but I can't figure
        # out how to do it. So, instead, we'll do this the hard way:
        #   1. Run TAPPY on the saved file output to XML
        #   2. Parse the XML and create a dict for the current site
        #   3. Add the dict to a new database with just the harmonic constituents

        subprocess.call(['/usr/bin/tappy.py', 'analysis', '--def_filename=' + formatFile, '--outputxml=' + tableName + '.xml', '--quiet', '/tmp/data.txt'])

        #results = tappy.analysis('/tmp/data.txt', def_filename = formatFile)

        if noisy:
            print 'done.'

        #print results

