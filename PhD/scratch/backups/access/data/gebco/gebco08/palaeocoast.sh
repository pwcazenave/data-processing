#!/bin/bash

# Script to lower the depth values by some constant, then create a new coast-
# line where depth values are now zero.

gebco=./grids/GEBCO_08.nc # symlink
area=-20/15/45/65

if [ $# -ne 1 ]; then
   echo "Usage: $(basename $0) DEPTH"
   echo "       Where DEPTH is the amount by which to shallow the bathymetry."
   exit 0
fi

verbose=-V

zdiff=$1

# Get the relevant section
grdcut $verbose -R$area $gebco -G${gebco%.*}_cut_${area//\//_}_${zdiff}m.grd -fg

# GEBCO data has positive land and negative depth. Therefore, to shallow, we add
# values
grdmath $verbose ${gebco%.*}_cut_${area//\//_}_${zdiff}m.grd $zdiff ADD \
   = ${gebco%.*}_${area//\//_}_${zdiff}m.grd

# Make xyz values for MIKE (without NaNs)
grd2xyz $verbose -S ${gebco%.*}_${area//\//_}_${zdiff}m.grd \
   > ./modelling/$(basename ${gebco%.*}_${area//\//_}_${zdiff}m.xyz)

# Make the mask which will be used to find the edge of the new xyz file
#grdmask $verbose -R$area -I0.5m \
#   ./modelling/$(basename ${gebco%.*}_${area//\//_}_${zdiff}m.xyz)\
#   -NNaN/1/NaN -G${gebco%.*}_${area//\//_}_${zdiff}m_mask.grd

# Take the mask and filter out all NaN values leaving just the 1s (i.e. the edge)
#grd2xyz -S ${gebco%.*}_${area//\//_}_${zdiff}m_mask.grd \
#   > ./modelling/$(basename ${gebco%.*}_${area//\//_}_${zdiff}m.xy)

