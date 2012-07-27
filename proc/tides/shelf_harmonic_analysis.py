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

from read_observed_data import getObservedData

def addToDB(db, stationName, constituentName, phase, amplitude, speed, inferred, noisy=False):
    """
    Add data to an SQLite database.

    - db specifies an SQLite databse. If it doesn't exist, it will be created.
    - stationName is the short name (i.e. AVO not Avonmouth)
    - constituent Name is M2, S2 etc.
    - phase is in degrees
    - amplitude is in metres
    - speed is in degrees/hour
    - inferred is 'true' or 'false' (as strings, not python special values)

    Optionally specify noisy=True to turn on verbose output.

    For reference, to extract the M2 amplitude, phase and speed for Ilfracombe,
    the SQL statment would be:

    select
        Amplitude.value,
        Phase.value,
        Speed.value
    from
        Amplitude join Phase join Speed
    where
        Phase.constituentName is 'm2' and
        Speed.constituentName is 'm2' and
        Amplitude.constituentName is 'm2' and
        Phase.shortName is 'ILF' and
        Speed.shortName is 'ILF' and
        Amplitude.shortName is 'ILF';

    """

    try:
        import sqlite3
    except ImportError:
        sys.exit('Importing SQLite3 module failed')

    conn = sqlite3.connect(db)
    c = conn.cursor()


    # Create the necessary tables if they don't exist already
    c.execute('CREATE TABLE IF NOT EXISTS StationName (latDD FLOAT(10), lonDD FLOAT(10), shortName TEXT COLLATE nocase, longName TEXT COLLATE nocase)')
    c.execute('CREATE TABLE IF NOT EXISTS Amplitude (shortName TEXT COLLATE nocase, value FLOAT(10), constituentName TEXT COLLATE nocase, valueUnits TEXT COLLATE nocase, inferredConstituent TEXT COLLATE nocase)')
    c.execute('CREATE TABLE IF NOT EXISTS Phase (shortName TEXT COLLATE nocase, value FLOAT(10), constituentName TEXT COLLATE nocase, valueUnits TEXT COLLATE nocase, inferredConstituent TEXT COLLATE nocase)')
    c.execute('CREATE TABLE IF NOT EXISTS Speed (shortName TEXT COLLATE nocase, value FLOAT(10), constituentName TEXT COLLATE nocase, valueUnits TEXT COLLATE nocase, inferredConstituent TEXT COLLATE nocase)')

    for item in xrange(len(inferred)):
        c.execute('INSERT INTO Amplitude VALUES (?,?,?,?,?)',\
                  (stationName, amplitude[item], constituentName[item], 'metres', inferred[item]))
        c.execute('INSERT INTO Phase VALUES (?,?,?,?,?)',\
                  (stationName, phase[item], constituentName[item], 'degrees', inferred[item]))
        c.execute('INSERT INTO Speed VALUES (?,?,?,?,?)',\
                  (stationName, speed[item], constituentName[item], 'degrees per mean solar hour', inferred[item]))

    conn.commit()

    conn.close()



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
                print 'analysis already completed. Skipping.'
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

                #subprocess.call(['/usr/bin/tappy.py', 'analysis', '--def_filename=' + formatFile, '--outputxml=' + tableName + '.xml', '--quiet', '/tmp/data.txt'])

                if noisy:
                    print 'done.'


            # Now I need to read in the xml file and add the results to an SQL
            # database.
            if noisy:
                print 'Adding station ' + tableName + ' harmonics to database...',

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
            addToDB('harmonics.db',\
                    tableName,\
                    constituentName,\
                    constituentPhase,\
                    constituentAmplitude,\
                    constituentSpeed,\
                    constituentInference,\
                    noisy=noisy)

            if noisy:
                print 'done.'


