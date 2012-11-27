#!/usr/bin/env python

import sys,math

class LoadData():
   def __init__(self):
      self.alldata=[]
      alldata=open(sys.argv[2]:)
      global x y z
      x,y,z=alldata.split(' ')

class CutMeUp():
   def __init__(self):
      self.currdata=[]
      for i in range(len(x))
         for j in range(len(y))
            if (x[i]>xmin) and (x[i]<xmax) and (y[j]>ymin) and (y[j]<ymax)
               currdata=z[i]

# Search for data within a sector defined by the size of the domain
class MakeExtents():
   def __init__(self):
      # Make a couple of arrays to hold the x and y coordinates
      self.xs=[]
      self.ys=[]
      self.xit=[]
      self.yit=[]
      self.gcwesn=[]
   
      south=91505
      west=578106
      north=98686
      east=588291
      inc=float(sys.argv[1])

      xit=(east-west)/inc
      yit=(north-south)/inc

      for x in range(int(math.ceil(xit))):
         xmax=west+inc
         self.xs[x].append(west)
         self.xs[x+1].append(xmax)
         south=xmax

      for y in range(int(math.ceil(yit))):
         ymax=south+inc
         self.xs[y].append(south)
         self.xs[y+1].append(ymax)
         south=ymax

      # Calcaulte the coordinates for each block
#      for xal in range(len(self.xs)):
#         for yal in range(len(self.ys)):
#            print self.xs[xal],self.ys[yal]
##            self.gcwesn.append=self.xs[x],self.ys[y]


# Make the extents
data=MakeExtents()
print data.gcwesn

# Open the file(s)
#for filename in sys.argv[2:]:
#	inmem=open(filename)



#class WaterFileSyntaxError(Exception):
#   def __init__(self, msg): self.msg = msg
#   def __str__(self): return repr(self.msg)
#
#class GetTide():
#   def __init__(self,filepath):
#      self.header={}
#      self.values=[]
#      self.parse(filepath)
#
#   def __getitem__(self,key):
#      return self.header.get(key)
#
#   def parse(self,filepath):
#      stillReadingHeader=True
#      for line in file(filepath):
#         line=line.strip()
#         if stillReadingHeader:
#            if line == 'VALUES':
#               stillReadingHeader=False
#            else:
#               headerName,headerVal=line.split('=')
#               self.header[headerName.strip()]=headerVal.strip()
#         else:
#            if line == 'END':
#               break
#            if line == self['MISSING VALUE']:
#               self.values.append(None)
#            else:
#               self.values.append(line)
##               self.values.append(int((line)) # former line
#      else:
#         raise WaterFileSyntaxError('Section "VALUES" missing or did not end with "END"')
#
#### Main program i.e. grunt work
#
#for filepath in sys.argv[1:]:
#   # use GetTide above to separate the header from the tidal data
#   gt=GetTide(filepath)
#
#   # check the headers...
##   print gt.header['NUMBER OF DATA RECORDS']
#
#   startDate,startTime=gt.header['PERIOD BEGIN'].split(" ")
#   interval=int(gt.header['REGISTRATION INTERVAL'])
#   
#   if gt.header['TIME REFERENCE'] == 'GMT':
#      fixZone=timedelta(minutes=0)
#   elif gt.header['TIME REFERENCE'] == 'MET':
#      fixZone=timedelta(minutes=60)
#
#   if gt.header.has_key('WATER DEPTH'):
#      fixDepths=gt.header['WATER DEPTH']
#   else:
#      fixDepths=0
#
#   timeOffset=timedelta(minutes=interval)
#   currTime=datetime.datetime(int(startDate[:4]),int(startDate[4:6]),int(startDate[6:8]),int(startTime[:2]),int(startTime[2:4]),int(startTime[4:6]))
#
##   print fixZone,timeOffset,timeOffset-fixZone
#
#   for i in range(int(gt.header['NUMBER OF DATA RECORDS'])):
##      print currTime,startDate,startTime
##      print startTime[:2],startTime[2:4],startTime[4:6]
#      printTime=currTime+((timeOffset*i)-fixZone)
#      if gt.values[i] == None:
##         print "there's a nan"
#         print printTime.strftime("%Y,%m,%d,%H,%M,%S"),"NaN"
#      else:
##         print "it's all numbers, john"
#         print printTime.strftime("%Y,%m,%d,%H,%M,%S"),(float(gt.values[i])/100)+float(fixDepths)
#
