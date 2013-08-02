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

from read_FVCOM_results import readFVCOM
from tide_tools import gregorianDate


if __name__ == '__main__':

    drawFig = True

    base = '/users/modellers/pica/Data/BODC/ctd'

    # The Port Erin netCDF files
    ncs = ['b1002772.qxf', 'b0979001.qxf', 'b1002796.qxf', 'b0979025.qxf', \
            'b0978998.qxf', 'b0978962.qxf', 'b0978986.qxf', 'b0978974.qxf', \
            'b1002803.qxf', 'b1002815.qxf', 'b1002784.qxf', 'b0979013.qxf']

    ncout = os.path.join(base, 'port_erin_ctd.nc')

    # Variable list metadata dict. Run get_port_erin_identifiers.sh to get the list
    defs = {}
    defs['AADYAA01'] = 'Time since 00:00 01/01/1760'
    defs['ACYCAA01'] = 'Sequence number'
    defs['ADEPZZ01'] = 'Depth below surface of the water body'
    defs['AMONAAZX'] = 'Concentration of ammonium {NH4} per unit volume of the water body [unknown phas>'
    defs['CDTAZZ01'] = 'Temperature of the atmosphere by thermometer'
    defs['CPHLFLP3'] = 'Concentration of chlorophyll-a {chl-a} per unit volume of the water body [parti>'
    defs['DOXYWITX'] = 'Concentration of oxygen {O2} per unit volume of the water body [dissolved phase>'
    defs['DOXYZZXX'] = 'Concentration of oxygen {O2} per unit volume of the water body [dissolved phase]'
    defs['NTOTWCTX'] = 'Concentration of nitrogen (total) per unit volume of the water body [dissolved >'
    defs['NTOTZZXX'] = 'Concentration of nitrogen (total) per unit volume of the water body [dissolved >'
    defs['NTRAZZXX'] = 'Concentration of nitrate {NO3} per unit volume of the water body [unknown phase]'
    defs['NTRIAAZX'] = 'Concentration of nitrite {NO2} per unit volume of the water body [unknown phase>'
    defs['NTRZAAZX'] = 'Concentration of nitrate+nitrite {NO3+NO2} per unit volume of the water body [u>'
    defs['OXYSZZ01'] = 'Saturation of oxygen {O2} in the water body [dissolved phase]'
    defs['PHOSMAZX'] = 'Concentration of phosphate {PO4} per unit volume of the water body [unknown pha>'
    defs['PHOSZZXX'] = 'Concentration of phosphate {PO4} per unit volume of the water body [unknown pha>'
    defs['PSALBSTX'] = 'Practical salinity of the water body by bench salinometer and computation using>'
    defs['SLCAAAZX'] = 'Concentration of silicate {SiO4} per unit volume of the water body [unknown pha>'
    defs['SSALAGT1'] = 'Salinity of the water body by titration against silver nitrate (AgNO3)'
    defs['SSALBSTX'] = 'Salinity of the water body by bench salinometer'
    defs['TEMPPR01'] = 'Temperature of the water body'
    defs['TPHSPP01'] = 'Concentration of phosphorus (total) per unit volume of the water body [dissolve>'

    lon, lat = [-4.83333], [54.09167]

    data = {}

    zlev = []
    indices = [0]
    duration = 0

    for file in ncs:
        nc, ga = readFVCOM(os.path.join(base, 'raw_data', file), globalAtts=True)
        k, _ = os.path.splitext(file)

        nc['indices'] = int(ga['dims']['primary'].split(':')[-1])
        duration += nc['indices']
        indices.append(indices[-1] + nc['indices'])
        zlev.append(int(ga['dims']['secondary'].split(':')[-1]))

        data[k] = nc

    zlev = np.unique(zlev)
    if len(zlev) > 1:
        raise Exception('Non-uniform depth levels, so I can\'t concetenate these netCDFs.')

    # Now find all the unique keys for each file so we can find out how many
    # different variables we have.
    vars = []
    for k in data.keys():
        for i in data[k].keys():
            if i not in vars:
                vars.append(i)

    # Make output array of size (times, zlevels, nvar)
    out = np.empty((duration, zlev, len(vars))) * np.nan

    for c, file in enumerate(ncs):
        k, _ = os.path.splitext(file)
        print 'Working on station {}'.format(k)

        for i in data[k].keys():
            # Find the index number we're using for this key
            idx = vars.index(i)

            try:
                if data[k][i].dtype == '|S1':
                    # String data is just a bunch of Ns or spaces. Not sure
                    # what it's for, but if I had to guess, I'd say it's a flag
                    # for missing data.
                    print 'Skipped variable {} in row {}'.format(i, idx)
                    continue
                else:
                    if np.ndim(data[k][i]) == 1:
                        # Time? Depth?
                        try:
                            out[indices[c]:indices[c + 1], 0, idx] = data[k][i]
                            print 'Added 1D variable {} in row {}'.format(i, idx)
                        except:
                            print 'Skipped variable {} in row {}'.format(i, idx)
                    else:
                        print 'Added 2D variable {} in row {}'.format(i, idx)
                        out[indices[c]:indices[c + 1], :, idx] = data[k][i]
            except Exception as e:
                if e.message.startswith('operands'):
                    raise e
                else:
                    print e

        print '\n'

    # Now sort the data by time ('AADYAA01')
    s = np.argsort(out[:, 0, vars.index('AADYAA01')])
    out = out[s, :, :]

    # Convert the time to Modified Julian Days. The offset between the BODC
    # time and MJD time origins is -36114 days (i.e. BODC starts before MJD).
    mjd = out[:, 0, vars.index('AADYAA01')] - 36114.0
    times = gregorianDate(mjd, mjd=True)

    # Make a Times array for the netCDF file.
    Times = ['{:04d}-{:02d}-{:02d}T{:02d}:{:02d}:{:09.6f}'.format(int(i[0]), int(i[1]), int(i[2]), int(i[3]), int(i[4]), i[5]) for i in times]

    # Export to NetCDF

    nt, nz, nv = out.shape

    nc = {}

    nc['dimensions'] = {'time':None,
            'level':nz,
            'DateStrLen':26,
            'one':1
            }
    # Add the global attributes
    nc['global attributes'] = {
            'description':'Time series of the ADCP data from the WaveHub site vertical distribution of pH, TCO2 and PCO2 from the Tamar FVCOM CO2 release model',
            'source':'Ian Ashton (i.g.c.ashton@exeter.ac.uk)',
            'history': 'Created by Pierre Cazenave on {}'.format(time.ctime(time.time()))
            }
    # Build the variables
    nc['variables'] = {
            'lon':{'data':[lon],
                'dimensions':['one'],
                'attributes':{'units':'degrees',
                        'long_name':'ADCP position (longitude)'}},
            'lat':{'data':[lat],
                'dimensions':['one'],
                'attributes':{'units':'degrees',
                        'long_name':'ADCP position (latitude)'}},
            'Times':{'data':Times,
                'dimensions':['time', 'DateStrLen'],
                'attributes':{'time_zone':'UTC'},
                'data_type':'c'},
            'mjd':{'data':mjd,
                'dimensions':['time'],
                'attributes':{'units':'days since 1858-11-17 00:00:00',
                    'format':'modified julian day (MJD)',
                    'time_zone':'UTC',
                    'long_name':'time'}}
            }

    # Append the other variables
    for c, v in enumerate(vars):
        if v is not 'indices':
            if defs.has_key(v):
                desc = defs[v]
            else:
                desc = 'No data available from BODC on this variable'

            # I know I shouldn't be using eval, but I see no way of
            # creating a dict from a list of variable names without
            # doing something unpythonic. So unpythonic it is.
            eval("nc['variables'].update({'" + v + "':{'data':out[:, :, c], \
                    'dimensions':['time', 'level'], \
                    'attributes':{'long_name':'" + desc + "'}}})")


    ncwrite.ncdfWrite(nc, ncout, Quiet=False)

    if drawFig:
        import matplotlib.pyplot as plt

        plt.figure()
        plt.subplot(2, 1, 1)
        plt.pcolormesh(out[:, 0, vars.index('AADYAA01')], -data[k]['ADEPZZ01'], out[:, :, vars.index('TEMPPR01')].transpose())
        plt.colorbar()
        plt.clim(7, 15)
        _ = plt.axis('tight')

        plt.subplot(2, 1, 2)
        plt.pcolormesh(out[:, 0, vars.index('AADYAA01')], -data[k]['ADEPZZ01'], out[:, :, vars.index('SSALBSTX')].transpose())
        plt.colorbar()
        plt.clim(33, 35)
        _ = plt.axis('tight')

        plt.show()
