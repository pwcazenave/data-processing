#!/bin/bash

# This is a little script which will take an input ESRI ASCII grid
# file and convert it to xyz. The GMT programs 'surface' and 'grdmask'
# are then used to produce a single GMT grid which can be split up into
# subset tiles using the quicksplit.sh script.

# Here we define the input file name.
infile=./your_ESRI_ASCII_file.asc

# Here we specify the grid resolution (90m)
gres=90

# We convert the input file to xyz first.
asc2xyz "$infile" > "${infile%.*}.xyz"

# Automatically calculate the extent of the data we're working on (i.e.
# how far west to how far east, and how far south to how far north).
area=$(minmax -I1 "${infile%.*}.xyz")

# Now we have an xyz file, we need to grid it and mask off the areas in
# in which we have no data.
surface $area -T0.25 -I$gres "${infile%.*}.xyz" -G"${infile%.*}_surface.grd"

# Now we have to create a mask which has NaNs where we don't have data and 
# values of one where we do.
grdmask $area -I$gres -S$gres "${infile%.*}.xyz" -G"${infile%.*}_mask.grd"

# Now we used the mask to blank out areas where we don't have data.
grdmath "${infile%.*}_mask.grd" "${infile%.*}_surface.grd" MUL = \
    "${infile%.*}.grd"

# Clear up some of the intermediate files we don't need anymore. 
rm -f "${infile%.*}_surface.grd" "${infile%.*}_mask.grd"
