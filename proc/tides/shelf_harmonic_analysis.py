#!/usr/bin/env python

"""
    Extract all the data from the SQL database of tides and use tappy.py to
    calculate the tidal constituents for each station.

"""

import csv
import tappy

from read_observed_data import getObservedData

# Shouldn't have a header
metaDataFiles = ['../../data/NTSLF/shelf_stations_sql.csv', '../../data/SHOM/shelf_stations_sql_edited.csv', '../../data/NSTD/shelf_station_single_years_sql.csv', '../../data/NTSLF/BPR/shelf_staions_sql.csv']

for file in metaDataFiles:

    fileHandle = csv.reader(open(file, 'r'))
    for row in fileHandle:
        # Tables in the SQL database are named by the shortName value.
        # This should be the third column in the current line
        tableName = row[2]

        # Use getObservedData() to extract all the data for each table
        currData = getObservedData('../../data/NTSLF/tides.db', tableName, noisy=True)

        # Convert to a NumPy array and throw away the quality and residuals.
        # This isn't pretty, but I haven't found a better way to convert mixed
        # data types like numbers and letters.
        obsData = []
        for row in currData:
            obsData.append(row[0:-2])
        obsData = np.asarray(obsData, dtype=float)

        # Run tappy and save the output (somehow)
        results = tappy.analysis(currData, def_filename = 'sparse.def')
        #run tappy.py
