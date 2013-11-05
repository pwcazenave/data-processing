"""
Read in the Port Erin netCDFs and create a super netCDF of all the time
series.

The variable AADYAA01 is not present in the ASCII equivalents of the netCDF
files, but it represents time (days?) since 00:00 01/01/1760.

Unfortunately, the values in AADYAA01 are integer days, so there are no times
(everything is at midnight). Comparing this with the data in the ASCII
filesshows that from 1996 onwards, the data do have time values. I haven't
figured a sensible way of adding the times to the concatenated netCDF file
generated here.

"""

import os
import time

import numpy as np
import ncdfWrite as ncwrite

from grid_tools import OSGB36toWGS84

if __name__ == '__main__':

    # Where are the files to be read in?
    climmeta = 'metadata/climatology_metadata.csv'

    ncout = 'ea_river_climatology.nc'

    # Read in the metadata and load the relevant climatology CSV file.
    metadata = {}
    metadata['ID'] = []
    metadata['siteID'] = []
    metadata['startDate'] = []
    metadata['endDate'] = []
    metadata['dataCount'] = []
    metadata['detCode'] = []
    metadata['sourceCode'] = []
    metadata['WIMS_REGION'] = []
    metadata['WIMS_SPT_DESC'] = []
    metadata['EA_REGION'] = []
    metadata['EA_AREA'] = []
    metadata['EA_WM_REGION'] = []
    metadata['EA_WM_AREA'] = []
    metadata['EA_RBD'] = []
    metadata['EA_WB_ID_TRANS'] = []
    metadata['EA_WB_ID_RCATS'] = []
    metadata['EA_WB_ID_LAKES'] = []
    metadata['EA_WB_ID_COAST'] = []
    metadata['EA_WB_ID_GWATR'] = []
    metadata['10KM_SQ'] = []
    metadata['EA_BFI_ID'] = []
    metadata['siteID'] = []
    metadata['siteName'] = []
    metadata['siteX'] = []
    metadata['siteY'] = []
    metadata['siteZ'] = []
    metadata['siteLon'] = []
    metadata['siteLat'] = []
    metadata['operatorCode'] = []
    metadata['siteType'] = []
    metadata['siteComment'] = []

    with open(climmeta, 'r') as f:
        for c, line in enumerate(f):
            if c > 0: # skip the header
                # Wow, this is messy!
                ID, startDate, endDate, dataCount, detCode, sourceCode, \
                WIMS_REGION, WIMS_SPT_DESC, EA_REGION, EA_AREA, EA_WM_REGION, \
                EA_WM_AREA, EA_RBD, EA_WB_ID_TRANS, EA_WB_ID_RCATS, \
                EA_WB_ID_LAKES, EA_WB_ID_COAST, EA_WB_ID_GWATR, a10KM_SQ, \
                EA_BFI_ID, siteID, siteName, siteX, siteY, siteZ, operatorCode, \
                siteType, siteComment = line.strip().split(',')

                # Save the relevant parts into their corresponding dicts.
                metadata['ID'].append(ID)
                metadata['siteID'].append(siteID)
                metadata['startDate'].append(startDate)
                metadata['endDate'].append(endDate)
                metadata['dataCount'].append(int(float(dataCount)))
                metadata['detCode'].append(detCode)
                metadata['sourceCode'].append(sourceCode)
                metadata['WIMS_REGION'].append(WIMS_REGION)
                metadata['WIMS_SPT_DESC'].append(WIMS_SPT_DESC)
                metadata['EA_REGION'].append(EA_REGION)
                metadata['EA_AREA'].append(EA_AREA)
                metadata['EA_WM_REGION'].append(EA_WM_REGION)
                metadata['EA_WM_AREA'].append(EA_WM_AREA)
                metadata['EA_RBD'].append(EA_RBD)
                metadata['EA_WB_ID_TRANS'].append(EA_WB_ID_TRANS)
                metadata['EA_WB_ID_RCATS'].append(EA_WB_ID_RCATS)
                metadata['EA_WB_ID_LAKES'].append(EA_WB_ID_LAKES)
                metadata['EA_WB_ID_COAST'].append(EA_WB_ID_COAST)
                metadata['EA_WB_ID_GWATR'].append(EA_WB_ID_GWATR)
                metadata['10KM_SQ'].append(a10KM_SQ)
                metadata['EA_BFI_ID'].append(EA_BFI_ID)
                metadata['siteID'].append(siteID)
                metadata['siteName'].append(siteName)
                if siteX:
                    siteX = float(siteX)
                metadata['siteX'].append(siteX)
                if siteY:
                    siteY = float(siteY)
                metadata['siteY'].append(siteY)
                if siteZ:
                    siteZ = float(siteZ)
                metadata['siteZ'].append(siteZ)
                metadata['operatorCode'].append(operatorCode)
                metadata['siteType'].append(siteType)
                metadata['siteComment'].append(siteComment)
                # Add useful coordinates (lon/lat) to the metadata.
                lon, lat = OSGB36toWGS84(np.array([float(siteX)]), np.array([float(siteY)]))
                metadata['siteLon'].append(lon)
                metadata['siteLat'].append(lat)


                # Load the relevant climatology data. Use a numpy array to store
                # the data as we'll be dumping it out as a 2D array.
                data = np.genfromtxt(os.path.join('climatology', ID + '.csv'), delimiter=',')

                if c == 1:
                    climatology = data
                else:
                    climatology = np.column_stack([climatology, data])

    # Create a day of year array.
    Times = np.arange(1, 365)

    # Export to netCDF

    nt, ns = climatology.shape

    nc = {}

    nc['dimensions'] = {'time':nt,
            'sites':ns
            'strlen':20
            'one':1
            }

    # Add the global attributes
    nc['global attributes'] = {
            'description':"Climatology of river temperatures derived from the Environment Agency's surface water tempearture archive for fresh water and estuarine sites in England & Wales.",
            'source':'Source data from the Environment Agency. Climatology calculated by Pierre Cazenave at Plymouth Marine Laboratory',
            'history': 'Created by Pierre Cazenave on {}'.format(time.ctime(time.time()))
            }

    # Build the variables
    nc['variables'] = {
            'lon':{'data':[lon],
                'dimensions':['ns'],
                'attributes':{'units':'degrees',
                    'long_name':'River position (longitude)'}},
            'lat':{'data':[metadata['siteLon']],
                'dimensions':['ns'],
                'attributes':{'units':'degrees',
                    'long_name':'River position (latitude)'}},
            'x':{'data':[metadata['siteLon']],
                'dimensions':['ns'],
                'attributes':{'units':'metres',
                    'long_name':'River position (eastings) British National Grid'}},
            'y':{'data':[metadata['siteLat']],
                'dimensions':['ns'],
                'attributes':{'units':'metres',
                    'long_name':'River position (northings) British National Grid'}},
            'time':{'data':Times,
                'dimensions':['time'],
                'attributes':{'units':'days',
                    'format':'day of year',
                    'long_name':'time'}},
            'height':{'data':[metadata['siteZ']],
                'dimensions':['one'],
                'attributes':{'units':'metres above mean sea level (positive up)',
                    'long_name':'height of recording station above mean sea level'}},
            'climatology':{'data':[climatology]],
                'dimensions':['ns', 'time'],
                'attributes':{'units':'celsius',
                    'long_name':'calculated mean daily river temperature'}}
            }

    ncwrite.ncdfWrite(nc, ncout, Quiet=False)

    if drawFig:

        import matplotlib.pyplot as plt

        # Create an appropriately sized array of depth values. This is because
        # for pcolormesh, the y array has to be n + 1 values long. What I'm
        # doing here is using the first and last depth values and adding those
        # to the midpoint of the depths inbetween.
        z = -data[k]['ADEPZZ01']
        Z = np.hstack((z[0], (np.diff(z) / 2) + z[:-1], z[-1]))

        plt.figure()
        plt.subplot(2, 1, 1)
        plt.pcolormesh(
                out[:, 0, vars.index('AADYAA01')] +
                out[:, 0, vars.index('AAFDZZ01')],
                Z,
                out[:, :, vars.index('TEMPPR01')].transpose()
            )
        plt.colorbar()
        plt.clim(7, 15)
        _ = plt.axis('tight')

        plt.subplot(2, 1, 2)
        plt.pcolormesh(
                out[:, 0, vars.index('AADYAA01')] +
                out[:, 0, vars.index('AAFDZZ01')],
                Z,
                out[:, :, vars.index('SSALBSTX')].transpose()
                )
        plt.colorbar()
        plt.clim(33, 35)
        _ = plt.axis('tight')

        plt.show()

    # Check the resulting netCDF
    if checkOutput:

        import matplotlib.pyplot as plt

        ncin = readFVCOM(ncout, noisy=True)

        # Extract the salinity data (SSALBSTX and SSALAGT1) and combine the two
        # data sets.
        sal1 = ncin['SSALBSTX']
        sal2 = ncin['SSALAGT1']

        # OK, this is doing my head in. We'll save all positions of zero values
        # in the original array so we can put them back at the end of all this.
        # Then we'll replace all values below zero with zero. We can then sum
        # the two arrays and put back the NaNs using the index we just saved.
        # There has to be a prettier way of doing this, but I haven't found it
        # yet.
        sal1idx = (sal1 == 0)
        sal2idx = (sal2 == 0)
        sal1nan = np.isnan(sal1) | (sal1 < 0)
        sal2nan = np.isnan(sal2) | (sal2 < 0)
        sal1a = sal1
        sal2a = sal2
        sal1a[sal1nan] = 0
        sal2a[sal2nan] = 0
        salt = sal1a + sal2a
        salt[sal1nan * sal2nan] = np.nan

        # Create an appropriately sized array of depth values. This is because
        # for pcolormesh, the y array has to be n + 1 values long. What I'm
        # doing here is using the first and last depth values and adding those
        # to the midpoint of the depths inbetween.
        z = -ncin['depth']
        Z = np.hstack((z[0], (np.diff(z) / 2) + z[:-1], z[-1]))

        plt.figure()
        plt.subplot(2, 1, 1)
        plt.pcolormesh(
                ncin['AADYAA01'][:, 0] + ncin['AAFDZZ01'][:, 0],
                Z,
                ncin['TEMPPR01'].transpose()
                )
        plt.colorbar()
        plt.clim(7, 15)
        _ = plt.axis('tight')

        plt.subplot(2, 1, 2)
        plt.pcolormesh(
                ncin['AADYAA01'][:, 0] + ncin['AAFDZZ01'][:, 0],
                Z,
                salt.transpose()
                )
        plt.colorbar()
        plt.clim(33, 35)
        _ = plt.axis('tight')

        plt.show()


