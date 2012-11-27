#!/bin/bash

# Simple script to cut out the correct columns from the input data 
# Katsuto sent. Also converts the amplitdue in cm to amplitude in 
# metres.
#
# Original printf:
#	'(2f10.6,f7.2,f6.1,i2,f6.2,f6.1)'
# Column widths: 
#	10    10     7      6      2      6      6
#	1-10, 11-20, 21-27, 28-33, 34-35, 36-41, 42-
# This way, the space separator between each column is at the start
# of the output column.
# 
# Pierre Cazenave 27/10/2010 v1.0

# Old, incorrectly formatted tides
#for i in ./harmonics/bte0x*.dat; do 
#	echo -n "Working on $i... "
#	cut -c1-10,11-20,21-27,28-33,34-35,36-41,42- --output-delimiter=" " < "$i" | \
#		awk '{if (NR==1) print $0; else print $1,$2,$3/100,$4,$5,$6,$7}' \
#		> ./fixed/$(basename "$i")
#	echo "done."
#done

# New, correctly formatted, and 500 year interval tides
for i in ./harmonics/bte0y*.dat; do 
	echo -n "Working on $i... "
	awk '{if (NR==1) print $0; else print $1,$2,$3/100,$4,$5,$6,$7}' "$i" \
		> ./fixed/$(basename "$i")
	echo "done."
done

# Check the file lengths match:
for i in ./harmonics/*.dat; do
	originalLength=$(wc -l < "$i")
	newLength=$(wc -l < ./fixed/$(basename "$i"))
	if [ -e ./fixed/$(basename "$i") ]; then
		printf "%s:\toriginal = %i\tnew = %i\tdifference = %i\n" "$i" $originalLength $newLength $(($originalLength-$newLength))
	else
		printf "%s file missing.\n" ./fixed/$(basename "$i")
	fi
done
