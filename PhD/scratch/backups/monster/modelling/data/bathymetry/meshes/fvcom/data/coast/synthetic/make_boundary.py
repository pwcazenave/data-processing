#!/usr/bin/env python

# Dirty little script to make a linear boundary

import numpy as np

# Set some constants
lat = 63.5
startLon = -15
endLon = 15
bRes = 0.1

nDegLon = (endLon - startLon) / bRes

f = open('boundary.cst', 'w')

# Write the cst file header
f.write('COAST\n')
f.write('1\n') # number of segments
f.write(str(int(nDegLon)) + ' 0.0\n') # number of nodes in the first segment

for i in np.linspace(startLon, endLon, nDegLon):
    #print (float(i), float(lat), 0.0)
    f.write('\t{0}  {1}   {2}\n'.format(float(i), float(lat), float(0.0)))
