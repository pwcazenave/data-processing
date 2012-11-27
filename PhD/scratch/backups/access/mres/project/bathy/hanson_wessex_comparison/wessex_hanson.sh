#! /bin/csh

# script to grid data from wessex archaeology of the wreck site. raw data has been concatenated from several ascii files into wessex_arch.txt.

# to change the region of the hanson bathymetry plot from the same as the wessex archaeology plot, you have to change  this line in the hanson section to this:
# plot the image
#grdimage $proj $area3 -Ihbw_grad.grd -Cwessex_arch.cpt hbw_mask.grd -O -K >> $outfile

set area=-R330528/331248/5623910/5624294
set area5=-R330528/331195/5623912/5624284
set area2=-R330528/331248/-25/-19
set area3=-R329880/331248/5623005/5624369
set area4=-R0/22/0/30
set proj=-JX5.3/2.9
set proj2=-JX22c/30c
set outfile=wessex_arch.ps

gmtset BASEMAP_TYPE = fancy
gmtset LABEL_FONT_SIZE = 12
gmtset HEADER_FONT_SIZE	= 16p
gmtset ANNOT_FONT_SIZE_PRIMARY 12
gmtset COLOR_NAN = 128/128/128

# data processing of xyz file from wessex archaeology
# increase the ascii file precision to avoid surface complaining that the data haven't been run through blockmean. 
gmtset D_FORMAT %.2lf

# need to use awk to reduce the magnitude of the easting and northing values so that you don't get values like 5.62394e+06 after blockmeaning the data, which I suspect causes surface to reject 90% of the data...
#awk '{print ($1/100),($2/100),$3}' raw_data/wessex_arch.txt >! wessex_arch_div.xyz

# preprocess the data with blockmean to assign a single value to every point, then grid this data using surface
#blockmean raw_data/wessex_arch.txt -V -I1 $area | surface -Gwessex_arch.grd -V -I1 $area -T0.25

# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first since bedforms are small (~30cm), then use the -I flag in grdimage to show it from a particular angle.
#grdgradient -V wessex_arch.grd -A250 -Nt0.7 -Gwessex_arch_grad.grd

# removing the interpolated data from the grid
#grdmask raw_data/wessex_arch.txt -Gwa_mask.grd -I1 $area -N/NaN/1/1 -S1
#grdmath wa_mask.grd wessex_arch.grd MUL = wessex_arch_mask.grd

# returning D_FORMAT to no decimal places so that the axes aren't labelled with numbers whose values are 10 decimal places long. 
gmtset D_FORMAT %.0lf

# adding the basemap with labels
psbasemap $proj $area -B100:"Eastings":/100:"Northings"::."Wessex Archaeology Group Bathymetry":WeSn -Xc -Y6.5 -P -K > $outfile

# make a colour palette file for grdimage
makecpt -Cwysiwyg -T-26/-18/1 -Z -V > wessex_arch.cpt

# plot the image
grdimage $proj $area5 -Iwessex_arch_grad.grd -Cwessex_arch.cpt wessex_arch_mask.grd -O -K >> $outfile
#grdcontour $proj $area5 wessex_arch_mask.grd -A1+um+g255/255/255 -C0.5 -V -O -K >> $outfile

# add a scale bar
psscale -D5.8/1.4/2/0.2 -B1 -Cwessex_arch.cpt -O -K >> $outfile


# process the raw data from the regional scale bathymetry
# use grep to remove lines where there is an incorrect depth value (1.70141E+038)
#grep -v 1.70141E+038 raw_data/hastings_bank_wreck.txt > raw_data/hbw.txt

# attempting to "normalise" the data for the hanson survey to the data from the wessex survey. The hanson survey was done when the tide was out, and therefore all the depths are smaller. By determining what the smallest depth value was around the wreck i.e. the highest point on the seabed, it may be possible to account for the general difference in depth. I am assuming that the depth of the wreck has not changed from one survey to another. The value used is the median of the top 15 shallowest depths in the area. 
#awk '{print $1, $2, ($3+(-1.9639412133))}' raw_data/hbw.txt > raw_data/hbw_dc.txt

# increase the ascii file precision to avoid surface complaining that the data haven't been run through blockmean. 
gmtset D_FORMAT %.2lf

# preprocess the data with blockmean to assign a single value to every point, then grid this data using surface - to work on data not depth corrected, remove the _dc suffix from hbw.txt (2 occurrences)
#blockmean raw_data/hbw_dc.txt -V -I1 $area3 | surface -Ghbw.grd -V -I1 $area3 -T0.25

# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first since bedforms are small (~30cm), then use the -I flag in grdimage to show it from a particular angle.
#grdgradient -V hbw.grd -A250 -Nt0.7 -Ghbw_grad.grd

# removing the interpolated data from the grid
#grdmask raw_data/hbw_dc.txt -Ghastings_bank_wreck_mask.grd -I1 $area3 -N/NaN/1/1 -S1
#grdmath hastings_bank_wreck_mask.grd hbw.grd MUL = hbw_mask.grd

# returning D_FORMAT to no decimal places so that the axes aren't labelled with numbers whose values are 10 decimal places long. 
gmtset D_FORMAT %.0lf

# adding the second basemap with labels
psbasemap $proj $area -B100:"Eastings":/100:"Northings"::."Hanson Aggregate Marine Bathymetry":WeSn -Y-5 -P -O -K >> $outfile

# make a colour palette file for grdimage
makecpt -Cwysiwyg -T-25/-15/1 -Z -V > hbw.cpt

# plot the image
grdimage $proj $area5 -Ihbw_grad.grd -Cwessex_arch.cpt hbw_mask.grd -O -K >> $outfile

# add a scale bar
psscale -D5.8/1.4/2/0.2 -B1 -Cwessex_arch.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
pstext $proj2 $area4 -X-1.5 -Y-1.5 -O << TEXT >> $outfile
#0 26 10 0.0 1 1 A
#0 13 10 0.0 1 1 B
18.1 10.5 12 0.0 1 1 Depth (m)
18.1 23.2 12 0.0 1 1 Depth (m)
TEXT

# view the image
gs -sPAPERSIZE=a4 $outfile
