#!/bin/csh

# script to plot the uc65 bathy and illuminate it to see if the yaw errors are still present even if the data have been processed using qinsy.

set area=-R318469/319176/5597470/5598300
set proj=-Jx0.02
set infile=./raw_data/uc65_06-11-09.xyz
set outfile=./images/uc65_bathy_caris.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 12
gmtset COLOR_NAN 0/0/0

## process the data
# increase decimal places to 10
gmtset D_FORMAT %.10lf

# creating a surface
#blockmedian $infile -I0.5 $area | surface -Guc65_bathy_interp.grd -I0.5 $area -T0.4 -V

# removing the interpolated data from the grid
#grdmask $infile -Guc65_mask.grd -I0.5 $area -N/NaN/1/1 -S3
#grdmath uc65_mask.grd uc65_bathy_interp.grd MUL = uc65_bathy.grd

# make an illumination file
#grdgradient uc65_bathy.grd -A250 -Nt0.4 -Guc65_grad.grd

# make a colour palette
makecpt -Crainbow -T36/46/0.1 -Z -I > .uc65.cpt

# return decimals to 0 places
gmtset D_FORMAT %.0lf

## plot the images
# make an image and output to postscript
psbasemap $proj $area -Ba100f50:"Eastings":/a100f50:"Northings"::."UC65 Bathymetry":WeSn -X4.5 -Yc -K -P > $outfile
grdimage $proj $area -Iuc65_grad.grd -C.uc65.cpt uc65_bathy.grd -O -K -P >> $outfile

# display the output
#gs -sPAPERSIZE=a4 $outfile
kghostview $outfile
