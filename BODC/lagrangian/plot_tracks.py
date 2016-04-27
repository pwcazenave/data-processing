# Plot the BODC buoy tracks.

import os
import numpy as np
import matplotlib.pyplot as plt

from glob import glob
from mpl_toolkits.basemap import Basemap
from PyFVCOM.read_FVCOM_results import ncread


if __name__ == '__main__':

    files = glob(os.path.join('raw_data', '*.qxf'))

    data = {}
    for file in files:
        data[file] = ncread(file, vars=['ALONAT01', 'ALATAT01', 'ALONAG01', 'ALATAG01'], noisy=True)

    # Do a quick plot.
    m = Basemap(llcrnrlon=-12,
                llcrnrlat=49,
                urcrnrlon=-4,
                urcrnrlat=53,
                rsphere=(6378137.00, 6356752.3142),
                resolution='i',
                projection='merc',
                area_thresh=0.2,
                lon_0=0,
                lat_0=50.5,
                lat_ts=50.5)
    parallels = np.arange(40, 60, 0.5)
    meridians = np.arange(-20, 20, 1)

    fig0 = plt.figure(figsize=(10, 7))
    ax0 = fig0.add_subplot(111)

    m.drawmapboundary()
    m.drawcoastlines(zorder=100)
    m.fillcontinents(color='0.6', zorder=100)
    m.drawparallels(parallels, labels=[1, 0, 0, 0], linewidth=0)
    m.drawmeridians(meridians, labels=[0, 0, 0, 1], linewidth=0)

    for k in data.keys():
        try:
            x, y = m(data[k]['ALONAG01'], data[k]['ALATAG01'])
        except:
            x, y = m(data[k]['ALONAT01'], data[k]['ALATAT01'])

        ax0.plot(x, y, '.-')

    fig0.show()
    fig0.savefig('tracks.png', bbox_inches='tight', pad_inches=0.2, dpi=300)


