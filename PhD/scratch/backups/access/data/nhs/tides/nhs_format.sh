#!/bin/bash

# Quickly format the NHS data for import into MATLAB.

for i in ./raw_data/*.txt; do
	# Strip out unecessary characters and divide the heights by 100
	# to give metres rather than centimetres.
 	tr ".:" " " < $i | awk '{if (NR>10) print $3,$2,$1,$4,$5,"00",$6/100,$8/100}' \
 		> ./formatted/$(basename $i)
done

