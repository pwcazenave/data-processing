"""
Take the COBS ASCII files for the HF Radar currents and create a NetCDF of the
data (similar to the PRIMaRE data).

The time series have 266 seconds added to them to account for the sampling
duration (532 seconds).

raw_data/currents###.txt format:

    time since 1/1/1970 in seconds
    wind direction (clockwise from N)
    current direction (clockwise from N)
    current speed (m/s)

cellinfo.txt format:

    cell number or ID (1-320)
    latitude of cell (degs)
    longitude of cell (degs)
    bearing away from master site (degs from N clockwise)
    bearing away from slave site (degs from N clockwise)
    range or distance from the master site (km)
    range or distance from the slave site (km)
    depth or bathymetry at the cell site (m)

WARNING: This code is very, very slow (think several hours). That's mainly the
loop which tries to find the indices for each time series in the overall time
series. I couldn't (quickly) think of an efficient way to do that, so
I bruteforced it. If you're running this on a larger grid, it might be better
to try and find a more efficient way of doing it.

"""

import glob
import time

import numpy as np
import ncdfWrite as ncwrite

from datetime import datetime
from tide_tools import julianDay

files = glob.glob('raw_data/currents???.txt')
ncout = 'cobs_hf_radar.nc'

fcells = open('cellinfo.txt', 'r')
cellinfo = fcells.readlines()

sid, slon, slat, sdepth = [], [], [], []
data = {}
for site in cellinfo:
    cid, clon, clat, bear_master, bear_slave, range_master, range_slave, depth = site.strip().split('\t')
    sid.append(cid)
    slon.append(clon)
    slat.append(clat)
    sdepth.append(depth)

sid, slon, slat, sdepth = np.asarray(sid, dtype=float), np.asarray(slon, dtype=float), np.asarray(slat, dtype=float), np.asarray(sdepth, dtype=float)

fcells.close()

# To find the actual value for each grid point, we need to create a set of
# regularly gridded values. Those values won't be quite right (the latitudes
# will be off because we're assuming constant grid intervals which don't happen
# in spherical coordinates) but should allow us to find the nearest point in
# the list and use that.
nx, ny, nt = 16, 20, 166535

lon = np.empty((nx, ny)) * np.nan
lat = np.empty((nx, ny)) * np.nan
depth = np.empty((nx, ny)) * np.nan
speed = np.empty((nx, ny, nt)) * np.nan
direction = np.empty((nx, ny, nt)) * np.nan
winddir = np.empty((nx, ny, 1nt)) * np.nan

times = np.arange(1122854400, 1322696400, 1200) # 20 minute sampling minimum increment
# Adjust times to account for the sampling period
times_fixed = times + 266
# Convert to Modified Julian Day. Look away now if you want to avoid horrible
# code...
greg_fixed = np.asarray([datetime.fromtimestamp(i) for i in times_fixed])
year = np.asarray([int(str(i).split('-')[0]) for i in greg_fixed])
month = np.asarray([int(str(i).split('-')[1]) for i in greg_fixed])
day = np.asarray([int(str(i).split('-')[-1].split(' ')[0]) for i in greg_fixed])
hour = np.asarray([int(str(i).split(' ')[-1].split(':')[0]) for i in greg_fixed])
minute = np.asarray([int(str(i).split(':')[1]) for i in greg_fixed])
second = np.asarray([int(str(i).split(':')[2]) for i in greg_fixed])

mjd_fixed = julianDay(np.column_stack((year, month, day, hour, minute, second)), mjd=True)

alon = np.linspace(-4.035, -3.116026, nx)
alat = np.linspace(53.315578, 54, ny)

for xi, x in enumerate(alon):
    for yi, y in enumerate(alat):
        dist = np.sqrt((slon - x)**2 + (slat - y)**2)
        lon[xi, yi] = slon[dist.argmin()]
        lat[xi, yi] = slat[dist.argmin()]
        depth[xi, yi] = sdepth[dist.argmin()]

        cell = sid[dist.argmin()].astype(int)

        # Read in the current cell's data.
        try:
            print('File currents{:03d}.txt'.format(cell)),

            data = np.genfromtxt('raw_data/currents{:03d}.txt'.format(cell))

            # Find the time indices from times for the current cell. This is
            # slow, but I can' think of a better way of doing it.
            tidx = []
            for t in data[:, 0]:
                tidx.append(np.abs(times - t).argmin())

            # Add the current data to the relevant spatial arrays
            winddir[xi, yi, tidx] = data[:, 1]
            direction[xi, yi, tidx] = data[:, 2]
            speed[xi, yi, tidx] = data[:, 3]

            print('done.')

        except:
            # File missing?
            print('missing?'.format(cell))

            continue

# Now we have the data in a sensible format, we can dump to NetCDF.

nc = {}

# Define the dimensions
nc['dimensions'] = {'time':nt,
        'lon':nx,
        'lat':ny,
        }
# Add the global attributes
nc['global attributes'] = {
        'description':'NOC High Frequency (HF) Radar Time series',
        'source':'netCDF3 python',
        'history': 'Created from the ASCII data on the Coastal Observatory website (http://cobs.noc.ac.uk/wera/) on {}'.format(time.ctime(time.time()))
        }

# Build the variables
nc['variables'] = {
        'time_original':{'data':times,
            'dimensions':['time'],
            'attributes':{'units':'seconds',
                'long_name':'Time since 1/1/1970 (epochal time) (s)',
                'time_zone':'UTC',
                'comments':'Times not fixed for sampling period'}},
        'time':{'data':mjd_fixed,
            'dimensions':['time'],
            'attributes':{'units':'days since 1858-11-17 00:00:00',
                'long_name':'Modified Julian Day (Time since 1858-11-17 00:00:00)',
                'time_zone':'UTC',
                'comments':'Times are fixed for sampling period by adding 266 seconds to each time stamp'}},
        'depth':{'data':depth,
            'dimensions':['lon', 'lat'],
            'attributes':{'units':'metres',
                'long_name':'water depth in metres (positive down)'}},
        'lon':{'data':lon,
            'dimensions':['lon', 'lat'],
            'attributes':{'units':'degrees',
                'long_name':'longitude grid'}},
        'lat':{'data':lat,
            'dimensions':['lon', 'lat'],
            'attributes':{'units':'degrees',
                'long_name':'latitude grid'}},
        'current_speed':{'data':speed,
            'dimensions':['lon', 'lat', 'time'],
            'attributes':{'units':'m/s',
                'long_name':'Current speed (m/s)'}},
        'current_direction':{'data':direction,
            'dimensions':['lon', 'lat', 'time'],
            'attributes':{'units':'degrees clockwise from north',
                'long_name':'Current direction (degs clockwise from N)'}},
        'wind_direction':{'data':winddir,
            'dimensions':['lon', 'lat', 'time'],
            'attributes':{'units':'degrees clockwise from north',
                'long_name':'Wind direction (degs clockwise from N)'}},
        }

# Write the output.
ncwrite.ncdfWrite(nc, ncout, Quiet=True)

