"""
Simple script to plot some of the river temperature climatology and the data
from which it's derived.

"""

# For headless runs:
import matplotlib as mpl
mpl.use('Agg')

import os
import glob
import multiprocessing

import numpy as np
import matplotlib.pyplot as plt

def clim_plot(ii):
    """
    Simple function to load data from a given list and plot a climatology.

    """

    # Load the data
    id = ids[ii]
    fname = id + '.csv'
    data = {}
    data['clim'] = np.genfromtxt(os.path.join(climdir, fname), delimiter=',')
    data['bin'] = np.genfromtxt(os.path.join(bindir, fname), delimiter=',')

    # Make an envelope from the binned data.
    intday = np.floor(data['bin'][:, 0])
    uintday = np.unique(intday)
    envelope = np.ma.masked_array(np.empty((uintday.shape[0], 2)), mask=False)
    for i, day in enumerate(uintday):
        idx = intday == day
        envelope[i, :] = np.min(data['bin'][idx, 1]), np.max(data['bin'][idx, 1])
        if envelope[i, 0] == envelope[i, 1]:
            envelope[i, :] = np.ma.masked

    # Plot the data.
    fig0 = plt.figure(figsize=(12, 5))
    ax0 = fig0.add_subplot(1, 1, 1)
    c0 = ax0.plot(data['clim'][:, 0], data['clim'][:, 1], 'k', linewidth=3, zorder=2, label='Two week running mean')
    b0 = ax0.fill_between(uintday, envelope[:, 0], envelope[:, 1], color=[0.75, 0.75, 0.75], alpha=0.5, zorder=1, label='Range')
    b1 = ax0.hexbin(intday, data['bin'][:, 1], gridsize=(365, data['bin'][:, 1].max().astype(int)), mincnt=1, cmap='hot_r', zorder=0, label='Density')
    b1.set_clim(0, b1.get_clim()[-1])

    c0 = plt.colorbar(b1)
    c0.set_label('Number of samples')

    l0 = ax0.legend(frameon=False)

    ax0.set_xlabel('Day of year')
    ax0.set_ylabel('Temperature $(^{\circ}C)$')

    fig0.tight_layout()
    #fig0.show()
    fig0.savefig(os.path.join('figures', id + '.png'), bbox_inches='tight', pad_inches=0.2, dpi=300)
    plt.close()


if __name__ == '__main__':

    base =  os.getcwd()
    climdir = os.path.join(base, 'climatology')
    bindir = os.path.join(climdir, 'binned')

    # Get a list of all the IDs for which we've got climatology.
    files = glob.glob(os.path.join(climdir, '*.csv'))
    ids = []
    for ff in files:
        ids.append(os.path.splitext(os.path.split(ff)[-1])[0])
    #ids = ['WQ3902T', '16020', '41000098', '26203', 'H1231181', 'THR090', 'HADY160W', '49200090', '98']

    todo = range(len(ids))
    pool = multiprocessing.Pool(processes=6)
    pool.map(clim_plot, todo)
    pool.close()


