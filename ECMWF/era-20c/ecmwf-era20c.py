"""
Get relevant forcing data for FVCOM from the ECMWF servers.

Author: Pierre Cazenave, Plymouth Marine Laboratory, August 2015

This is split into analysis:
    - 2m temperature (Kelvin)
    - Dew point temperature (Kelvin)
    - 10m u wind (m/s)
    - 10m v wind (m/s)
    - Mean Sea Level pressure (Pa)
and forecast:
    - Evaporation (m)
    - Total precipitation (m)
    - Surface net solar radiation (short wave) (J/m**2)
    - Surface thermal radiation downward (long wave) (J/m**2)

The relative humidity is calculated from the dew point temperature and ambient
temperature.

The forecast data are accumulated from 0600UTC with each forecast step (3 hour
interval). The 3rd time step is therefore the accumulated data from 0600
+ 9 hours, which is the value at 1500. To get the instantaneous, subtract the
accumulated from the given step from the previous step's data:

    inst = (data(n) - data(n - 1))

Temperatures are converted to Celsius and heat fluxes to W/m**2.

Data sampled less frequently (the temperatures) are linearly interpolated
onto the finer time series of the other data. All data are clipped to the
common time period.

"""

from __future__ import print_function

import os
import sys
import time
import pygrib
import calendar
import datetime
import multiprocessing

import matplotlib.pyplot as plt
import numpy as np

from ecmwfapi import ECMWFDataServer
from netCDF4 import date2num, num2date

from PyFVCOM.ocean_tools import calculate_rhum
from PyFVCOM.read_FVCOM_results import ncwrite


def get(year, month, outdir='.'):
    """
    Get the ECMWF ERA-20C FVCOM forcing data for a given year.

    The analysis data (instantaneous values):
        - 2m temperature (Kelvin)
        - Dew point temperature (Kelvin)
        - 10m u wind (m/s)
        - 10m v wind (m/s)
        - Mean Sea Level pressure (Pa)
    The two temperature variables are only available every 6 hours.

    The forecast data (accumulated from 0600UTC + n hours for each step):
        - Evaporation
        - Total precipitation
        - Surface net solar radiation (J/m**2)
        - Surface thermal radiation downward (J/m**2)

    Parameters
    ----------
    year : int
        Year for which to download data.
    outdir : str, optional
        Output directory for the files. Defaults to the current directory.

    Returns
    -------
    files : tuple
        File paths for the analysis and forecast data (in that order).

    """

    server = ECMWFDataServer()

    # Buffer by four days from the current month.
    date = datetime.datetime(year, month, 01, 00, 00, 00)
    dom = calendar.monthrange(year, month)[-1]
    start_date = date - datetime.timedelta(days=4)
    end_date = date + datetime.timedelta(dom + 4)
    s_start = start_date.strftime('%Y-%m-%d')
    s_end = end_date.strftime('%Y-%m-%d')

    files = (os.path.join(outdir, '{:04d}-{:02d}_analysis.grb'.format(year, month)),
             os.path.join(outdir, '{:04d}-{:02d}_forecast.grb'.format(year, month)))

    server.retrieve({
        "class": "e2",
        "dataset": "era20c",
        "date": "{}/to/{}".format(s_start, s_end),
        "expver": "1",
        "levtype": "sfc",
        "param": "151.128/165.128/166.128/167.128/168.128",
        "stream": "oper",
        "target": files[0],
        "time": "00/03/06/09/12/15/18/21",
        "type": "an",
    })

    server.retrieve({
        "class": "e2",
        "dataset": "era20c",
        "date": "{}/to/{}".format(s_start, s_end),
        "expver": "1",
        "levtype": "sfc",
        "param": "175.128/176.128/182.128/228.128",
        "step": "3/6/9/12/15/18/21/24",
        "stream": "oper",
        "target": files[1],
        "time": "06",
        "type": "fc",
    })

    return files


