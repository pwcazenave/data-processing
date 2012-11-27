#!/usr/bin/env python

""" 
The NHS tidal data are in local time, and this varies depending on 
whether it's summer (GMT+2) or winter (GMT+1). Now, I could write some
horrible bash script with date to subtract the time from each reading,
but Python seems much more sensible here. 

This script takes the raw input and subtracts either one or two hours
from all the times to give GMT times. All other data are untouched.

Apparently DST in Europe (whose system Norway follows) starts on the 
last Sunday in March and ends on the last Sunday in October. So, the
summer period is from April to October inclusive; the rest is winter.

Pierre Cazenave pwc101@soton.ac.uk 21/01/2011

"""

import os
import sys
import time
import linecache
import pickle

def getTimeOfYear(file):
    """ Find out what time of year it is: Winter or Summer. """

    line = linecache.getline(file,11)
    line = line.strip()
    ddmmyyyy, obs, pred, res = line.split("\t")
    dd, mm, yyyyHHMM, = ddmmyyyy.split(".")
    yyyy, HHMM = yyyyHHMM.split(" ")
    HH, MM = HHMM.split(":")

    if mm < 4 or mm > 10:
        # Winter
        offsetTime = 1.0
    else:
        # Summer
        offsetTime = 2.0

    return offsetTime

def correctDateTime(file,offsetTime):
    """ 
    Based on the results of getTimeOfYear, subtract the requisite
    number of hours from the time for each observation.

    The header length is hardcoded as 10 lines long. Hopefully this
    won't change any time soon. 

    """

    header = []

    f = open(file)

    for line in f:
        line = line.strip()

        if line[:1].isalpha():
        	# Save the header
        	header.append(line)
        elif len(line[:1]) == 0:
            # Skip empty lines
        	continue
        else:
            ddmmyyyyHHMM, obs, pred, res = line.split("\t")

            # Convert the date and time to seconds since the epoch
            c = time.strptime(ddmmyyyyHHMM,"%d.%m.%Y %H:%M")
            t = time.mktime(c)
            t = t - (offsetTime*3600)
            tc = time.strftime("%d.%m.%Y %H:%M",time.localtime(t))

            # Format the times properly so we can avoid running the 
            # bash script at all.
            dd, mm, yyyyHHMM, = tc.split(".")
            yyyy, HHMM = yyyyHHMM.split(" ")
            HH, MM = HHMM.split(":")

            print yyyy, mm, dd, HH, MM, "00", float(obs)/100, float(res)/100


for file in sys.argv[1:]:
    offsetTime = getTimeOfYear(file)
    correctDateTime(file,offsetTime)

