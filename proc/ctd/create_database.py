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

from read_FVCOM_results import readFVCOM
from ocean_tools import pressure2depth

def findNamesBODC(data):
    """
    Little function to find the key names for the depth, temperature, salinity,
    sigma-t, pressure, fluorometer, irradiance, transmittance, oxygen
    saturation and attenuance keys in the supplied dict. If one is missing,
    None is returned for that data type.

    The function searches for any of the following:

    Depth: ADEPZZ01 DEPHPR01
    Temperature: POTMCV01 TEMPCC01 TEMPCU01 TEMPS901 TEMPST01 TEMPST02
    Salinity: PSALCC01 PSALCC02 PSALCU01 PSALST01
    Sigma-t: SIGTPR01 SIGTPR02
    Pressure: PRESPR01
    Instrument fluorometer voltage: FVLTAQ01 FVLTPELN FVLTWS01 FVLTZZ01
    Downwelling irradiance: DWIRPP01 IRRDPP01 IRRDUV01
    Transmittance: POPTDR01 POPTSR01
    Oxygen saturation: OXYSBB01 OXYSSC01 OXYSSU01
    Oxygen concentration: DOXYPR01 DOXYSC01 DOXYSU01
    Attenuance: ATTNDR01 ATTNMR01 ATTNSR01
    Conversion factor: TOKGPR01

    Parameters
    ----------

    data : ndarray
        Dict of data from the BODC CTD NetCDF files.

    Returns
    -------

    keys : dict
        Dict of the key names in the data dict. The keys in the output dict are
        named:
            - depth
            - temperature
            - salinity
            - sigma-t
            - pressure
            - fluorometer
            - irradiance
            - transmittance
            - o2saturation
            - o2concentration
            - attenuance
            - conversion

    """

    conv = ['TOKGPR01']
    salt = ['PSALCC01', 'PSALCC02', 'PSALCU01', 'PSALPR01', 'PSALST01']
    temp = ['TEMPCC01', 'TEMPCU01', 'TEMPS901', 'TEMPST01', 'TEMPST02']
    conc = ['CPHLPM01', 'CPHLPS01', 'DOXYPR01', 'DOXYSC01', 'DOXYSU01']
    satu = ['OXYSBB01', 'OXYSSC01', 'OXYSSU01', 'OXYSZZ01']
    fluo = ['FVLTAQ01', 'FVLTPELN', 'FVLTWS01', 'FVLTZZ01']
    zeta = ['ADEPZZ01', 'DEPHPR01']
    pres = ['PRESPR01']
    irra = ['IRRDUV01']
    atte = ['ATTNDR01', 'ATTNMR01', 'ATTNSR01', 'ATTNZS01', 'VSRDACTX']
    sigt = ['SIGTEQ01', 'SIGTPR01', 'SIGTPR02']
    tran = ['POPTDR01', 'POPTSR01']
    sequ = ['ACYCAA01']

    targets = ['sequence', 'depth', 'temperature', 'salinity', 'sigma-t',
            'pressure', 'fluorometer', 'irradiance', 'transmittance',
            'o2saturation', 'o2concentration', 'attenuance', 'conversion']
    keys = {}

    # Start with all values as None
    for key in targets:
        keys[key] = None

    # Find each data type separately so we know what's what when we insert it
    # into the SQLite database.
    for key in data.iterkeys():
        if key in zeta:
            keys['depth'] = key
        elif key in temp:
            keys['temperature'] = key
        elif key in salt:
            keys['salinity'] = key
        elif key in sigt:
            keys['sigma-t'] = key
        elif key in pres:
            keys['pressure'] = key
        elif key in fluo:
            keys['fluorometer'] = key
        elif key in irra:
            keys['irradiance'] = key
        elif key in tran:
            keys['transmittance'] = key
        elif key in satu:
            keys['o2saturation'] = key
        elif key in conc:
            keys['o2concentration'] = key
        elif key in atte:
            keys['attenuance'] = key
        elif key in conv:
            keys['conversion'] = key

    return keys


