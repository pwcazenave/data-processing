"""
Read in the calculated climatologies for the river temperature data and
generate a single netCDF.

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

                print('Site {}'.format(ID)),

                # Some need to be in specific formats.
                dataCount = int(float(dataCount)) # not sure why this is the way it is...
                if siteX:
                    siteX = float(siteX)
                if siteY:
                    siteY = float(siteY)
                if siteZ:
                    siteZ = float(siteZ)

                # Save the relevant parts into their corresponding dicts.
                metadata['ID'].append(ID)
                metadata['siteID'].append(siteID)
                metadata['startDate'].append(startDate)
                metadata['endDate'].append(endDate)
                metadata['dataCount'].append(dataCount)
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
                if not siteX:
                    siteX = 0.0
                metadata['siteX'].append(siteX)
                if not siteY:
                    siteY = 0.0
                metadata['siteY'].append(siteY)
                if not siteZ:
                    siteZ = -9999
                metadata['siteZ'].append(siteZ)
                metadata['operatorCode'].append(operatorCode)
                metadata['siteType'].append(siteType)
                metadata['siteComment'].append(siteComment)
                # Add useful coordinates (lon/lat) to the metadata.
                lon, lat = OSGB36toWGS84(np.array([siteX]), np.array([siteY]))
                metadata['siteLon'].append(lon[0])
                metadata['siteLat'].append(lat[0])

                # Load the relevant climatology data. Use a numpy array to store
                # the data as we'll be dumping it out as a 2D array.
                data = np.genfromtxt(os.path.join('climatology', ID + '.csv'), delimiter=',')

                if c == 1:
                    Times = data[:, 0]
                    climatology = data[:, 1]
                else:
                    climatology = np.column_stack([climatology, data[:, 1]])

                print('done.')


    # Export to netCDF

    nt, ns = climatology.shape

    nc = {}

    nc['dimensions'] = {'days':nt,
            'time':None,
            'DateStrLen':20,
            'strlen':50,
            'one':1
            }

    # Add the global attributes
    nc['global attributes'] = {
            'description':"Climatology of river temperatures derived from the Environment Agency's surface water tempearture archive for fresh water and estuarine sites in England & Wales.",
            'source':'Source data from the Environment Agency. Climatology calculated by Pierre Cazenave at Plymouth Marine Laboratory',
            'history':'Created by Pierre Cazenave on {}'.format(time.ctime(time.time())),
            'notes':'Due to a limitation in the code used to write the netCDF file, the "time" dimension should be more accurately named "sites", indicating the number of stations in the database.'
            }

    # Build the variables
    nc['variables'] = {
            'lon':{'data':metadata['siteLon'],
                'dimensions':['time'],
                'attributes':{'units':'degrees',
                    'long_name':'River position (longitude)'}},
            'lat':{'data':metadata['siteLat'],
                'dimensions':['time'],
                'attributes':{'units':'degrees',
                    'long_name':'River position (latitude)'}},
            'x':{'data':metadata['siteX'],
                'dimensions':['time'],
                'attributes':{'units':'metres',
                    'long_name':'River position (eastings) British National Grid'}},
            'y':{'data':metadata['siteY'],
                'dimensions':['time'],
                'attributes':{'units':'metres',
                    'long_name':'River position (northings) British National Grid'}},
            'time':{'data':Times,
                'dimensions':['days'],
                'attributes':{'units':'days',
                    'format':'day of year',
                    'long_name':'time'}},
            'height':{'data':metadata['siteZ'],
                'dimensions':['time'],
                'attributes':{'units':'metres above mean sea level (positive up)',
                    'long_name':'height of recording station above mean sea level'}},
            'StartDate':{'data':['{:20s}'.format(i) for i in metadata['startDate']],
                'dimensions':['time', 'DateStrLen'],
                'attributes':{'format':'DD/MM/YYYY HH:MM:SS',
                    'time_zone':'UTC',
                    'long_name':'Time series start date'},
                'data_type':'c'},
            'EndDate':{'data':['{:20s}'.format(i) for i in metadata['endDate']],
                'dimensions':['time', 'DateStrLen'],
                'attributes':{'format':'DD/MM/YYYY HH:MM:SS',
                    'time_zone':'UTC',
                    'long_name':'Time series end date'},
                'data_type':'c'},
            'EA_REGION':{'data':['{:50s}'.format(i) for i in metadata['EA_REGION']],
                'dimensions':['time', 'strlen'],
                'attributes':{'long_name':'Environment Agency region name'},
                'data_type':'c'},
            'EA_AREA':{'data':['{:50s}'.format(i) for i in metadata['EA_AREA']],
                'dimensions':['time', 'strlen'],
                'attributes':{'long_name':'Environment Agency area name'},
                'data_type':'c'},
            'SiteName':{'data':['{:50s}'.format(i) for i in metadata['siteName']],
                'dimensions':['time', 'strlen'],
                'attributes':{'long_name':'Site name for the river temperature data'},
                'data_type':'c'},
            'SiteType':{'data':['{:50s}'.format(i) for i in metadata['siteType']],
                'dimensions':['time', 'strlen'],
                'attributes':{'long_name':'Site type for the temperature data'},
                'data_type':'c'},
            'Comments':{'data':['{:50s}'.format(i) for i in metadata['siteComment']],
                'dimensions':['time', 'strlen'],
                'attributes':{'long_name':'Notes/comments on the site'},
                'data_type':'c'},
            'OperatorCode':{'data':['{:50s}'.format(i) for i in metadata['operatorCode']],
                'dimensions':['time', 'strlen'],
                'attributes':{'long_name':'Operator code for the site'},
                'data_type':'c'},
            '10KM_SQ':{'data':['{:50s}'.format(i) for i in metadata['10KM_SQ']],
                'dimensions':['time', 'strlen'],
                'attributes':{'long_name':'Ordnance Survey grid square ID'},
                'data_type':'c'},
            'DataCount':{'data':metadata['dataCount'],
                'dimensions':['time'],
                'attributes':{'long_name':'Number of data points in this record'}},
            'climatology':{'data':climatology.transpose(),
                'dimensions':['time', 'days'],
                'attributes':{'units':'celsius',
                    'long_name':'calculated mean daily river temperature'}}
            }

    ncwrite.ncdfWrite(nc, ncout, Quiet=False)


