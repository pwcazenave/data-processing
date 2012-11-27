#!/bin/bash

# Script to extract boundary files from Uehara's original inputs in 
# ./no_headers.

# Only need one time-slice's worth of inputs, since the boundaries don't change
# across time. We'll use the 00ka BP data. Likewise, the tidal constituent file
# we choose is irrelevant because the boundaries are all the same, so let's use 
# the M2 constituent, as it's a pretty important one.

infile=./no_headers/bta0-m2_00ka_m.dat

# Katsuto's readme.txt indicates the following order for the boundary file 
# identifier in column 4:
#       East:   1
#       West:   2
#       North:  3
#       South:  4
# So, let's use awk to pull out each boundary into a separate file, according
# to these values
boundaries=(east west north south)
for ((i=1; i<=4; i++)); do # start from one and go to 4
   awk '{if ($5=='$i') print $1,$2,"1 0 0"}' $infile > ../../../land_files/round_8_palaeo/uehara_${boundaries[$(($i-1))]}_coastline.xyz
done
