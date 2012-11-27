#!/bin/csh -f

# script to determine the difference between the original grid and the new
# gps tidally corrected bathymetry grid

##----------------------------------------------------------------------------##

# get the basics in
set area=-R314494/322135/5.59553e+06/5.59951e+06
set proj=-Jx0.003

# i/o
set infile_05=../2005/swath/raw_data/area473_2005_3.pts
set infile_06=../2006/swath/raw_data/area473_2006_gps_tide.txt
set outfile_2005=./images/gps_area473_2005.ps
set outfile_2006=./images/gps_area473_2006.ps
set diff_05_06=./images/gps_diff_05_06.ps

# page dimensions etc.
set a4=-R0/32/0/22
set page=-JX32c/22c

# labelling etc.
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset HEADER_OFFSET 0.2c
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##

# do the processing
# make a 2.5 metre grid of the two datasets (again...)
# 2005
#awk '{print $1, $2, $3*-1}' $infile_05 | blockmean $area -I2.5 \
#   > ./raw_data/area473_2005_gps.bmd
# 2006
#blockmean $area -I2.5 $infile_06 \
#   > ./raw_data/area473_2006_gps.bmd

# gridding
#surface -Garea473_2005_gps_interp.grd -I2.5 $area -T0 \
#   ./raw_data/area473_2005_gps.bmd
#surface -Garea473_2006_gps_interp.grd -I2.5 $area -T0 \
#   ./raw_data/area473_2006_gps.bmd

# fft filter the data (no NaNs! - just the output of surface)
#grdfft area473_2005_gps_interp.grd -G2005.fft -L -F-/-/800/70
#grdfft area473_2006_gps_interp.grd -G2006.fft -L -F-/-/800/70

# remask the area
#grdmath 2005.fft area473_2006_mask.grd MUL = \
#   gps_area473_2005_fft.grd
#grdmath 2006.fft area473_2006_mask.grd MUL = \
#   gps_area473_2006_fft.grd

##----------------------------------------------------------------------------##

# differences...
# subtract one grid from the other
#grdmath gps_area473_2005_fft.grd gps_area473_2006_fft.grd SUB = \
#   gps_area473_diff.grd

##----------------------------------------------------------------------------##

# plot the images
# make a colour palette file
grd2cpt -Cwysiwyg $area -Z gps_area473_diff.grd > .gps_diff.cpt

grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry Difference":WeSn \
   -C.diff_05_06.cpt gps_area473_diff.grd \
   -K -Xc -Yc > $diff_05_06

# scales etc.
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $diff_05_06
psscale -B1 -C.diff_05_06.cpt -D28/10/3/0.4 -O -K >> $diff_05_06
pstext $page $a4 -O << DIFF_05_06 >> $diff_05_06
27.4 12 12 0 0 1 Difference (m)
DIFF_05_06

##----------------------------------------------------------------------------##

# view the images
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $diff_05_06
