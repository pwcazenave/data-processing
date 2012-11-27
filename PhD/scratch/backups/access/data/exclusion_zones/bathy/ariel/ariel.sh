#!/bin/csh

# script to plot the ariel bathy and illuminate it to see if the yaw errors are still present even if the data have been processed using qinsy.

#set area=-R682480/683300/5613666/5614271
set area=-R258350/259135/5616067/5616640
set proj=-Jx0.028
#set infile=./raw_data/ariel_003.pts
set infile=./raw_data/ariel_06-11-09.xyz
#set outfile=./images/ariel_bathy.ps
set outfile=./images/ariel_bathy_caris.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 12
gmtset COLOR_NAN 0/0/0

## process the data
# increase decimal places to 10
gmtset D_FORMAT %.10lf

# creating a surface
blockmedian $infile -I0.5 $area | surface -Gariel_bathy_interp.grd -I0.5 $area -T0.3 -V

# removing the interpolated data from the grid
grdmask $infile -Gariel_mask.grd -I0.5 $area -N/NaN/1/1 -S3
grdmath ariel_mask.grd ariel_bathy_interp.grd MUL = ariel_bathy.grd

# make an illumination file
grdgradient ariel_bathy.grd -A250 -Nt0.4 -Gariel_grad.grd

# make a colour palette
makecpt -Cwysiwyg -T22/36/1 -Z -I > ariel.cpt

# return decimals to 0 places
gmtset D_FORMAT %.0lf

## plot the images
# make an image and output to postscript
psbasemap $proj $area -Ba100f50:"Eastings":/a100f50:"Northings"::."Ariel Bathymetry":WeSn -X4.5 -Yc -K > $outfile
grdimage $proj $area -Iariel_grad.grd -Cariel.cpt ariel_bathy.grd -O -K >> $outfile

# display the output
gs -sPAPERSIZE=a4 $outfile
