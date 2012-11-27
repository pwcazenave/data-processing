#!/usr/bin/env python

# Script to create tidal heights from the tidal constituents given to
# me by Katsuto Uehara from his paper on the northwest European continental
# shelf.
#

import sys
import os
import linecache
import math
import re
import string
import pickle

class FileException(Exception):
   def __init__(self, msg): self.msg = msg
   def __str__(self): return repr(self.msg)

class DataError(Exception):
   def __init__(self, msg): self.msg = msg
   def __str__(self): return repr(self.msg)

class MakeTime():
   def __init__(self,startDate,startTime,endDate,endTime):
      import datetime
      sYr=int(startDate[:4])
      sMon=int(startDate[4:6])
      sDay=int(startDate[6:8])
      sHr=int(startTime[:2])
      sMin=int(startTime[2:4])
      sSec=int(startTime[4:6])
      eYr=int(endDate[:4])
      eMon=int(endDate[4:6])
      eDay=int(endDate[6:8])
      eHr=int(endTime[:2])
      eMin=int(endTime[2:4])
      eSec=int(endTime[4:6])
      print sYr,sMon,sDay,sHr,sMin,sSec,eYr,eMon,eDay,eHr,eMin,eSec


class MakeTides():
   def __init__(self,file):

      # Which time?
      # FIXME Need to use the MakeTime function to generate a timeseries
      #       which will populate the output with spatial and temporally 
      #       varying tidal height.
      t=range(0,1000)

      # I have m2, s2, n2, k1 and o1 tidal constituents. Their periods in 
      # hours are found in Wahr, J. (1995) Earth Tides.
      # Semi-diurnal periods 
#      m2=12.421
#      s2=12
#      n2=12.658
#      #k2=11.967

#      # Diurnal periods
#      k1=23.934
#      o1=25.819
#      #p1=24.066
#      #phi1=23.804
#      #omega1=23.869
#      #s1=24

      # Instead, create the speed in degrees/hour from the rotation rates
      # of the various moons/planets etc.
      Tr=15
      hr=0.04106864
      sr=0.54901653
      pr=0.00464183
      Nr=-0.00220641

      m2=(2*Tr)-(2*sr)+(2*hr)
      s2=2*Tr
      n2=(2*Tr)-(3*sr)+(2*hr)+pr
      k1=Tr+hr
      o1=Tr-(2*sr)+hr
      
      # Read in the file
      try:
         f=open(file,'r')
      except:
         raise FileException('File name not valid. Check and try again.')

      # Create an output filename based on input, but suffixed with _tide.txt
      # Outputs to "outdir"
      filename=file.split(".")[0].split("/")[-1]
      outDir="outdir/"
      if not os.path.isdir(outDir):
         os.makedirs(outDir)
      suffix="_tide.txt"
      fout=open(outDir+filename+suffix,"w")

      # Add the time series to the output file
      fout.write(str(t)+"\n")
      
      for line in f.readlines():
         # Which constituent are we working with? 
         currentFile=os.path.basename(file)
         currentHarmonic=currentFile[5:7]
         # Use the amplitude and phase from the file with the constituent's
         # period as defined above to create the new tidal height for one
         # time only
         if currentHarmonic=='m2':
            speed=m2
         elif currentHarmonic=='s2':
            speed=s2
         elif currentHarmonic=='n2':
            speed=n2
         elif currentHarmonic=='k1':
            speed=k1
         elif currentHarmonic=='o1':
            speed=o1
         else:
            raise FileException('Can\'t parse filename given for constituent.')

         if '#' in line:
#            fout.write("# hz(m)\n")
            continue
         else:
            lonDD,latDD,ha,hp,ia,ua,va=line.split()
#            omega=(2*math.pi)/(float(speed))
            # Need to split off dependent upon which boundary we're at
            if ia==1:
               newSF=east
            elif ia==2:
               newSF=west
            elif ia==3:
               newSF=north
            elif ia==4:
               newSF=south
            else:
               raise DataError('Can\'t read which boundary the data are for.')

            newOut=

            tideHeight=[]
            for timeVal in range(0,len(t)):
               tideHeight.append(float(ha)*math.cos(math.radians(float(speed))*t[timeVal]+float(hp)))
         
            fout.write(str(tideHeight)+"\n")
#            print lonDD,latDD,ha,hp,ia,ua,va,float(speed),tideHeight

for file in sys.argv[1:]:
   MakeTides(file)
#   MakeTime("20100510","120015","20100511","180014")
