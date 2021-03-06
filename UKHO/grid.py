"""
This is going to be a monster.

Grid the data in the whole UKHO data set received so far (2015/04/07) to 1km
resolution. That's pretty low compared with the source data (probably), but is
pretty high for a shelf-wide data set. To make this even vaguely managable,
split the entire domain up into 100km by 100km tiles.

Don't do any fancy gridding (the newest, highest quality etc.) just average
everything which touches each tile.

"""

import os
import utm
import glob
import tempfile
import subprocess
import multiprocessing

import numpy as np
import matplotlib.pyplot as plt

class Point(object):
    """ A point class for a two coordinate location. """

    def __init__(self, x, y):
        self.x = x
        self.y = y


class Rect(object):
    """ A rectangle class with four points. """

    def __init__(self, p1, p2):
        """
        Store the top, bottom, left and right values for points
        p1 and p2 are the (corners) in either order.
        """

        self.left   = min(p1.x, p2.x)
        self.right  = max(p1.x, p2.x)
        self.bottom = min(p1.y, p2.y)
        self.top    = max(p1.y, p2.y)


def range_overlap(a_min, a_max, b_min, b_max):
    """ Check for overlapping ranges.

    Neither range is completely greater than the other.

    Taken from http://codereview.stackexchange.com/questions/31352

    Parameters
    ----------
    a_min, a_max, b_min, b_max : float
        Minimum and maximum values for two ranges (i.e. the edges of
        a rectangle).

    Returns
    -------
    overlapping : bool
        True if the ranges overlap.

    """

    return (a_min <= b_max) and (b_min <= a_max)


def overlap(r1, r2):
    """ Check for overlapping rectangles.

    Overlapping rectangles overlap both horizontally & vertically.

    Taken from http://codereview.stackexchange.com/questions/31352

    Parameters
    ----------
    r1, r2 : Rect
        Two rectangle classes for overlap check.

    Returns
    -------
    check : bool
        True if rectangles overlap at all.

    """

    return range_overlap(r1.left, r1.right, r2.left, r2.right) and range_overlap(r1.bottom, r1.top, r2.bottom, r2.top)


def sources(rect, poly, files):
    """ Find the raw files to use to grid the box defined by rect.

    For the box defined in rect, in the list of bounds defined in poly,
    extract the files whose bounding boxes interect the box and return the
    file names as a list.

    Coordinate types for each rectangle definition must be the same (i.e.
    all UTM, all spherical etc.).

    Parameters
    ----------
    rect : Rect
        Class describing the rectangle within which all intersecting data
        polygons should be identified.
    poly : list
        List of Rect classes describing the data polygons.
    files : list
        List of file names of data corresponding to the data polygon extents.

    Returns
    -------
    overlapping : list
        List of file paths which intersect the box `rect'.

    """

    # Do any of the raw data sets intersect this box?
    overlapping = []
    for data_rect, f in zip(poly, files):
        if overlap(rect, data_rect):
            overlapping.append(f)

    return overlapping


