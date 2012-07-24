#!/usr/bin/env python

import sys
import datetime
import time
import os

class WaterFileSyntaxError(Exception):
    def __init__(self, msg): self.msg = msg
    def __str__(self): return repr(self.msg)

class GetTide():
    def __init__(self,filepath):
        self.header = {}
        self.values = []
        self.parse(filepath)

    def __getitem__(self,key):
        return self.header.get(key)

    def parse(self,filepath):
        stillReadingHeader = True
        for line in file(filepath):
            line = line.strip()
            if stillReadingHeader:
                if line == 'VALUES':
                    stillReadingHeader = False
                else:
                    headerName,headerVal = line.split('=')
                    self.header[headerName.strip()] = headerVal.strip()
            else:
                if line == 'END':
                    break
                if line == self['MISSING VALUE']:
                    self.values.append(None)
                else:
                    self.values.append(line)
                    # self.values.append(int((line)) # former line
        else:
            raise WaterFileSyntaxError('Section "VALUES" missing or did not end with "END"')

### Main program i.e. grunt work

for filepath in sys.argv[1:]:

    # Get the basename and extension
    base, ext = os.path.splitext(filepath)

    # Open the output file
    f = open(base + '.txt', 'wt')

    # use GetTide above to separate the header from the tidal data
    gt = GetTide(filepath)

    startDate, startTime = gt.header['PERIOD BEGIN'].split(" ")
    interval = int(gt.header['REGISTRATION INTERVAL'])

    if gt.header['TIME REFERENCE'] == 'GMT':
        fixZone = datetime.timedelta(minutes=0)
    elif gt.header['TIME REFERENCE'] == 'MET':
        fixZone = datetime.timedelta(minutes=60)

    if gt.header.has_key('WATER DEPTH'):
        fixDepths = gt.header['WATER DEPTH']
    else:
        fixDepths=0

    timeOffset = datetime.timedelta(minutes = interval)
    currTime=datetime.datetime(int(startDate[:4]), \
                               int(startDate[4:6]), \
                               int(startDate[6:8]), \
                               int(startTime[:2]), \
                               int(startTime[2:4]),\
                               int(startTime[4:6])\
                               )

    for i in xrange(int(gt.header['NUMBER OF DATA RECORDS'])):
        printTime = currTime + ((timeOffset * i) - fixZone)
        if gt.values[i] == None:
            f.write(printTime.strftime("%Y,%m,%d,%H,%M,%S") + ",-9999,-9999,P\n")
        else:
            f.write(printTime.strftime("%Y,%m,%d,%H,%M,%S") + "," + str(float(gt.values[i]) / 100) + ",-9999,P\n")
