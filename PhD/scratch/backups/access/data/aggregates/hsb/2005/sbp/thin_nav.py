#!/usr/bin/env python

import sys,linecache

class CalledError(Exception):
   def __init__(self, msg): self.msg = msg
   def __str__(self): return repr(self.msg)

class FilterFixes(file):
   def __init__(self,filepath):
      print filepath
      f=open(filepath,'r')

      firstline=linecache.getline(file,2)
      firstline=firstline.strip()
      firstline=firstline.split("\t")

      prevfix=int(firstline[len(firstline)-1])-1

      for line in f.readlines():
         line=line.strip()
         date,easting,northing,fix=line.split('\t')

         if fix != 'Fix':
            diff=int(fix)-int(prevfix)
            if diff != 0:
               print line
            prevfix = fix
         else:
            print line

      f.close()

if len(sys.argv[1:])<1:
   raise CalledError('No files specified when called.')
else:
   for file in sys.argv[1:]:
      FilterFixes(file)