def gread(fname, fix, noisy=False):
    """
    Read the GRIB data and optionally fix back to instantaneous values for a
    given year's output.

    Parameters
    ----------
    fname : int
        GRIB file name to process.
    fix : list
        List of True/False for whether to fix the cumulative values back to
        instantaneous (True = yes).
    noisy : bool, optional
        Set to True to enable verbose output. Defaults to False.

    Returns
    -------
    data : dict
        Dictionary of numpy arrays whose keys are the variable names from the
        GRIB file(s).

    """

    if len(fname) != len(fix):
        raise ValueError('The length of the `fix\' array does not match the number of files to process.')

    data = {}

    for params in zip(fname, fix):

        gfile, cumul2inst = params

        if noisy:
            print('Loading GRIB file {}...'.format(gfile), end=' ')
        sys.stdout.flush()
        grb = pygrib.open(gfile)
        if noisy:
            print('done.')

        # Get a list of the unique variable names. This is inefficient
        # because we iterate through all variables and all times. I haven't
        # found a nice way to get these names with pygrib, which seems like a
        # bit of a limitation to me.
        if noisy:
            print('Extracting variable names...', end=' ')
        sys.stdout.flush()
        names = []
        for g in grb:
            if g['name'] not in names:
                names.append(g['name'])

        if noisy:
            print('done.')
            for v in names:
                print('Found: {}'.format(v))

        grb.rewind()

        # Now we know what we've got for this file, we can load the data.
        for name in names:

            if noisy:
                print('Working on {}...'.format(name), end=' ')
            sys.stdout.flush()

            current = grb.select(name=name)
            lat, lon = current[0].latlons()

            # Get the sampling interval. We have to do this dynamically
            # because some of the data are every 6 hours (the temperature)
            # whilst the majority are every 3 hours.

            # Set the sampling based on the hours in the first two time steps
            # and only overwrite it if we have a specific sampling value.
            sampling = current[0]['startStep']
            if sampling == 0:
                sampling = np.abs(current[1]['hour'] - current[0]['hour'])

            if sampling == 0:
                raise ValueError('Sampling interval (hours) cannot be zero.')
            ns = 24 / sampling
            nt = len(current)
            ny, nx = np.shape(lat)

            if name in data:
                raise KeyError('The current variable ({}) is already in the loaded data.'.format(name))

            data[name] = {}
            data[name]['lon'] = lon
            data[name]['lat'] = lat
            data[name]['units'] = current[0]['units']
            # Not all the records have the CF names (I'm looking at you,
            # Mean sea level pressure), so make them up here if they're
            # missing.
            if 'cfVarName' in current[0].keys():
                shortName = current[0]['cfVarName']
            else:
                shortName = ''.join([i[0] for i in name.split(' ')]).lower()
                # Remove numbers from the short names.
                shortName = ''.join([i if i.isalpha() else '' for i in shortName])
                if shortName[0].isnumeric():
                    shortName = shortName[1:]
            if 'cfName' in current[0].keys():
                longName = current[0]['cfName']
            else:
                longName = name
            data[name]['shortName'] = shortName
            data[name]['longName'] = longName

            # For the analysis data, start at 6am to match the forecast data.
            loop_offsets = (6 / sampling)
            # If we're working with forecast data, just start at the beginning.
            if cumul2inst:
                loop_offsets = 0

            # Allocate the temporal variables. Remove three ns's because the
            # range used for tt (below) start from ns * 2 and ends at nt - ns.
            data[name]['Times'] = []

            for tt in range(loop_offsets, nt - loop_offsets, ns):
                if (tt + ns) <= nt:
                    day = np.ma.empty((ny, nx, ns))
                    Times = []  # Y/M/D h:m:s
                    for ti in range(ns):
                        si = tt + ti  # source array index
                        currenttime = (current[si]['year'],
                                       current[si]['month'],
                                       current[si]['day'],
                                       current[si]['hour'],
                                       current[si]['minute'],
                                       current[si]['second'])
                        if cumul2inst:
                            Times.append(datetime.datetime(*currenttime) +
                                         datetime.timedelta(current[si]['startStep'] / 24.0))
                        else:
                            Times.append(datetime.datetime(*currenttime))

                        day[..., ti] = np.ma.masked_where(current[si]['values'] == current[si]['missingValue'],
                                                          current[si]['values'])
                else:
                    if noisy:
                        extra_times = tt + ns - nt
                        if extra_times == 1:
                            msg = '{} trailing time dropped...'
                        else:
                            msg = '{} trailing times dropped...'
                        print(msg.format(extra_times),
                              end=' ')

                # Add a flag saying this variable is forecast.
                data[name]['forecast'] = False
                if cumul2inst:
                    data[name]['forecast'] = True
                    if noisy and tt == loop_offsets:
                        print('cumulative data to instantaneous...', end=' ')
                    day = np.dstack((day[..., 0], np.diff(day, axis=2)))

                # Store all the temporal data in the output dict.
                if 'data' in data[name]:
                    data[name]['data'] = np.dstack((data[name]['data'], day))
                else:
                    data[name]['data'] = day
                data[name]['Times'] = data[name]['Times'] + Times

            # Flip the data upside down because it gets stored upside down
            # otherwise, making subsetting it a pain. Also, it'd be wrong.
            data[name]['data'] = data[name]['data'][::-1, :, :]
            # Add half the sampling to the Times and make Modified Julian Days
            # array.
            data[name]['Times'] = [i + datetime.timedelta(sampling / 2.0 / 24.0) for i in data[name]['Times']]
            data[name]['Times'] = np.asarray(data[name]['Times'])
            data[name]['time'] = date2num(data[name]['Times'],
                                          'days since 1858-11-17 00:00:00')

            if data[name]['units'] == 'J m**-2':
                # J/m^2 to W/m^2
                if noisy:
                    print('Joules to Watts...', end=' ')
                data[name]['data'] /= 3600 * sampling
                data[name]['units'] = 'W m**-2'

            if data[name]['units'] == 'K':
                data[name]['data'] -= 273.15
                data[name]['units'] = 'degrees_C'

            if name.lower() in ['evaporation', 'total precipitation']:
                data[name]['data'] /= 3600 * sampling
                data[name]['units'] = 'm s**-1'

            if noisy:
                print('done.')

        grb.close()

    # Calculate relative humidity from the dew point temperature and
    # air temperature,
    if '2 metre dewpoint temperature' in data and '2 metre temperature' in data:
        data['Relative humidity'] = {}
        data['Relative humidity']['data'] = calculate_rhum(data['2 metre dewpoint temperature']['data'],
                                                           data['2 metre temperature']['data'])
        data['Relative humidity']['shortName'] = 'rhum'
        data['Relative humidity']['longName'] = 'Relative Humidity'
        data['Relative humidity']['units'] = '%'
        # Use one of the source data arrays for the spatial and temporal data.
        data['Relative humidity']['lon'] = data['2 metre dewpoint temperature']['lon']
        data['Relative humidity']['lat'] = data['2 metre dewpoint temperature']['lat']
        data['Relative humidity']['Times'] = data['2 metre dewpoint temperature']['Times']
        data['Relative humidity']['time'] = data['2 metre dewpoint temperature']['time']
        data['Relative humidity']['forecast'] = data['2 metre dewpoint temperature']['forecast']

    return data


