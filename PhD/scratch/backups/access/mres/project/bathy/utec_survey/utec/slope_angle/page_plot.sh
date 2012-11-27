#! /bin/csh

# plot the slope angle grid

# set some variables:
set area_processing=-R578117/588284/91508/98686
set area_text=-R0/30/0/22
set proj_plot=-Jx0.0021
set proj_text=-JX30/22
set outfile=../../images/slope_gradient_page.ps

# mask off the interpolated area
#grdmath -V ../mask.grd ../illuminated/grad_south_west.grd MUL = masked_slope.grd

# plot a grid of the surface:
grdimage $area_processing $proj_plot masked_slope.grd -Ba1000f500g500:"Eastings":/a1000f500g500:"Northings":WeSn -C../illuminated/true_grad.cpt -X4 -Yc -K  > $outfile
psscale -D22.5/6/5/0.5 -B1 -Cangle.cpt -O -K >> $outfile
pstext $area_text $proj_text -O << DEGREES >> $outfile
22 9 12 0 1 1 (Gradient) 
DEGREES

# view the image:
gs -sPAPERSIZE=a4 $outfile
