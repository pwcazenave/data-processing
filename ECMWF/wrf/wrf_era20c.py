"""
Get relevant forcing data for WRF from the ECMWF servers.

Author: Pierre Cazenave, Plymouth Marine Laboratory, December 2015

"""

from __future__ import print_function

import os
import sys
import calendar
import datetime

from ecmwfapi import ECMWFDataServer


def get(year, month, outdir='.'):
    """
    Get the ECMWF ERA-20C FVCOM forcing data for a given year.

    Gets the following variables at the surface and model levels.

    Model:
    ML_PARAMS=z/q/u/v/t/d/vo
    LEVELS=1000/925/850/700/500/300/250/200/150/100/70/50/30/20/10

    Surface:
    SFC_PARAMS=sp/msl/skt/2t/10u/10v/2d/z/lsm/sst/ci/sd/stl1/stl2/stl3/stl4/swvl1/swvl2/swvl3/swvl4

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

    files = []

    # Buffer by four days from the current month.
    date = datetime.datetime(year, month, 01, 00, 00, 00)
    dom = calendar.monthrange(year, month)[-1]
    start_date = date - datetime.timedelta(days=4)
    end_date = date + datetime.timedelta(dom + 4)
    s_start = start_date.strftime('%Y-%m-%d')
    s_end = end_date.strftime('%Y-%m-%d')

    prefixes = ('{:04d}-{:02d}_ML.grb2', '{:04d}-{:02d}_SFC.grib')
    files = (os.path.join(outdir, prefixes[0].format(year, month)),
             os.path.join(outdir, prefixes[1].format(year, month)))

    if not os.path.exists(files[0]):
        try:
            # Pressure levels data
            server.retrieve({
                "class": "e2",
                "dataset": "era20c",
                "date": "{}/to/{}".format(s_start, s_end),
                "expver": "1",
                "levelist": "1/2/3/5/7/10/20/30/50/70/100/125/150/175/200/225/250/300/350/400/450/500/550/600/650/700/750/775/800/825/850/875/900/925/950/975/1000",
                "levtype": "pl",
                "param": "129.128/130.128/131.128/132.128/133.128/138.128/155.128",
                "stream": "oper",
                "target": files[0],
                "time": "00/03/06/09/12/15/18/21",
                "type": "an",
            })
        except Exception:
            os.remove(files[1])

    if not os.path.exists(files[1]):
        try:
            # Surface data
            server.retrieve({
                "class": "e2",
                "dataset": "era20c",
                "date": "{}/to/{}".format(s_start, s_end),
                "expver": "1",
                "levtype": "sfc",
                "param": "31.128/34.128/39.128/40.128/41.128/42.128/134.128/139.128/"
                         "141.128/151.128/165.128/166.128/167.128/168.128/170.128/"
                         "183.128/235.128/236.128",
                "stream": "oper",
                "target": files[1],
                "time": "00/06/12/18",
                "type": "an",
            })
        except Exception:
            os.remove(files[1])

    return files


if __name__ == '__main__':

    noisy = True

    # Read in the month and year from the arguments to the script.
    year = int(sys.argv[1])
    month = int(sys.argv[2])

    output = os.path.join('grib', '{}'.format(year))
    try:
        os.makedirs(output)
    except:
        pass

    # Download the GRIB files.
    files = get(year, month, outdir='grib/{}'.format(year))
