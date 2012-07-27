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

from lxml import etree

from tide_tools import getObservedData, addHarmonicResults


if __name__ == '__main__':

    # Be verbose
    noisy = True

    # Shouldn't have a header
    metaDataFiles = ['../../../NTSLF/shelf_stations_sql.csv',\
                     '../../../SHOM/shelf_stations_sql_edited.csv',\
                     '../../../NSTD/shelf_station_single_years_sql.csv',\
                     '../../../NTSLF/BPR/shelf_staions_sql.csv']

    # TAPPY format definition file
    formatFile = '/users/modellers/pica/Work/data/proc/tides/sparse.def'

    for file in metaDataFiles:

        fileHandle = csv.reader(open(file, 'r'))
        for row in fileHandle:
            # Tables in the SQL database are named by the shortName value.
            # This should be the third column in the current line
            tableName = row[2]

            # Check if the XML file for the current station already exists, and
            # if so, move along to the next station.
            try:
                f = open(tableName + '.xml', 'r')
                f.close()
                print 'Analysis already completed. Skipping.'
            except:
                # Use getObservedData() to extract all the data for each table
                currData = getObservedData('../../../NTSLF/tides.db', tableName,
                        1990, 2012, noisy=noisy)

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
                    print 'Saving station {} to /tmp/data_{}.txt...'.format(row[3].title(), tableName),
                np.savetxt('/tmp/data_' + tableName + '.txt', obsData, fmt='%4i/%02i/%02i %02i:%02i:%02i %.3f')
                if noisy:
                    print 'done.'

                if noisy:
                    print 'Running TAPPY on the data...',
                # This is a bit of a hack. It ought to be possible to import tappy and
                # use the data directly with the imported library, but I can't figure
                # out how to do it. So, instead, we'll do this the hard way:
                #   1. Run TAPPY on the saved file output to XML
                #   2. Parse the XML and add the relevant values to an SQL database.

                #subprocess.call(['/usr/bin/tappy.py', 'analysis', '--def_filename=' + formatFile, '--outputxml=' + tableName + '.xml', '--quiet', '/tmp/data_' + tableName + '.txt'])

                # Remove the temporary file we created upon which to run TAPPy
                try:
                    os.remove('/tmp/data_' + tableName + '.txt')
                except:
                    print 'Unable to remove /tmp/data_{}.txt. File may be locked or you don\'t have permissions.'.format(tableName)

                if noisy:
                    print 'done.'


            # Now I need to read in the xml file and add the results to an SQL
            # database.
            if noisy:
                print 'Adding station ' + tableName + ' harmonics to database:',

            try:
                f = open(tableName + '.xml', 'r')
            except IOError:
                sys.exit('Unable to open constituent XML file. Aborting')

            tree = etree.parse(f)

            constituentName = []
            constituentSpeed = []
            constituentInference = []
            constituentPhase = []
            constituentAmplitude = []

            for harmonic in tree.iter('Harmonic'):

                # This is not pretty.
                for item in harmonic.iter('name'):
                    constituentName.append(item.text)

                for item in harmonic.iter('speed'):
                    constituentSpeed.append(item.text)

                for item in harmonic.iter('inferred'):
                    constituentInference.append(item.text)

                for item in harmonic.iter('phaseAngle'):
                    constituentPhase.append(item.text)

                for item in harmonic.iter('amplitude'):
                    constituentAmplitude.append(item.text)

            # Now add all those values to the database
            addHarmonicResults('harmonics.db',\
                    tableName,\
                    constituentName,\
                    constituentPhase,\
                    constituentAmplitude,\
                    constituentSpeed,\
                    constituentInference,\
                    noisy=noisy)

            if noisy:
                print 'done.'


