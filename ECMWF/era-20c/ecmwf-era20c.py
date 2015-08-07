!/usr/bin/env python

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

import os
import pygrib
import netCDF4

import matplotlib.animation as animation

from ecmwfapi import ECMWFDataServer



def get(year, outdir='./'):
    """
    Get the ECMWF ERA-20C FVCOM forcing data for a given year.

    The analysis data (instantaneous values):
        - 2m temperature (Celsius)
        - Dew point temperature (Celsius)
        - 10m u wind (m/s)
        - 10m v wind (m/s)
        - Surface pressure (hPA)

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
        "param": "134.128/165.128/166.128/167.128/168.128",
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

def fix(fname, sampling=3, noisy=False):
    """
    Fix the accumulated forecast variables back to instantaneous values for
    a given year's output.

    Parameters
    ----------
    year : int
        Model year to process.
    sampling : int, optional
        Sampling interval (in hours). Defaults to 3.
    noisy : bool, optional
        Set to True to enable verbose output. Defaults to False.

    Returns
    -------
    data : dict
        Dictionary of numpy arrays whose keys are the variable names from the
        GRIB file.

    """

    grb = pygrib.open(fname)

    # Get a list of the unique variable nanes. This is inefficient because we
    # iterate through all variables and all times. I haven't found a nice way
    # to get these names with pygrib, which seems like a bit of a limitation to
    # me.
    names, longnames, shortnames = [], [], []
    for g in grb:
        if g['name'] not in names:
            names.append(g['name'])
            longnames.append(g['cfName'])
            shortnames.append(g['cfVarName'])

    grb.rewind()

    # Now we've got the variable names, we can open them individually and dump
    # them in a dict for writing to netCDF. Store the metadata too.
    data = {}
    for name in names:

        if noisy:
            print('Working on {}'.format(name))

        current = grb.select(name=name)

        # We have 24 hour long 3-hourly cumulative forecast data which need to
        # be converted to instantaneous values. We must also convert from J/m^2
        # to W/m^2 (by dividing by the time interval in seconds).
        lat, lon = current[0].latlons()
        ns = 24 / sampling
        nt = len(current)
        ny, nx = np.shape(lat)
        # We skip the first day because it doesn't start at the right time (the
        # download seems to miss the first of the eight samples in a single
        # forecast). We've accounted for this in get() by offsetting the
        # download by a day for each year. Getting this offset wrong will
        # seriously break the conversion from cumulative to instantaneous, so
        # be mindful of the data you're working with!
        data[name] = {}
        data[name]['data'] = np.empty((ny, nx, nt - ns))
        data[name]['lon'] = lon
        data[name]['lat'] = lat
        data[name]['units'] = current[0]['units']
        data[name]['Times'] = np.empty((nt))
        data[name]['time'] = np.empty((nt))

        for tt in range(ns * 2, nt - ns, ns):
            day = np.ma.empty((ny, nx, ns))
            time, Times = [], []  # MJD and Y/M/D h:m:s
            for hh in range(ns):
                si = tt - hh - 1  # source array index
                ti = ns - hh - 1  # target array index

                currenttime = (current[si]['year'],
                               current[si]['month'],
                               current[si]['day'],
                               current[si]['hour'],
                               current[si]['minute'],
                               current[si]['second'])
                Times.append(currenttime)
                time.append(current[si]['julianDay'])
                day[..., ti] = np.ma.masked_where(current[si]['values'] == current[si]['missingValue'],
                                                  current[si]['values'])

            day_diff = np.dstack((day[..., 0], np.diff(day, axis=2)))
            if 'radiation' in name:
                # J/m^2 to W/m^2
                day_diff = day_diff / (3600 * ns)

            st = tt - (ns * 2)
            data[name]['data'][..., st:st + ns] = day_diff
            data[name]['Times'][st:st + ns] = Times

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
