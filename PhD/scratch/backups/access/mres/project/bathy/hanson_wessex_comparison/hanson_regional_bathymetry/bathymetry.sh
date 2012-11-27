#! /bin/csh

# just need to plot the damn hanson aggregates marine dataset so i have a bathymetry map of the whole area... how hard can this be?...

# some general variables:
set area=-R329880/331248/5623005/5624369
set area4=-R0/22/0/30
set proj=-JX6.3
set proj2=-JX30c/22c
set outfile=wessex_arch.ps

# process the raw data from the regional scale bathymetry
# use grep to remove lines where there is an incorrect depth value (1.70141E+038)
#more ../raw_data/hastings_bank_wreck.txt | grep -v 1.70141E+038 > raw_data/hbw.txt

# increase the ascii file precision to avoid surface complaining that the data haven't been run through blockmean. 
#gmtset D_FORMAT %.10lf

# preprocess the data with blockmean to assign a single value to every point, then grid this data using surface - to work on data not depth corrected, remove the _dc suffix from hbw.txt (2 occurrences)
#blockmean ../raw_data/hbw_dc.txt -V -I1 $area | surface -Ghbw.grd -V -I1 $area -T0.25

# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first since bedforms are small (~30cm), then use the -I flag in grdimage to show it from a particular angle.
#grdgradient -V hbw.grd -A250 -Nt0.7 -Ghbw_grad.grd

# removing the interpolated data from the grid
#grdmask ../raw_data/hbw_dc.txt -Ghastings_bank_wreck_mask.grd -I1 $area -N/NaN/1/1 -S1
#grdmath hastings_bank_wreck_mask.grd hbw.grd MUL = hbw_mask.grd

# returning D_FORMAT to no decimal places so that the axes aren't labelled with numbers whose values are 10 decimal places long. 
gmtset D_FORMAT %.0lf

# adding the second basemap with labels
psbasemap $proj $area -B200:"Eastings":/200:"Northings"::."Hanson Aggregate Marine Bathymetry":WeSn -Xc -Yc -K > $outfile

# make a colour palette file for grdimage
#makecpt -Cwysiwyg -T-25/-15/1 -Z -V > hbw.cpt

# plot the image
grdimage $proj $area -Ihbw_grad.grd -Chbw.cpt hbw_mask.grd -O -K >> $outfile

# make and plot a contour map of the bathymetry
grdcontour hbw_mask.grd -C1 $proj $area -A2 -S10 -O -K >> $outfile

# add a scale bar
psscale -D7/3.1/2/0.2 -B1 -Chbw.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
pstext -V $proj2 $area4 -O -X0 -Y0 << TEXT >> $outfile
12.9 15 12 0.0 1 1 Depth (m)
TEXT

# view the image
gs -sPAPERSIZE=a4 $outfile