def worker(input, output):
    """ Worker function to add our function of interest to the queue. """

    for func, args in iter(input.get, 'STOP'):
        indices = args[-1]
        result = func(*args[:-1])
        output.put((indices, result))

    return indices, result


def interp(data, noisy=False):
    """
    Interpolate the data onto a common time reference (the highest resolution
    of all the data).

    Parameters
    ----------
    data: dict
        Output of gread().
    noisy : bool, optional
        Set to True to enable verbose output. Defaults to False.

    Returns
    -------
    data_interp: dict
        New data interpolated onto a common time reference.

    """

    task_queue = multiprocessing.Queue()
    done_queue = multiprocessing.Queue()
    NPROCS = multiprocessing.cpu_count() - 1 # leave a spare CPU

    data_interp = {}

    min_increment = np.Inf
    min_time = -np.Inf
    max_time = np.Inf

    for var in data:
        # Find the finest resolution time data from the analysis variables.
        if 'time' in data[var] and not data[var]['forecast']:
            vtime = data[var]['time']
            inc = np.min(np.diff(data[var]['time']))
            if inc < 0:
                inc = np.median(np.diff(data[var]['time']))
            if inc < min_increment:
                min_increment = inc

            maxt = np.max(vtime)
            mint = np.min(vtime)
            if maxt < max_time:
                max_time = maxt
            if mint > min_time:
                min_time = mint

    common_time = np.arange(min_time, max_time + min_increment, min_increment)
    common_Times = num2date(common_time,
                            'days since 1858-11-17 00:00:00')

    # Interpolate each variable onto the common time reference and update the
    # time variables as necessary.
    for var in data:

        data_interp[var] = {}

        # For those analysis data which are already 3-hourly (i.e. not
        # temperature), just trim to the right period. For the others, do the
        # actual interpolation.
        trim = False
        var_increment = np.median(np.diff(data[var]['time']))
        if var_increment == min_increment and not data[var]['forecast']:
            if noisy:
                print('Trimming {} to common time...'.format(var),
                      end=' ')
                sys.stdout.flush()

            mint_diff = np.abs(data[var]['time'] - min_time)
            maxt_diff = np.abs(data[var]['time'] - max_time)
            if mint_diff.min() == 0 and maxt_diff.min() == 0:
                trim = True

        if trim:
            si = np.argmin(mint_diff)
            ei = np.argmin(maxt_diff)
            data_interp[var]['data'] = data[var]['data'][..., si:ei]
        else:
            if noisy:
                print('Interpolating {} to {} hourly...'.format(var, int(24.0 * min_increment)),
                      end=' ')
                sys.stdout.flush()

            ny, nx, nt = np.shape(data[var]['data'])
            TASKS = []
            for xx in range(nx):
                for yy in range(ny):
                    TASKS.append((interp1d,
                                  (common_time,
                                   data[var]['time'],
                                   data[var]['data'][yy, xx, :],
                                   (yy, xx))))
            for task in TASKS:
                task_queue.put(task)
            for _ in range(NPROCS):
                process = multiprocessing.Process(target=worker,
                                        args=(task_queue, done_queue))
                process.daemon = True
                process.start()

            # Wait for everything to finish.
            task_queue.join()

            # Extract the results into a single large array
            data_interp[var]['data'] = np.empty((ny, nx, len(common_time)))
            for _ in TASKS:
                pos, result = done_queue.get()
                data_interp[var]['data'][pos[0], pos[1], :] = result

        # New times
        data_interp[var]['time'] = common_time
        data_interp[var]['Times'] = common_Times
        # And the rest
        data_interp[var]['lon'] = data[var]['lon']
        data_interp[var]['lat'] = data[var]['lat']
        data_interp[var]['shortName'] = data[var]['shortName']
        data_interp[var]['longName'] = data[var]['longName']
        data_interp[var]['units'] = data[var]['units']

        if noisy:
            print('done.')

    task_queue.close()
    done_queue.close()

    return data_interp