def grid(rect):
    """ Farm out the gridding for a given box to GMT.

    Checks for which files intersect this box and grids those that fall within
    it. Skips this box if no files are found to intersect.

    The GMT pipeline is as follows:

    1. blockmean - regularly grid the data to the desired resolution.
    2. nearneighbor - interpolate to fill gaps.
    3. grdmask - mask off regions more than four times the resolution away from
       the original data point.
    4. grdmath - apply the mask and save to netCDF.
    5. grdreformat - convert from netCDF to geoTIFF.

    Parameters
    ----------
    rect : Rect
        Box within which to grid the data.

    """

    gotgmt = 5
    gmt = 'gmt' # Assume GMT 5. Change only if the blockmean command is found.

    try:
        #subprocess.call('blockmean', stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True) == 0
        ret = subprocess.call(['blockmean', '--help'])
        gotgmt = 4
        # Eliminate the GMT prefix command used in GMT5.
        gmt = ''
    except OSError:
        pass

    if not gotgmt:
        raise OSError('GMT not/installed cannot be found. Check you PATH and/or installation.')

    files = sources(rect, poly, raw)

    if not files:
        # If the list of files is empty, just skip this box.
        if noisy:
            print('No files in this box. Skipping.')
        return

    else:

        # Fix quoting for subprocess call.
        files = ['"{}"'.format(i) for i in files]

        bfile = tempfile.NamedTemporaryFile(delete=True)
        nfile = tempfile.NamedTemporaryFile(delete=True)
        mfile = tempfile.NamedTemporaryFile(delete=True)
        prefix = 'UKHO_{}_{}_{}_{}-{}m'.format(
                rect.left,
                rect.right,
                rect.bottom,
                rect.top,
                res
                )
        ncfile = os.path.join('nc', '{}m'.format(res), '{}.nc'.format(prefix))
        geofile = os.path.join('tiffs', '{}m'.format(res), '{}.tiff'.format(prefix))

        #ax0.plot(np.mean((rect.left, rect.right)), np.mean((rect.top, rect.bottom)), 'ro')
        #fig0.show()
        #fig0.canvas.draw()

        if os.path.isfile(ncfile) and not clobber:
            if noisy:
                print('netCDF file {} exists and clobber set to False. Skipping'.format(ncfile))
            return

        area = '-R{}/{}/{}/{}'.format(rect.left, rect.right, rect.bottom, rect.top)

        blockmean = [gmt, 'blockmean', area, '-I{}'.format(res), ' '.join(files)]
        nearneighbor = [gmt, 'nearneighbor', area, '-I{}'.format(res), '-N4', '-S{}'.format(res * 4), bfile.name, '-G{}'.format(ncfile)]
        grdmask = [gmt, 'grdmask', area, '-I{}'.format(res), '-S{}'.format(res * 4), '-NNaN/1/1', bfile.name, '-G{}'.format(mfile.name)]
        grdmath = [gmt, 'grdmath', nfile.name, mfile.name, 'MUL = {}'.format(ncfile)]
        grdreformat = [gmt, 'grdreformat', ncfile, '{}=gd:gtiff'.format(geofile)]

        # Blockmean has to be handled slightly differently as it writes to
        # stdout. The others all handle output files internally.
        subprocess.call(' '.join(blockmean), stdout=bfile, shell=True)
        for proc in [nearneighbor]: #, grdmask, grdmath:
            subprocess.call(' '.join(proc), shell=True)

        if gotgmt == 5:
            subprocess.call(' '.join(grdreformat), shell=True)

        if noisy:
            if gotgmt == 5:
                print('Created files {} and {}.'.format(ncfile, geofile))
            else:
                print('Created file {}.'.format(ncfile))


if __name__ == '__main__':

    noisy = True # print output?
    serial = False # run in serial or parallel?
    clobber = True # overwrite existing files?

    raw = glob.glob(os.path.join('ascii', 'utm30n', '*.ascii'))
    bnds = glob.glob(os.path.join('metadata', '*.bnd'))

    # Grid resolution and box size.
    res = 250 # in metres
    size = 25000 # in metres

    # Get the coverage of the whole data set. Requires running the bounds.sh
    # script to extract the metadata from each file. Apparently the .xml
    # metadata doesn't include this (basic) information.
    west, east, south, north = float('inf'), -float('inf'), float('inf'), -float('inf')
    poly = []

    for file in bnds:
        with open(file) as f:
            bnd = [float(i) for i in f.read().strip().split('\t')]
            if bnd[2] < west:
                west = bnd[2]
            if bnd[3] > east:
                east = bnd[3]
            if bnd[0] < south:
                south = bnd[0]
            if bnd[1] > north:
                north = bnd[1]

            ll = utm.from_latlon(bnd[0], bnd[2], force_zone_number=30)[:2]
            ur = utm.from_latlon(bnd[1], bnd[3], force_zone_number=30)[:2]
            poly.append(Rect(Point(ll[0], ll[1]), Point(ur[0], ur[1])))

    # For sensible grids, convert to UTM. We can do the reverse at the end to
    # maintain a sensible overall grid configuration. Buffer the bounds by the
    # desired grid resolution each way.
    southwest = utm.from_latlon(south, west, force_zone_number=30)
    northeast = utm.from_latlon(north, east, force_zone_number=30)

    # Make a list of boxes which will be checked for validity when being
    # gridded.
    nx = int(np.ceil((northeast[0] - southwest[0]) / size))
    ny = int(np.ceil((northeast[1] - southwest[1]) / size))

    if noisy:
        print('{} potential boxes within the domain.'.format(nx * ny))

    west, south = southwest[:2]

    box = []
    for y in range(ny):
        for x in range(nx):

            # Get the rest of the coordinates.
            east = west + size
            north = south + size

            #box.append((west, east, south, north))
            box.append(Rect(Point(west, south), Point(east, north)))

            # Move to the next box across.
            west = west + size

        # Jump to the next row.
        south = south + size
        west = southwest[0]

    try:
        os.mkdir(os.path.join('nc', '{}m'.format(res)))
    except:
        pass

    try:
        os.mkdir(os.path.join('tiffs', '{}m'.format(res)))
    except:
        pass


    if serial:
        #fig0 = plt.figure()
        #ax0 = fig0.add_subplot(111)
        c = 0
        for b in box:
            c += 1
            if noisy: print('{} of {}'.format(c, len(box)))
            grid(b)

    else:
        # Leave a spare CPU.
        pool = multiprocessing.Pool(multiprocessing.cpu_count() - 1)
        pool.map(grid, box)
        pool.close()


