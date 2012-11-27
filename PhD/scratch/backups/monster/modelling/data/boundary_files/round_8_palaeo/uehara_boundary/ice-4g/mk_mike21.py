#!/usr/bin/env python

# Read in a template 21t file and produce a set of them for 
# Katsuto's boundary data.

# Pierre Cazenave 26/05/2010 pwc101@soton.ac.uk

import sys
#import fileinput 
import re

class TemplateFileSyntaxError(Exception):
   def __init__(self, msg): self.msg = msg
   def __str__(self): return repr(self.msg)

class ParseTemplate():
   def __init__(self,filepath):
      self.structure={}
      self.parse(filepath)

#   def __getitem__(self,key):
#      return self.structure.get(key)

   def parse(self,filepath):
      for line in file(filepath):
         line=line.strip()
         if line.strip():
            if line=='EndSect  // M21_TidePH': # EOF
               break
            elif '=' in line:
               structureName,structureVal=line.split('=')
               self.structure[structureName.strip()]=structureVal.strip()
            else:
               self.structure[line.strip()]=None
      else:
         raise TemplateFileSyntaxError('Improperly formatted template file. Check and try again.')

class ParseNewData():
   def __init__(self,datapath):
      self.newData={}
      self.header=[]
      self.consts=['k1','m2','n2','o1','s2']
      self.lines(datapath)

   def lines(self,datapath):
      count=0
      for line in file(datapath):
         if '#' not in line:
            count+=1
            line=re.sub("\s+"," ",line.strip())
            [lon,lat,ha,hp,i,ua,va]=line.split(' ')
            self.newData[count]=[lon,lat,ha,hp,i,ua,va]
         else:
            self.header=re.sub("\s+"," ",line.strip())

template,datafiles=sys.argv[1],sys.argv[2:]

templateArray=ParseTemplate(template)
print templateArray.structure

for datapath in datafiles:
   dataArray=ParseNewData(datapath)
   print dataArray.newData
   print dataArray.header

# Use the templateArray to populate new values from dataArray.newData
