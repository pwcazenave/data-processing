#!/bin/bash

# Script to take the raw BODC tidal data, extract the location and timeseries
# for a given site and year, and output it to a MIKE/MATLAB friendly format.
#
# In a separate, but related file, store the quality information:
#	M = improbable value from BODC quality control
#	N = null value
#	T = interpolated value
#
# The format for the MIKE/MATLAB file is:
# SampleNumber Year Month Day Hour Minute Second Height Residual
#
# Pierre Cazenave 22/10/2010 v1.0
# pwc101 <at> soton {dot} ac [dot] uk
#

# Let's get it on...

for i in ./bodc_archive_all/???????.txt; do
	echo $i
	awk '{if (NR>11) print $0}' "$i" | \
		tr ")/:" " " | \
		grep -v [A-Z] > \
		./bodc_archive_all/formatted/$(basename "$i")
done
