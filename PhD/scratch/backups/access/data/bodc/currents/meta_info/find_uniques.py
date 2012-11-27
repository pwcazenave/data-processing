#!/usr/bin/env python

import sys
import linecache
import csv
import os
from math import abs

class CalledError(Exception):
    def __init__(self, msg): self.msg = msg
    def __str__(self): return repr(self.msg)

class FilterFixes(file):
    def __init__(self, filepath):
        base, ext = os.path.splitext(filepath)
        f=open(filepath, 'r')
        fout=open(base+'_filtered'+ext, 'w')

        firstline=linecache.getline(file, 1)
        firstline=firstline.strip()
        firstline=firstline.split(",")

        prevLatDD=0
        prevLonDD=0
        
        csvOut = csv.writer(fout, delimiter=',', quotechar='"')

        for line in csv.reader(f, delimiter=','):
            if line[0] != 'site_no':
                diffLatDD=float(line[1])-float(prevLatDD)
                diffLonDD=float(line[2])-float(prevLonDD)
                #print math.fabs(diffLatDD),float(prevLatDD),float(line[1])
                if math.fabs(diffLatDD) > 0 and math.fabs(diffLonDD) > 0:
                    csvOut.writerow(line)

                prevLatDD = line[1]
                prevLonDD = line[2]
            else:
                csvOut.writerow(line)

        f.close()
        fout.close()

if len(sys.argv[1:])<1:
    raise CalledError('No files specified when called.')
else:
    for file in sys.argv[1:]:
        FilterFixes(file)

