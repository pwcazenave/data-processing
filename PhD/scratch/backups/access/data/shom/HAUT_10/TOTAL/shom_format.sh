#!/bin/bash

# Take the SHOM raw data, cut out the appropriate columns and split out
# annual files from the aggregated data for each site, such that it matches
# the format of the NTSLF files (i.e. YYYYNAME.txt)
# We're not using the residuals because they're not always present, which
# makes my life difficult in MATLAB.

for i in *.slv; do
	cut -c1-4,6-7,9-10,12-13,15-16,18-20,21- --output-delimiter=" " $i > /tmp/$i
	cd ./formatted
	awk '{print $1,$2,$3,$4,$5,$6,$7 >> $1"'${i%.*}'.txt"}' /tmp/$i
	cd -
	\rm -f /tmp/$i
done
