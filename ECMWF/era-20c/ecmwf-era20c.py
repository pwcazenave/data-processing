"""
Get the relevant forcing data from the ECMWF servers.

This is split into analysis:
    - 2m temperature
    - Dew point temperature
    - 10m u wind
    - 10m v wind
    - Surface pressure
and forecast:
    - Evaporation
    - Total precipitation
    - Surface net solar (long wave)
    - Surface net thermal (short wave)
    - Surface downward solar (long wave)
    - Surface downward thermal (short wave)

The relative humidity is calculated from the dew point temperature and ambient
temperature.

The forecast data are accumulated from 0600UTC with each forecast step (3 hour
interval). The 3rd time step is therefore the accumulated data from 0600
+ 9 hours, which is the value at 1500. To get the instantaneous, subtract the
accumulated from the given step from the previous step's data and then divide
the result by the interval (3 hours):

    inst = (data(n) - data(n - 1)) / interval

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
import matplotlib.animation as animation
import numpy as np

from ecmwfapi import ECMWFDataServer
from netCDF4 import date2num, num2date

from PyFVCOM.ocean_tools import calculate_rhum
from PyFVCOM.read_FVCOM_results import ncwrite


def get(year, month, outdir='.'):
    """
    Get the ECMWF ERA-20C FVCOM forcing data for a given year.

    The analysis data (instantaneous values):
        - 2m temperature (Celsius)
        - Dew point temperature (Celsius)
        - 10m u wind (m/s)
        - 10m v wind (m/s)
        - Mean Sea Level pressure (hPA)

    The forecast data (accumulated from 0600UTC + n hours for each step).
        - Evaporation
        - Total precipitation
        - Surface net solar
        - Surface net thermal
        - Surface downward solar
        - Surface downward thermal

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
        "param": "169.128/175.128/176.128/177.128/182.128/228.128",
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

            # We skip the first day because it doesn't start at the right
            # time (the download seems to miss the first of the eight samples
            # in a single forecast). We've accounted for this in get() by
            # offsetting the download by a day for each year. Getting this
            # offset wrong will seriously break the conversion from
            # cumulative to instantaneous, so be mindful of the data you're
            # working with! We don't use the last time because we read
            # forward for each day.
            for tt in range(loop_offsets, nt - loop_offsets, ns):
                if (tt + ns) <= nt:
                    day = np.ma.empty((ny, nx, ns))
                    Times = []  # Y/M/D h:m:s
                    for ti in range(ns):
                        si = tt + ti  # source array index
                        hoursminutes = '{:04d}'.format(current[si]['dataTime'])
                        currenttime = (current[si]['year'],
                                       current[si]['month'],
                                       current[si]['day'],
                                       int(hoursminutes[:2]),
                                       int(hoursminutes[2:]),
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

                # Check we're working with the right offset (the first step
                # should be the same as the sampling interval). This is only
                # necessary on the forecast data (signified by cumul2inst).
                if cumul2inst and sampling != current[0]['startStep']:
                    msg = 'The first step in the data is {}, not {}. Have you downloaded from a non-midnight start point? Have you specified the correct `sampling\' value?'.format(
                        Times[0].hour, sampling)
                    raise ValueError(msg)

                if cumul2inst:
                    if noisy and tt == loop_offsets:
                        print('cumulative data to instantaneous...', end=' ')
                    day = np.dstack((day[..., 0], np.diff(day, axis=2)))

                # Store all the temporal data in the output dict.
                st = tt - loop_offsets  # offset for the first day of data
                if 'data' in data[name]:
                    data[name]['data'] = np.dstack((data[name]['data'], day))
                else:
                    data[name]['data'] = day
                data[name]['Times'] = data[name]['Times'] + Times

            # Fix Times and make Modified Julian Days array.
            data[name]['Times'] = np.asarray(data[name]['Times'])
            data[name]['time'] = date2num(data[name]['Times'],
                                          'days since 1858-11-17 00:00:00')

            if data[name]['units'] == 'J m**-2':
                # J/m^2 to W/m^2
                if noisy:
                    print('Joules to Watts...', end=' ')
                data[name]['data'] /= (3600 * sampling)
                data[name]['units'] = 'W m**-2'

            if data[name]['units'] == 'K':
                data[name]['data'] -= 273.15
                data[name]['units'] = 'degrees_C'

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

    return data


def worker(input, output):
    """ Worker function to add our function of interest to the queue. """

    for func, args in iter(input.get, 'STOP'):
        indices, result = calculate(interp1d, args)
        output.put((indices, result))


def calculate(func, args):
    """ Wrapper around the function we want to run and its inputs. """

    indices, result = func(*args)

    return indices, result


def interp1d(interptimes, times, values, indices):
    """
    Wrapper around np.interp to return the index we've used as well as the
    interpolated data. We need the indices passed through the multiprocessing
    pipeline so we can reconstruct the output data in the right order.

    Parameters
    ----------
    interptimes: np.ndarray
        Times onto which to interpolate the timeseries (times, values).
    times: np.ndarray
        Times of the original data.
    values: np.ndarray
        Values of the original data.
    indices: np.ndarray
        Indices in the original data array.

    Returns
    -------
    indices: np.ndarray
        The indices in the original data.
    interpvalues: np.ndarray
        The interpolated time series.

    """

    interpvalues = np.interp(interptimes, times, values)

    return indices, interpvalues


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

    multiprocessing.freeze_support()
    task_queue = multiprocessing.Queue()
    done_queue = multiprocessing.Queue()
    NPROCS = multiprocessing.cpu_count() - 1 # leave a spare CPU

    data_interp = {}

    min_increment = np.Inf
    min_time = -np.Inf
    max_time = np.Inf

    for var in data:
        # Find the finest resolution time data.
        if 'time' in data[var]:
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

        # For those data which are already 3-hourly (i.e. most), just trim to
        # the right period. For the others, do the actual interpolation.
        trim = False
        if np.median(np.diff(data[var]['time'])) == min_increment:
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
                multiprocessing.Process(target=worker,
                                        args=(task_queue, done_queue)).start()
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
    Times = data[tmpvar]['Times']
    ny, nx, _ = data[data.keys()[0]]['data'].shape
    datestrlen = 26

    nc = {}
    nc['dimensions'] = {
        'lat': ny,
        'lon': nx,
        'time': None,
        'datestrlen': datestrlen
    }
    nc['global attributes'] = {
            'description': 'ECMWF ERA-20C data for FVCOM converted from GRIB to netCDF by ecmwf-era20c.py',
            'source': 'http://apps.ecmwf.int/datasets/data/era20c-daily/',
            'history': 'Created by Pierre Cazenave on {}'.format(time.ctime(time.time()))
            }
    nc['variables'] = {
        'latitude': {'data': [lat],
                     'dimensions': ['lon', 'lat'],
                     'attributes': {'units': 'Degrees North'}
                     },
        'longitude': {'data': [lon],
                      'dimensions': ['lon', 'lat'],
                      'attributes': {'units': 'Degrees North'}
                      },
        'time':{'data': mjdtime,
                'dimensions': ['time'],
                'attributes': {'format': 'Modified Julian Day (MJD)',
                               'longname': 'time',
                               'units': 'days since 1858-11-17 00:00:00',
                               'time_zone': 'UTC'}
                }
        # 'Times': {'data': Times,
        #           'dimensions': ['time'],
        #           'attributes': {'time_zone': 'UTC'}
        #           }
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

    start = 2000
    end = 2010

    # for year in range(start, end):
    for year in range(start, start + 1):

        # for month in range(1, 13):
        for month in range(1, 2):
            # Download the GRIB files.
            files = get(year, month)
            # files = ('2003-01_analysis.grb', '2003-01_forecast.grb')
            fix = [False, True]  # do we fix the cumulative?

            # Load the data and fix the forecast data variables to instantaneous.
            data = gread(files, fix, noisy=noisy)

            # Interpolate everything onto a common time reference.
            data_interp = interp(data, noisy)

            # Dump to netCDF.
            fout = 'ECMWF-ERA20C_FVCOM_{:04d}-{:02d}.nc'.format(year, month)
            dump(data_interp, fout, noisy=noisy)

            # Animate some of the data.
            if looksee:
                cmax = 500
                plotdata = data['Surface thermal radiation downwards']['data']
                lon = data['Surface thermal radiation downwards']['lon']
                lat = data['Surface thermal radiation downwards']['lat']

                def update_plot(i):
                    pc = ax.pcolormesh(lon, lat, plotdata[..., i])
                    pc.set_clim(0, cmax)
                    return pc,

                def init_plot():
                    pc = ax.pcolormesh(lon, lat, plotdata[..., 0])
                    plt.colorbar(pc)
                    pc.set_clim(0, cmax)
                    return pc,

                fig = plt.figure()
                ax = fig.add_subplot(111)
                ani = animation.FuncAnimation(fig,
                                              update_plot,
                                              np.arange(plotdata.shape[-1]),
                                              init_func=init_plot,
                                              interval=25,
                                              blit=True)
                plt.show()