def dump(data, fout, noisy=False):
    """
    Dump the data from the GRIB files into a netCDF file.

    Parameters
    ----------
    data : dict
        The data from the GRIB files. This is the output of `gread'.
    fout : str
        Output file name.
    noisy : bool, optional
        Set to True for verbose output (defaults to False).

    """

    tmpvar = data.keys()[0]
    lon, lat = data[tmpvar]['lon'], data[tmpvar]['lat']
    mjdtime = data[tmpvar]['time']
    Times = [i.strftime('%Y-%m-%dT%H:%M:%S') for i in data[tmpvar]['Times']]
    ny, nx, _ = data[data.keys()[0]]['data'].shape
    datestrlen = 19

    nc = {}
    nc['dimensions'] = {
        'lat': ny,
        'lon': nx,
        'time': None,
        'datestrlen': datestrlen
    }
    nc['global attributes'] = {
        'description': 'ECMWF ERA-20C data for FVCOM from ecmwf-era20c.py',
        'source': 'http://apps.ecmwf.int/datasets/data/era20c-daily/',
        'history': 'Created by Pierre Cazenave on {}'.format(
            time.ctime(time.time())
        )
    }
    nc['variables'] = {
        'lat': {'data': [lat],
                     'dimensions': ['lon', 'lat'],
                     'attributes': {'units': 'degrees_north',
                                    'standard_name': 'latitude',
                                    'long_name': 'Latitude',
                                    'axis': 'Y'}
                     },
        'lon': {'data': [lon],
                      'dimensions': ['lon', 'lat'],
                      'attributes': {'units': 'degrees_east',
                                     'standard_name': 'longitude',
                                     'long_name': 'Longitude',
                                     'axis': 'X'}
                      },
        'time': {'data': mjdtime,
                 'dimensions': ['time'],
                 'attributes': {'format': 'Modified Julian Day (MJD)',
                                'longname': 'time',
                                'units': 'days since 1858-11-17 00:00:00',
                                'time_zone': 'UTC'}
                 },
        'Times': {'data': Times,
                  'dimensions': ['time', 'datestrlen'],
                  'attributes': {'time_zone': 'UTC'},
                  'data_type': 'c'
                  }
    }

    # Add the rest of the variables and their data.
    for var in data.keys():
        # Use the shortname as the variable name (no spaces).
        sname = data[var]['shortName']
        new = {sname: {'data': data[var]['data'].transpose(2, 0, 1),
                       'dimensions': ['time', 'lat', 'lon'],
                       'attributes': {'shortname': data[var]['shortName'],
                                      'longname': data[var]['longName'],
                                      'units': data[var]['units']
                                      }
                       }}
        nc['variables'].update(new)

    ncwrite(nc, fout, Quiet=False)


if __name__ == '__main__':

    noisy = True
    looksee = False  # animate some data

    # Read in the month and year from the arguments to the script.
    year = int(sys.argv[1])
    month = int(sys.argv[2])

    # Download the GRIB files.
    # files = get(year, month, outdir='grib')
    files = ('grib/{:04d}-{:02d}_analysis.grb'.format(year, month),
             'grib/{:04d}-{:02d}_forecast.grb'.format(year, month))
    fix = [False, True]  # do we fix the cumulative?

    # Load the data and fix the forecast data variables to
    # instantaneous.
    data = gread(files, fix, noisy=noisy)

    # Interpolate everything onto a common time reference.
    data_interp = interp(data, noisy=noisy)

    # Dump to netCDF.
    fout = os.path.join('/dev/shm', 'nc',
                        'ECMWF-ERA20C_FVCOM_{:04d}-{:02d}.nc'.format(year, month))
    dump(data_interp, fout, noisy=noisy)
