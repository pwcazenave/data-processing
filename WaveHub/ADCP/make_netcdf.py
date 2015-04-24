"""
Script to convert the data from the three ADCP deployments from ASCII to
a NetCDF file for the WaveHub site.

Not sure if this is better in an SQLite database. The BODC current data may
eventually need to be made available in the same way as the tidal data, so this
might be necessary in the future...

"""

import os
import sys
import glob
import time

import numpy as np
import matplotlib.pyplot as plt

from PyFVCOM.tide_tools import julianDay
from PyFVCOM.read_FVCOM_results import readFVCOM, ncwrite

if __name__ == '__main__':

    noisy = True

    base = '/users/modellers/pica/Data/WaveHub/ADCP/raw_data/'
    out = os.path.join(base, 'wavehub_adcp_2010-2011.nc')

    lon, lat = -5.673366667, 50.306716667

    # Read the data from each directory and add each vertical level (we will be
    # limited to the same number for each deployment, so if more data come
    # along later with more/fewer bins, we'll have to have a new file).
    adcp = {}

    for d in os.listdir(base):

        if d.endswith('.nc'): continue

        bins = []
        idx = []
        used = []

        for f in glob.glob(os.path.join(base, d, '*.txt')):
            # Save the current file name in case glob doesn't preserve order
            # (it may well do, but this is safer).
            used.append(f)

            # Open the current file, extract its depth and then dump the data
            # into the array at the relevant depth. We'll use the file name to
            # find out which index to use (reversing because we'll match FVCOM
            # in terms of having the first index be the surface, the last the
            # seabed).
            ff = open(f, 'r')
            lines = ff.readlines()

            # Read through the lines and extact the depth and put it into an
            # array.
            for i, line in enumerate(lines):
                line = line.strip()
                if line.startswith('Bin '):
                    z = line.split(':')[1].split('m')[0].strip()
                    bins.append(float(z))
                    break

            ff.close()

            # Use the file name to get the array index.
            _, fname = os.path.split(f)
            fname, _ = os.path.splitext(fname)
            lvl = 10 - int(fname[3:])
            idx.append(lvl)

            # We'll use genfromtxt for the bulk of the data.
            data = np.genfromtxt(f, skip_header=6)

            if adcp.has_key('Level-' + str(lvl)):
                adcp['Level-' + str(lvl)] = np.vstack([adcp['Level-' + str(lvl)], data])
            else:
                adcp['Level-' + str(lvl)] = data

            # Add to a dict with the level and directory as the key
            #adcp[str(idx[-1]) + '_' + d] = data

        adcp[d + '-' + 'bins'] = bins
        adcp[d + '-' + 'files'] = used
        adcp[d + '-' + 'levels'] = idx

    # Now we have all the data, we can manipulate it as we see fit.
    ADCP = np.empty(tuple([i for i in adcp['Level-0'].shape] + [10]))
    for v in adcp:
        if v.startswith('Level-'):
            i = int(v.split('-')[1])
            ADCP[:, :, i] = adcp[v]

    mjd = julianDay(ADCP[:, 0:6, 0], mjd=True)

    # Make a Times array for the NetCDF file.
    times = ['{:04d}-{:02d}-{:02d}T{:02d}:{:02d}:{:09.6f}'.format(int(i[0]), int(i[1]), int(i[2]), int(i[3]), int(i[4]), i[5]) for i in ADCP[:, :6, 0]]


    # Export to NetCDF

    _, _, nz = ADCP.shape

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
            'depth':{'data':[np.sort(bins)],
                'dimensions':['level'],
                'attributes':{'units':'metres',
                        'long_name':'Bin depth below surface (positive down)'}},
            'Times':{'data':times,
                'dimensions':['time', 'DateStrLen'],
                'attributes':{'time_zone':'UTC'},
                'data_type':'c'},
            'mjd':{'data':mjd,
                'dimensions':['time'],
                'attributes':{'units':'days since 1858-11-17 00:00:00',
                    'format':'modified julian day (MJD)',
                    'time_zone':'UTC',
                    'long_name':'time'}},
            'u':{'data':ADCP[:, -6, :],
                'dimensions':['time', 'level'],
                'attributes':{'units':'meters s-1',
                    'long_name':'Eastward Water Velocity'}},
            'v':{'data':ADCP[:, -5, :],
                'dimensions':['time', 'level'],
                'attributes':{'units':'meters s-1',
                    'long_name':'Northward Water Velocity'}},
            'w':{'data':ADCP[:, -4, :],
                'dimensions':['time', 'level'],
                'attributes':{'units':'meters s-1',
                    'long_name':'Vertical Water Velocity'}},
            'error':{'data':ADCP[:, -4, :],
                'dimensions':['time', 'level'],
                'attributes':{'units':'meters s-1',
                    'long_name':'Velocity error magnitude'}},
            'speed':{'data':ADCP[:, -2, :],
                'dimensions':['time', 'level'],
                'attributes':{'units':'meters s-1',
                    'long_name':'Current speed'}},
            'direction':{'data':ADCP[:, -1, :],
                'dimensions':['time', 'level'],
                'attributes':{'units':'degrees North',
                    'long_name':'Current direction'}},
            }

    ncwrite(nc, out, Quiet=False)



    # Check everything looks sensible

    # Load in the NetCDF file and overlay on the input data.
    NC = readFVCOM(out, noisy=True)

    fig0 = plt.figure(figsize=(10, 7.5))
    n = 10
    for i in xrange(n):
        yyyy, mm, dd, HH, MM, SS = ADCP[i, 0:6, 0].astype(int)
        plt.clf()
        plt.subplot2grid((2, 2), (0, 0))
        plt.plot(ADCP[i, -2, :], -np.sort(bins), '.-')
        plt.plot(NC['speed'][i, :], -np.sort(bins), 'bx:')
        plt.xlim(ADCP[:n, -2, :].min(), ADCP[:n, -2, :].max())
        plt.xlabel('Speed (m/s)')
        plt.ylabel('Depth (m)')
        plt.title('{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(yyyy, mm, dd, HH, MM, SS))

        plt.subplot2grid((2, 2), (0, 1))
        plt.plot(ADCP[i, -1, :], -np.sort(bins), 'r.-')
        plt.plot(NC['direction'][i, :], -np.sort(bins), 'rx:')
        plt.xlim(ADCP[:n, -1, :].min(), ADCP[:n, -1, :].max())
        plt.xlabel('Direction ($^{\circ}N$)')
        plt.title('{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}'.format(yyyy, mm, dd, HH, MM, SS))

        plt.subplot2grid((2, 2), (1, 0), colspan=2)
        plt.plot(mjd[:n], ADCP[:n, -2, 0], '.-', label='Surface')
        plt.plot(mjd[:n], ADCP[:n, -2, -1], 'k.-', label='Seabed')
        plt.plot(mjd[i], ADCP[i, -2, 0], 'ro', ms=5, zorder=2)
        plt.plot(mjd[i], ADCP[i, -2, -1], 'ro', ms=5, zorder=2)
        plt.xlabel('Time (Modified Julian Days)')
        plt.ylabel('Speed (m/s)')
        plt.xlim(mjd[0], mjd[n])
        plt.legend(frameon=False)

        time.sleep(0.01)
        fig0.canvas.draw()

    fig0.show()
