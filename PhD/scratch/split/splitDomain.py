#!/usr/bin/env python

"""

Takes a number of arguments on the commandline to split a domain
into either a fixed number of subdomains, or a number of domains
of a given size.

Size and number of domains can be asymmetrical.

Pierre Cazenave pwc101 {at} soton [dot] ac <dot> uk

"""

import os
import sys
import getopt
import commands
import math

class InputError(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)


class MakeFixedExtents:
	"""
	For a given domain, calculates the extents based on a fixed subdomain
	size. Provides the WESN coordinates for each subset starting from the
	southwestern corner and moving to the northeastern corner. The domain 
	can be rectangular.
	"""
	
	def __init__(self):

		self.xExtents = []
		self.yExtents = []

		# Based on the specified increment, calculate the width and height of
		# the domain, and save the extents of each subset.
		xIter = float((east-west)/xInc)
		yIter = float((north-south)/yInc)
		
		for xLim in range(int(math.ceil(xIter))):
			self.xExtents.append(west+(xLim*xInc))
			self.xExtents.append(west+(xLim*(xInc+1)))
		for yLim in range(int(math.ceil(yIter))):
			self.yExtents.append(south+(yLim*yInc))
			self.yExtents.append(south+(yLim*(yInc+1)))



class MakeVariableExtents:
	"""
	Calcuates the coordinate extents for a domain into a specified number 
	of domains, whose sizes will be odd widths (but still fixed).
	"""

	def __init__(self):
		
		self.xExtents = []
		self.yExtents = []
		
		if int(math.ceil(xSplit)-math.floor(xSplit)) is not 0:
			raise InputError, 'Specify a whole number increment in the x dimension'

		if int(math.ceil(ySplit)-math.floor(ySplit)) is not 0:
			raise InputError, 'Specify a whole number increment in the y dimension'

		# Extract the size of xInc and yInc based on the number of specified
		# subdivisions.
		xInc = float(east-west)/xSplit
		yInc = float(north-south)/ySplit

		xIter = xSplit
		yIter = ySplit

		# Although not stricly necessary, leave the int(math.ceil()) in.
		for xLim in range(int(math.ceil(xIter))):
			self.xExtents.append(west+(xLim*xInc))
			self.xExtents.append(west+(xInc*(xLim+1)))
		for yLim in range(int(math.ceil(yIter))):
			self.yExtents.append(south+(yLim*yInc))
			self.yExtents.append(south+(yInc*(yLim+1)))
		
class SplitDomain:
	"""
	For a given domain, splits the domain into fixed sized subsets based 
	on the coordinates output from either MakeFixedExtents() or 
	MakeVariableExtents(). This can either be done internally with Python,
	or is can call awk as an external command. The former might be useful
	on Windows machines which don't have awk installed, the latter is
	probably going to be faster.

	In both instances, the output is written to the output file with the
	calculated extents for the particular iteration.
	"""

	def __init__(self,filepath,xMin,xMax,yMin,yMax,outfile):
		
		fout=open(outfile,'w')

		self.xloc = []
		self.yloc = []
		self.zVal = []
		self.subset = []

		try:
			pass
			# We'll have a go at using awk...
			#os.system("awk '{if ($1>'$WEST' && $1<='$EAST' && $2>'$SOUTH' && $2<='$NORTH'}'"+filepath)
		finally:
			# OK, we don't have awk, or it didn't work. Do this natively.

			for line in open(filepath):
				line = line.strip()
				if ' ' in line:
					line = ' '.join(line.split( ))

				try:
					self.xLoc, yLoc, self.zVal = line.split('\t')
				except:
					self.xLoc, self.yLoc, self.zVal = line.split(' ')
				
				if float(xMin) < float(self.xLoc) <= float(xMax) and float(yMin) < float(self.yLoc) <= float(yMax):
					fout.write(line+'\n')

		fout.close()

# All of these must be able to be floats, so make sure the code doesn't
# rely on them being ints at any point. 
# TODO: Read in these values with getopt.

options, remainder = getopt.gnu_getopt(sys.argv[1:], 'F:S:R:', ['fixed','size','area'])

fixed=False
variable=False

for opt, arg in options:
	if opt in ('-F', '--fixed'):
		fixed = True
		xInc, yInc = arg.split('/')
		xInc = float(xInc)
		yInc = float(yInc)
	elif opt in ('-S', '--size'):
		variable = True
		xSplit, ySplit = arg.split('/')
		xSplit = float(xSplit)
		ySplit = float(ySplit)
	elif opt in ('-R', '--area'):
		west, east, south, north = arg.split('/')
		west = float(west)
		east = float(east)
		south = float(south)
		north = float(north)

file = "test_data.txt"
basename, extension = os.path.splitext(file)

if fixed:
	domain = MakeFixedExtents()
elif variable:
	domain = MakeVariableExtents()

count=0

if fixed:
	print "doing fixed"
	for i in range(0,len(domain.xExtents),2):
		for j in range(0,len(domain.yExtents),2):
			count+=1
			print "Set %i of %i..." % (count, ((east-west)/xInc)*((north-south)/yInc))
			suffix = "_"+str(domain.xExtents[i])+"_"+str(domain.xExtents[i+1])+"_"+str(domain.yExtents[j])+"_"+str(domain.yExtents[j+1])+"_"+str(xInc)+"_"+str(yInc)
			SplitDomain(file,domain.xExtents[i], domain.xExtents[i+1], domain.yExtents[j], domain.yExtents[j+1],basename+suffix+extension)
elif variable:
	print "doing variable"
	for i in range(0,len(domain.xExtents),2):
		for j in range(0,len(domain.yExtents),2):
			count+=1
			print "Set %i of %i..." % (count, xSplit*ySplit)
			suffix = "_"+str(domain.xExtents[i])+"_"+str(domain.xExtents[i+1])+"_"+str(domain.yExtents[j])+"_"+str(domain.yExtents[j+1])+"_"+str(xSplit)+"_"+str(ySplit)
			SplitDomain(file,domain.xExtents[i], domain.xExtents[i+1], domain.yExtents[j], domain.yExtents[j+1],basename+suffix+extension)
			
