#! /bin/csh

# plot the gradient of the bathymetry data from the 10m grid

set area_plot=-R578117/588284/91508/98686
set area_text=-R0/29.7/0/21.0
set proj_plot=-JX21.4/14.6
set proj_text=-JX30/22
set outfile=../images/gradient_map.ps
set grid_size=10

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 14

#---------------------------------------------------------------------------#

# remove the interpolated data from the grid
#grdmask ../raw_data/lines_blockmeaned_$grid_size.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
#grdmath -V grad_mask$grid_size.grd utec_grad$grid_size.grd MUL = grad$grid_size.grd

#---------------------------------------------------------------------------#

# plot the grdgradient output

# increase decimal places to 1
gmtset D_FORMAT %.1f

# make the colout palette file
makecpt -Cwysiwyg -T-0.7/0.7/0.1 -Z > grad.cpt

# place a basemap down to centre the image
psbasemap $area_plot $proj_plot -B0wesn -K -Xc -Yc > $outfile

# plot the data
grdimage $area_plot $proj_plot grad$grid_size.grd -Cgrad.cpt -B0 -O -K >> $outfile

# plot the scalebar with 1 decimal place
psscale -D22.2/6/5/0.5 -B0.2 -Cgrad.cpt -O -K -V >> $outfile

# add a text label for the scale
pstext $proj_text $area_text -O -K -V << TEXT >> $outfile
21.95 8.6 12 0.0 1 1 Gradient
TEXT

# return decimal places to zero
gmtset D_FORMAT %.0f

# add labelled axes
psbasemap $area_plot $proj_plot -Ba1000f500g500:"Eastings":/a1000f500g500:"Northings"::."Gradient map of the Hastings Shingle Bank":WeSn -O >> $outfile

#---------------------------------------------------------------------------#

# view the image
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile
