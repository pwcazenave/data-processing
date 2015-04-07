"""
Script to take the bounds of each data set and create a polygon of it in
a shapefile. Useful for identifying what data is where.

"""

import os
import glob
import shapefile

if __name__ == '__main__':

    # Output file name.
    shp = os.path.join('shp', 'ukho.shp')
    try:
        os.mkdir('shp')
    except:
        pass

    bounds = glob.glob(os.path.join('metadata', '*.bnd'))

    w = shapefile.Writer(shapefile.POLYGON)
    w.field('ID','C',50)
    w.field('year','C',50)
    w.field('name','C',50)
    w.field('mindepth','C',50)
    w.field('maxdepth','C',50)
    #w.field('Minimum depth', fieldType='F', size='10', decimal=4)
    #w.field('Maximum depth', fieldType='F', size='10', decimal=4)

    for file in bounds:
        with open(file, 'r') as f:
            bnds = [float(i) for i in f.read().strip().split('\t')]

        # Use only the first 6 columns (some files apparently have more
        # than three columns).
        south, north, west, east, zmin, zmax = bnds[:6]

        poly = [
            [west, south],
            [west, north],
            [east, north],
            [east, south],
            [west, south]
            ]

        site = os.path.splitext(os.path.basename(file))[0]
        year = int(site.split(' ')[0])
        id = site.split(' ')[1]
        name = ' '.join(site.split(' ')[2:])

        # Add to the shapefile.
        w.poly(parts=[poly])
        w.record(id, str(year), name, str(zmin), str(zmax))

    w.save(shp)