if __name__ == '__main__':

    noisy = True

    con = sqlite3.connect('./ctd.db')
    cur = con.cursor()

    base = '/users/modellers/pica/Data/BODC/ctd/'
    metaDataFiles = (os.path.join(base, 'all_stations.csv'))

    # Read the metadata into a dict
    f = open(metaDataFiles, 'rt')
    reader = csv.DictReader(f)

    # Create a new database and add the metadata to a field called Stations with
    # some of the metadata fields.
    try:
        with con:
            cur.execute('\
                    CREATE TABLE Stations(\
                    BODCReference INT, \
                    DataType TEXT COLLATE nocase, \
                    Instrument TEXT COLLATE nocase, \
                    Platform TEXT COLLATE nocase, \
                    Latitude FLOAT(10), \
                    Longitude FLOAT(10), \
                    PositionDef TEXT COLLATE nocase, \
                    StartDate TEXT COLLATE nocase, \
                    yearStart INT, \
                    monthStart INT, \
                    dayStart INT, \
                    EndDate TEXT COLLATE nocase, \
                    yearEnd INT, \
                    monthEnd INT, \
                    dayEnd INT, \
                    Duration FLOAT(10), \
                    SeaFloorDepth FLOAT(10), \
                    SeriesDepthMin FLOAT(10), \
                    SeriesDepthMax FLOAT(10), \
                    Project TEXT COLLATE nocase, \
                    Country TEXT COLLATE nocase, \
                    Organisation TEXT COLLATE nocase, \
                    QC TEXT COLLATE nocase, \
                    SeriesAvailability TEXT COLLATE nocase, \
                    Warnings TEXT COLLATE nocase, \
                    Licence TEXT COLLATE nocase, \
                    OriginalKeys TEXT COLLATE nocase);')

            # Now add the metadata.
            for row in reader:
                if noisy:
                    print('Adding station {}'.format(row['BODC reference']))

                try:
                    # Save the current site ID.
                    site = 'b{:07d}'.format(int(row['BODC reference']))

                    ncfile = os.path.join(base, 'raw_data', '{}.qxf'.format(site))
                    data = readFVCOM(ncfile)

                    # Since the BODC data has a bunch of different codes for
                    # the same thing then I have to search for one of a few
                    # different codes in each file. This is a bit of a pain.
                    # Save these keys to the Staions table in case I have
                    # messed up the groupings in findNamesBOCD.
                    keys = findNamesBODC(data)

                    # If we don't have a depth key, but we do have a pressure
                    # one, calculate the depth using the UNESCO Fofonoff and
                    # Millard (1983) equation.
                    if keys['depth'] is None and keys['pressure'] is not None:
                        keys['depth'] = 'my_depth'
                        data['my_depth'] = pressure2depth(data[keys['pressure']], float(row['Latitude A']))

                    # Save only those we've actually used.
                    nckeys = "'" + ' '.join([str(k) for k in keys.values() if k is not None]) + "'"

                    # Split the dates
                    try:
                        sYear, sMonth, sDay = re.split('-|/', row['Start date'])
                    except:
                        sYear, sMonth, sDay = -99, -99, -99 # use the nodata value

                    try:
                        eYear, eMonth, eDay = re.split('-|/', row['End date'])
                    except:
                        eYear, eMonth, eDay = -99, -99, -99 # use the nodata value

                    cur.execute('\
                            INSERT INTO Stations VALUES(\
                            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \
                            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', (\
                            int(row['BODC reference']), \
                            row['Oceanographic data type'], \
                            row['Instrument'], \
                            row['Platform'], \
                            float(row['Latitude A']), \
                            float(row['Longitude A']), \
                            row['Positional definition'], \
                            row['Start date'], \
                            int(sYear), \
                            int(sMonth), \
                            int(sDay), \
                            row['End date'], \
                            int(eYear), \
                            int(eMonth), \
                            int(eDay), \
                            float(row['Series duration (days)']), \
                            float(row['Sea floor depth (m)']), \
                            float(row['Series depth minimum (m)']), \
                            float(row['Series depth maximum (m)']), \
                            row['Project'], \
                            row['Country'], \
                            row['Organisation'], \
                            row['Quality control (QC)'], \
                            row['Series availability'], \
                            row['Warnings'], \
                            row['Licence'], \
                            nckeys))

                    # Create a table with all the possible data types we're likely
                    # to find from the BODC data. Some of these will be blank if we
                    # don't have any data for a given station.
                    query = 'CREATE TABLE {}(\
                            SequenceNumber INT, \
                            Depth FLOAT(10), \
                            OxygenConcentration FLOAT(10), \
                            FluorometerVoltage FLOAT(10), \
                            DownwellingIrradiance FLOAT(10), \
                            OxygenSaturation FLOAT(10), \
                            Transmittance FLOAT(10), \
                            Attenuance FLOAT(10), \
                            Pressure FLOAT(10), \
                            Salinity FLOAT(10), \
                            SigmaTheta FLOAT(10), \
                            Temperature FLOAT(10), \
                            ConversionFactor FLOAT(10))'.format(site)

                    cur.execute(query)

                    # Now extract the data and dump it into the data base.
                    values, s, addme = [], [], []

                    for k in keys:
                        if keys[k] is not None:
                            if k == 'depth':
                                s.append('Depth')
                                addme = data[keys[k]]
                            if k == 'o2concentration':
                                s.append('OxygenConcentration')
                                addme = data[keys[k]]
                            if k == 'fluorometer':
                                s.append('FluorometerVoltage')
                                addme = data[keys[k]]
                            if k == 'irradiance':
                                s.append('DownwellingIrradiance')
                                addme = data[keys[k]]
                            if k == 'o2saturation':
                                s.append('OxygenSaturation')
                                addme = data[keys[k]]
                            if k == 'transmittance':
                                s.append('Transmittance')
                                addme = data[keys[k]]
                            if k == 'pressure':
                                s.append('Pressure')
                                addme = data[keys[k]]
                            if k == 'salinity':
                                s.append('Salinity')
                                addme = data[keys[k]]
                            if k == 'sigma-t':
                                s.append('SigmaTheta')
                                addme = data[keys[k]]
                            if k == 'temperature':
                                s.append('Temperature')
                                addme = data[keys[k]]
                            if k == 'attenuance':
                                s.append('Attenuance')
                                addme = data[keys[k]]
                            if k == 'sequence':
                                s.append('SequenceNumber')
                                addme = data[keys[k]]
                            if k == 'conversion':
                                s.append('ConversionFactor')
                                addme = data[keys[k]]

                            if len(values) == 0:
                                values = addme
                            else:
                                values = np.column_stack((values, addme))

                    # If we haven't been given a sequence number, make one here.
                    if keys['sequence'] is None:
                        s.append('SequenceNumber')
                        values = np.column_stack((values, np.arange(values.shape[0]) + 1))

                    for c, v in enumerate(values):
                        # I can't get the 'safe' way to work, so we'll have to be 'unsafe'. Ho hum.
                        #cur.execute('INSERT INTO ? (?) VALUES (?)', (site, ','.join(s), ','.join([str(i) for i in v.tolist()])))
                        try:
                            cur.execute('INSERT INTO {} ({}) VALUES ({})'.format(site, ','.join(s), ','.join([str(i) for i in v.tolist()])))
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
