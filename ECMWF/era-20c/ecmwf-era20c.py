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
    - Surface net solar
    - Surface net thermal
    - Surface downward solar
    - Surface downward thermal

The forecast data are accumulated from 0600UTC with each forecast step (3 hour
interval). The 3rd time step is therefore the accumulated data from 0600
+ 9 hours, which is the value at 1500. To get the instantaneous, subtract the
accumulated from the given step from the previous step's data and then divide
the result by the interval (3 hours):

    inst = (data(n) - data(n - 1)) / interval

"""

import pygrib
import netCDF4

import matplotlib.animation as animation

from ecmwfapi import ECMWFDataServer


def get(year):
    """ Get the ECMWF ERA-20C FVCOM forcing data for a given year. """

    # The analysis data (instantaneous values)
    #   - 2m temperature
    #   - 10m u wind
    #   - 10m v wind
    #   - Surface pressure
    server.retrieve({
        "class": "e2",
        "dataset": "era20c",
        "date": "{}-12-31/to/{}-01-01".format(year - 1, year + 1),
        "expver": "1",
        "levtype": "sfc",
        "param": "134.128/165.128/166.128/167.128",
        "stream": "oper",
        "target": "{}_analysis.grb".format(year),
        "time": "00/03/06/09/12/15/18/21",
        "type": "an",
    })

    # The forecast data (accumulated from 0600UTC + n hours for each step).
    #   - Evaporation
    #   - Total precipitation
    #   - Surface net solar
    #   - Surface net thermal
    #   - Surface downward solar
    #   - Surface downward thermal
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

def fix(year, sampling=3):
    """
    Fix the accumulated forecast variables back to instantaneous values for
    a given year's output.

    Optionally specify the sampling interval in hours (defaults to 3 for the
    ERA-20C data).

    """

    fname = '{}_forecast.grb'.format(year)
    grb = pygrib.open(fname)

    # Get a list of the unique variable nanes. This is inefficient because we
    # iterate through all variables and all times. I haven't found a nice way
    # to get these names with pygrib, which seems like a bit of a limitation to
    # me.
    names = []
    for g in grb:
        if g['name'] not in names:
            names.append(g['name'])

    grb.rewind()

    # Now we've got the variable names, we can open them individually and dump
    # them in a dict for writing to netCDF. Store the metadata too.
    data = {}
    for name in names:
        current = grb.select(name=name)

        # We have 24 hour long 3-hourly cumulative forecast data which need to
        # be converted to instantaneous values.
        ns = 24 / sampling
        nt = len(current)
        lat, lon = current[0].latlons()
        ny, nx = np.shape(lat)
        for tt in range(ns + 3, nt, ns):
            day = np.empty((ny, nx, ns))
            for hh in range(ns):
                day[..., ns - hh - 1] = current[tt - hh - 1]['values']
            day_diff = np.dstack((day[..., 0], np.diff(day[..., ::-1], axis=2)))
            # Convert the heat flux parameters from J/m^2 to W/m^2 by dividing by the time interval (in seconds).
            if 'radiation' in name:
                day_diff = day_diff / (3600 * ns)



        # Animate the current data
        fig = plt.figure()
        ax = fig.add_subplot(111)
        cmax = 500
        ani = animation.FuncAnimation(fig,
                                      update_plot,
                                      np.arange(8),
                                      init_func=init_plot,
                                      interval=25,
                                      blit=True)




    for v in grb:
        if 'precipitation' in v:


        pass

def update_plot(i):
    pc = ax.pcolormesh(day_diff[..., i])
    pc.set_clim(0, cmax)
    return pc,

def init_plot():
    pc = ax.pcolormesh(day_diff[..., 0])
    plt.colorbar(pc)
    pc.set_clim(0, cmax)
    return pc,


if __name__ == '__main__':

    start = 2000
    end = 2010

    server = ECMWFDataServer()

    for year in range(start, end):

        # Download the GRIB file.
        get(year)

        # Fix the forecast data variables to instantaneous and write out to
        # netCDF.
        #fix(year)


