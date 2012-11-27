#!/bin/bash

# script to generate a small (~10MB) file of the sound of harris lidar data
# in lat/long and utm

infile=./soh_original_longlat.txt

awk '{if ($1 <= -7.08983 && $1 >= -7.09383 && $2 <= 57.7121 && $2 >= 57.7093) print}' $infile > soh_clipped.txt
