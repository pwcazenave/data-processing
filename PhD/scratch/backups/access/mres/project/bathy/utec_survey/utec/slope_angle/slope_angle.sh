#! /bin/csh

# script to convert the magnitude of the slope from the output of grdgradient on the utec.grd file, to a slope angle grid.

set area_plot=-R578117/588284/91508/98686
set area_ill=-R-10/10/-10/10
set area_text=-R0/22/0/30
set proj_plot=-JX9/6.4
set proj_ill=-JX3
set proj_text=-JX30/22
set grid_size=2
set outfile=../../images/slope_angle.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

# create a gradient map from the utec 10m grid
grdgradient -V ../utec$grid_size.grd -A225 -Ggrad_south_west.grd
grdgradient -V ../utec$grid_size.grd -A135 -Ggrad_south_east.grd
grdgradient -V ../utec$grid_size.grd -A315 -Ggrad_north_west.grd
grdgradient -V ../utec$grid_size.grd -A45 -Ggrad_north_east.grd

# take the grid file and convert the magnitude of the gradient to radians (since slope = tan(theta), therefore theta = atan(slope)

grdmath -V ../illuminated/grad_south_west.grd ATAN = grad_south_west_radians.grd
grdmath -V ../illuminated/grad_south_east.grd ATAN = grad_south_east_radians.grd
grdmath -V ../illuminated/grad_north_west.grd ATAN = grad_north_west_radians.grd
grdmath -V ../illuminated/grad_north_east.grd ATAN = grad_north_east_radians.grd
                                                                                
# then convert the radians into degrees by multiplying the radians value by 180/pi
grdmath -V grad_south_west_radians.grd 57.29577951 MUL = grad_south_west_degrees.grd
grdmath -V grad_south_west_radians.grd 57.29577951 MUL = grad_south_east_degrees.grd
grdmath -V grad_south_west_radians.grd 57.29577951 MUL = grad_north_west_degrees.grd
grdmath -V grad_south_west_radians.grd 57.29577951 MUL = grad_north_east_degrees.grd

# mask off the interpolated data
grdmath -V ../illuminated/grad_mask2.grd grad_south_west_degrees.grd MUL = grad_s_w_degrees.grd
grdmath -V ../illuminated/grad_mask2.grd grad_south_west_degrees.grd MUL = grad_s_e_degrees.grd
grdmath -V ../illuminated/grad_mask2.grd grad_south_west_degrees.grd MUL = grad_n_w_degrees.grd
grdmath -V ../illuminated/grad_mask2.grd grad_south_west_degrees.grd MUL = grad_n_e_degrees.grd

# using the 1m grid
#grdmath -V ../mask.grd grad_south_west_degrees.grd MUL = grad_s_w_degrees.grd
#grdmath -V ../mask.grd grad_south_west_degrees.grd MUL = grad_s_e_degrees.grd
#grdmath -V ../mask.grd grad_south_west_degrees.grd MUL = grad_n_w_degrees.grd
#grdmath -V ../mask.grd grad_south_west_degrees.grd MUL = grad_n_e_degrees.grd

# then plot it all...

# make colour palette file first
makecpt -Cwysiwyg -T-0.07/0.07/0.01 -V -Z > angle.cpt

# plot bottom left image 
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WeSn grad_s_w_degrees.grd -Cangle.cpt -K -X4 -Y2.6> $outfile 
# plot bottom right image 
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wESn grad_n_w_degrees.grd -Cangle.cpt -O -K -X12 >> $outfile
# plot top left image 
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WesN grad_s_e_degrees.grd -Cangle.cpt -O -K -X-12 -Y9.4 >> $outfile
# plot top right image 
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wEsN grad_s_w_degrees.grd -Cangle.cpt -O -K -X12 >> $outfile

# add the arrows indicating illumination direction
psxy $proj_ill $area_ill -O -K -G0/0/0 -P -Sv -X-3 -Y-3 << DIR >> $outfile
0 0 45 2
0 0 135 2
0 0 225 2
0 0 315 2 
DIR

# add a scale bar
psscale -D0.6/6/5/0.5 -B0.01 -Cangle.cpt -O -K >> $outfile
 
# add labels to the images, and the label to the scale bar using pstext
psbasemap $proj_text $area_text -B0 -O -K -X-13 -Y-10 >> $outfile
pstext $proj_text $area_text -O << TEXT >> $outfile
9.8 25.7 12 0.0 1 1 Slope Angle
9.8 13 12 0 1 1 Illuminated
10.3 12.3 12 0 1 1 from
TEXT

# view the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf $outfile
