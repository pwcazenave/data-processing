#! /bin/csh 

# script to determine the difference in the depths of the hanson aggregate marine data and the wessex archaeology group data - they were presumably taken on different days and therefore in different tidal conditions.

set area=-R330528/331195/5623910/5624280
set area3=-R329880/331563/5623005/5624369
set area4=-R0/22/0/30
set proj=-JX5.3/2.9
set proj2=-JX22c/30c
set outfile=difference.ps

gmtset BASEMAP_TYPE = fancy
gmtset LABEL_FONT_SIZE = 12
gmtset HEADER_FONT_SIZE	= 16p

# preprocessing the data
# first need to reprocess the raw data from the xyz file to just show the same region as the wessex archaeology data

# increase the ascii file precision to avoid surface complaining that the data haven't been run through blockmean. 
gmtset D_FORMAT %.10lf

# use grep to remove lines where there is an incorrect depth value (1.70141E+038)
#more ../hanson_wessex_comparison/raw_data/hastings_bank_wreck.txt | grep -v 1.70141E+038 > raw_data/hbw.txt

# copy the depth corrected raw data text file
#cp ../hanson_wessex_comparison/raw_data/hbw_dc.txt raw_data/

# preprocess the data with blockmean to assign a single value to every point, then grid this data using surface
#blockmean raw_data/hbw_dc.txt -V -I1 $area | surface -Ghbw_dc.grd -V -I1 $area -T0.2

# removing the interpolated data from the grid
#grdmask raw_data/hbw_dc.txt -Ghastings_bank_wreck_mask.grd -I1 $area -N/NaN/1/1 -S1
#grdmath hastings_bank_wreck_mask.grd hbw_dc.grd MUL = hbw_mask.grd

# returning D_FORMAT to no decimal places so that the axes aren't labelled with numbers whose values are 10 decimal places long. 
gmtset D_FORMAT %.0lf

# need to copy the grid file for the wessex archaeology data into this directory. 
#cp ../hanson_wessex_comparison/wessex_arch_mask.grd .

# copy the hanson aggregates marine grid file into this directory
#cp ../hanson_wessex_comparison/hbw_mask.grd .

# using grdmath, the difference between the two datasets will be determined by subtracting one grid from the other.
#grdmath hbw_mask.grd wessex_arch_mask.grd SUB = wessex_hanson_difference.grd

# plot the image
# make a colour palette file
makecpt -Chot -T-1/2/1 -Z -V > difference.cpt

# add a basemap
psbasemap $proj $area -B100:"Eastings":/100:"Northings"::."Bathymetry Difference":WeSn -Xc -Y6.5 -P -K > $outfile

# plot the image using grdimage
grdimage $proj $area -Cdifference.cpt wessex_hanson_difference.grd -O -K >> $outfile

# add a scale to the image
psscale -D5.8/1.4/2/0.2 -B1 -Cdifference.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
pstext $proj2 $area4 -X-1.5 -Y-1.5 -O << TEXT >> $outfile
17.6 10.5 12 0.0 1 1 Difference (m)
TEXT

# view the image
gs -sPAPERSIZE=a4 $outfile
