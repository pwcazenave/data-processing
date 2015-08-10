"""
Get the relevant forcing data from the ECMWF servers.

This is split into analysis:
    - 2m temperature
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
import pygrib
import datetime

import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np

from ecmwfapi import ECMWFDataServer

from PyFVCOM.ocean_tools import calculate_rhum
from PyFVCOM.read_FVCOM_results import ncwrite


def get(year, outdir='.'):
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

    files = (os.path.join(outdir, '{}_analysis.grb'.format(year)),
             os.path.join(outdir, '{}_forecast.grb'.format(year)))

    server.retrieve({
        "class": "e2",
        "dataset": "era20c",
        "date": "{}-12-31/to/{}-01-01".format(year - 1, year + 1),
        "expver": "1",
        "levtype": "sfc",
        "param": "151.128/165.128/166.128/167.128/168.128",
        "stream": "oper",
        "target": "{}_analysis.grb".format(year),
        "time": "00/03/06/09/12/15/18/21",
        "type": "an",
    })

    server.retrieve({
        "class": "e2",
        "dataset": "era20c",
        "date": "{}-12-31/to/{}-01-01".format(year - 1, year + 1),
        "expver": "1",
        "levtype": "sfc",
        "param": "169.128/175.128/176.128/177.128/182.128/228.128",
        "step": "3/6/9/12/15/18/21/24",
        "stream": "oper",
        "target": "2003_forecast.grb",
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

    for params in zip(fname, fix):

        fname, cumul2inst = params

        if noisy:
            print('Loading GRIB file {}...'.format(gfile), end=' ')
        sys.stdout.flush()
        grb = pygrib.open(gfile)
        if noisy:
            print('done.')

        # Get a list of the unique variable nanes. This is inefficient because we
        # iterate through all variables and all times. I haven't found a nice way
        # to get these names with pygrib, which seems like a bit of a limitation to
        # me.

        if noisy:
            print('Extracting variable names...', end=' ')
        sys.stdout.flush()
        names, longnames, shortnames = [], [], []
        for g in grb:
            if g['name'] not in names:
                names.append(g['name'])
                longnames.append(g['cfName'])
                shortnames.append(g['cfVarName'])

        grb.rewind()

        # Now we know what we've got for this file, we can load the data.
        data = {}
        for name in names:

            if noisy:
                print('Working on {}...'.format(name), end=' ')

            current = grb.select(name=name)

            # We have 24 hour long 3-hourly cumulative forecast data which need to
            # be converted to instantaneous values. We must also convert from J/m^2
            # to W/m^2 (by dividing by the time interval in seconds).
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
            data[name]['data'] = np.empty((ny, nx, nt - ns))
            data[name]['lon'] = lon
            data[name]['lat'] = lat
            data[name]['units'] = current[0]['units']

            # Allocate the temporal variables. Remove three ns's because the range
            # used for tt (below) start from ns * 2 and ends at nt - ns.
            data[name]['Times'] = np.zeros(nt - (ns * 3)).astype(datetime.datetime)
            data[name]['time'] = np.zeros(nt - (ns * 3))
            data[name]['step'] = np.zeros(nt - (ns * 3))

            # We skip the first day because it doesn't start at the right time (the
            # download seems to miss the first of the eight samples in a single
            # forecast). We've accounted for this in get() by offsetting the
            # download by a day for each year. Getting this offset wrong will
            # seriously break the conversion from cumulative to instantaneous, so
            # be mindful of the data you're working with!
            for tt in range(ns * 2, nt - ns, ns):
                day = np.ma.empty((ny, nx, ns))
                time, Times = [], []  # Julian Day and Y/M/D h:m:s
                step = []  # forecast step
                for ti in range(ns):
                    si = ti + ns  # source array index
                    hoursminutes = '{:04d}'.format(current[si]['dataTime'])
                    currenttime = (current[si]['year'],
                                   current[si]['month'],
                                   current[si]['day'],
                                   int(hoursminutes[:2]),
                                   int(hoursminutes[2:]),
                                   current[si]['second'])
                    if cumul2inst:
                        Times.append(datetime.datetime(*currenttime) +
                                     datetime.timedelta(24.0 / current[si]['startStep']))
                    else:
                        Times.append(datetime.datetime(*currenttime))

                    day[..., ti] = np.ma.masked_where(current[si]['values'] == current[si]['missingValue'],
                                                      current[si]['values'])

                # Check we're working with the right offset (the first step
                # should be the same as the sampling interval). This is only
                # necessary on the forecast data (signified by cumul2inst).
                if cumul2inst and sampling != current[0]['startStep']:
                    msg = 'The first step in the data is {}, not {}. Have you downloaded from a non-midnight start point? Have you specified the correct `sampling\' value?'.format(
                        Times[0].hour, sampling)
                    raise ValueError(msg)

                if cumul2inst:
                    day_diff = np.dstack((day[..., 0], np.diff(day, axis=2)))

                if data[name]['units'] == 'J m**-2':
                    # J/m^2 to W/m^2
                    day_diff = day_diff / (3600 * sampling)

                # Store all the temporal data in the output dict.
                st = tt - (ns * 2)  # offset to account for the first day of data
                data[name]['data'][..., st:st + ns] = day_diff
                data[name]['Times'][st:st + ns] = Times
                data[name]['time'][st:st + ns] = np.asarray(time)
                data[name]['step'][st:st + ns] = np.asarray(step)

            if noisy:
                print('done.')

        grb.close()

    return data

def update_plot(i):
    pc = ax.pcolormesh(lon, lat, plotdata[..., i])
    pc.set_clim(0, cmax)
    return pc,

def init_plot():
    pc = ax.pcolormesh(lon, lat, plotdata[..., 0])
    plt.colorbar(pc)
    pc.set_clim(0, cmax)
    return pc,

if __name__ == '__main__':

    noisy = True

    start = 2000
    end = 2010

    server = ECMWFDataServer()

    for year in range(start, end):

        # Download the GRIB files.
        files = get(year)

        # Fix the forecast data variables to instantaneous and write out to
        # netCDF.
        data = fix(files[-1], noisy=noisy)  # the last file is the forecast one.

        # Animate some data.
        fig = plt.figure()
        ax = fig.add_subplot(111)
        cmax = 500
        plotdata = data['Surface net thermal radiation']['data']
        lon = data['Surface net thermal radiation']['lon']
        lat = data['Surface net thermal radiation']['lat']
        ani = animation.FuncAnimation(fig,
                                      update_plot,
                                      np.arange(8),
                                      init_func=init_plot,
                                      interval=25,
                                      blit=True)
