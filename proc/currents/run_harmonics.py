"""
Load current meter data from the SQLite database and perform a harmonic
analysis on the u and v components, saving the results to an SQLite database
matching format with the tidal equivalent.

The multiprocessing approach is taken from:

http://stackoverflow.com/questions/10797998

"""

from __future__ import print_function

import os
import glob
import multiprocessing

import numpy as np
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap
from mpl_toolkits.axes_grid1 import make_axes_locatable
from pytides.tide import Tide
from datetime import datetime

from PyFVCOM.current_tools import scalar2vector, addHarmonicResults, getObservedData, getObservedMetadata

def worker(input, output):
    """ Worker function to add our function of interest to the queue. """

    for func, args in iter(input.get, 'STOP'):
        result, name = calculate(do_harmonics, args)
        output.put((result, name))


def calculate(func, args):
    """ Wrapper around the function we want to run and its inputs. """

    result, name = func(*args)

    return result, name


def do_harmonics(Times, series, name):
    """
    Perform the harmonic analysis on a single time series. This makes this
    function much more usable in parallel.

    Parameters
    ----------
    Times : datetime
        datetime object of the times.
    series : ndarray
        Time series data to analyse (e.g. u, v, zeta).
    name : str
        Station name.

    Returns
    -------
    modelled : dict
        Dictionary of the results with keys 'constituent', 'phase' and
        'amplitude' of type list (of strings), ndarray and ndarray,
        respectively.

    """

    analysis = Tide.decompose(series, Times)

    modelled = {}
    modelled['constituent'] = [c.name for c in analysis.model['constituent']]
    modelled['amplitude'] = analysis.model['amplitude']
    modelled['phase'] = analysis.model['phase']

    return modelled, name


def coasts(m, parallels, meridians):
    """ Plot the Basemap basics. """

    m.drawmapboundary()
    m.drawcoastlines(zorder=100)
    m.fillcontinents(color='0.6', zorder=100)
    m.drawparallels(parallels, labels=[1, 0, 0, 0], fontsize=10, linewidth=0)
    m.drawmeridians(meridians, labels=[0, 0, 0, 1], fontsize=10, linewidth=0)


if __name__ == '__main__':

    # Set up the multiprocessing environment.
    multiprocessing.freeze_support()
    task_queue = multiprocessing.Queue()
    done_queue = multiprocessing.Queue()
    NPROCS = multiprocessing.cpu_count() - 1 # leave a spare CPU

    noisy = True

    db = os.path.join(os.path.sep,
            'users', 'modellers', 'pica', 'Data',
            'proc', 'currents', 'currents.db')
    hdb = os.path.join(os.path.sep,
            'users', 'modellers', 'pica', 'Data',
            'proc', 'currents', 'harmonics.db')

    # Load some data and format it for pytides.
    lat, lon, site, longname = getObservedMetadata(db)

    data = {}
    for s in site:
        sitedata = np.asarray(getObservedData(db, s, noisy=noisy))
        times = sitedata[:, :6].astype(int)
        dates = np.asarray([datetime(*i) for i in times])
        # Only add this site if we've got a sufficiently long time series, defined
        # here as greater than 2 weeks.
        duration = (dates[-1] - dates[0]).total_seconds() / 60 / 60 / 24 # in days
        if duration <= 14.0:
            if noisy:
                print('Skipping {} due to short time series ({:.2f} days)'.format(s, duration))
                continue
        data[s] = {}
        data[s]['dates'] = dates
        # Convert speed from cm/s to m/s.
        u, v = scalar2vector(sitedata[:, 7].astype(float), sitedata[:, 6].astype(float) / 100)
        data[s]['u'] = u
        data[s]['v'] = v

    #u_tide = Tide.decompose(data[s]['u'], data[s]['dates'])
    #v_tide = Tide.decompose(data[s]['v'], data[s]['dates'])

    # pytide results are stored in an odd manner (seems as though they're
    # intended for use in pandas). However, the bits I'm interested in are:
    #   u_tide.model['constituent'] # constituent names (sort of)
    #   u_tide.model['amplitude'] # constituent amplitude
    #   u_tide.model['phase'] # constituent phase (degrees)
    #
    # To get a list of the constituent names, you can do this:
    #   cnames = [c.name for c in u_tide.model['constituent']]
    #
    # then extracting the amplitude and phase for a given constituent is just
    # a cname.index('M2') away.

    # So, fitting this in with my existing TAPPY infrastructure means writing
    # the relevant data to the SQLite database and supplying dummy data for the
    # information which TAPPY returns which pytides doesn't.

    # Do the parallel preprocessing. Since the data is stored in a dict, we
    # need to be doubly sure we're marrying up the right input with the right
    # output.
    keys = data.keys()
    ns = len(keys)
    for comp in 'u', 'v':
        TASKS = [(Tide, (
            data[keys[i]]['dates'],
            data[keys[i]][comp],
            keys[i]
            )) for i in range(ns)]
        for task in TASKS:
            task_queue.put(task)
        for _ in range(NPROCS):
            multiprocessing.Process(target=worker, args=(task_queue, done_queue)).start()
        # Extract the results into a single large dict.
        harmonics = {}
        for _ in TASKS:
            ret = done_queue.get()
            results, name = ret
            harmonics[name] = results

        for k in keys:
            # We don't have a speed value, so set to -1 here. Set the inferred
            # values to False too.
            addHarmonicResults(hdb, k,
                    harmonics[k]['constituent'],
                    harmonics[k]['phase'],
                    harmonics[k]['amplitude'],
                    np.zeros(harmonics[k]['phase'].shape) - 1,
                    np.repeat('False', len(harmonics[k]['constituent'])),
                    ident=comp,
                    noisy=noisy)

    # Set up the ancillary information for the plot.
    extents = np.array((np.min(lon), np.max(lon), np.min(lat), np.max(lat)))
    m = Basemap(llcrnrlon=extents[0:2].min(),
            llcrnrlat=extents[-2:].min(),
            urcrnrlon=extents[0:2].max(),
            urcrnrlat=extents[-2:].max(),
            rsphere=(6378137.00, 6356752.3142),
            resolution='i',
            area_thresh=0.1,
            projection='merc',
            lat_0=extents[-2:].mean(),
            lon_0=extents[0:2].mean(),
            lat_ts=extents[-2:].mean())

    parallels = np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 2.5)
    meridians = np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 5)

    x, y = m(lon, lat)

    fig0 = plt.figure(figsize=(12, 10))
    ax0 = fig0.add_subplot(1, 1, 1)

    coasts(m, parallels, meridians)

    pl0 = ax0.plot(x, y, 'ko', label='Current meters', zorder=100)

    #div0 = make_axes_locatable(ax0)
    #cax0 = div0.append_axes("right", size="2.5%", pad=0.1)
    #cb0 = fig0.colorbar(tp0, cax=cax0)
    #cb0.set_label('Amplitude (m)')

    fig0.tight_layout(pad=3)
    fig0.show()
    fig0.savefig(os.path.join('BODC_current_meters.png'))

