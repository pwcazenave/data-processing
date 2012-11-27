#! /bin/csh

# script to plot the bathy (be it QINSy or utec) with 4 different illumination angles

set area_processing=-R578117/588284/91508/98686
set area_text=-R0/22/0/30
set area_ill=-R-10/10/-10/10
#set area_plot=-R578106/588290/91506/98686
set area_plot=-R578117/588284/91508/98686
set proj_plot=-JX9/6.4
set proj_text=-JX30/22
set proj_ill=-JX3
set grid_size=10
set outfile=../../images/utec_illumination.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset MEASURE_UNIT cm

#------------------------------------------------------------------------------#

# processing the data

# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first, then use the -I flag in grdimage to show it from a particular angle. appended point of compass is the direction from which the light source shines.
grdgradient -V ../utec$grid_size.grd -A225 -Nt0.7 -Ggrad_south_west.grd
grdgradient -V ../utec$grid_size.grd -A135 -Nt0.7 -Ggrad_south_east.grd
grdgradient -V ../utec$grid_size.grd -A315 -Nt0.7 -Ggrad_north_west.grd
grdgradient -V ../utec$grid_size.grd -A45 -Nt0.7 -Ggrad_north_east.grd

#------------------------------------------------------------------------------#

# plot the images

# plot bottom left image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WeSn -Igrad_north_east.grd -C../utec.cpt ../utec_mask$grid_size.grd -K -X4 -Y2.6 -V > $outfile
# plot bottom right image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wESn -Igrad_north_west.grd -C../utec.cpt ../utec_mask$grid_size.grd -O -K -X12 >> $outfile
# plot top left image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WesN -Igrad_south_east.grd -C../utec.cpt ../utec_mask$grid_size.grd -O -K -X-12 -Y9.4 >> $outfile
# plot top right image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wEsN -Igrad_south_west.grd -C../utec.cpt ../utec_mask$grid_size.grd -O -K -X12 >> $outfile

# add the arrows indicating illumination direction
psxy $proj_ill $area_ill -O -K -G0/0/0 -P -Sv -X-3 -Y-3 << DIR >> $outfile
0 0 45 2
0 0 135 2
0 0 225 2
0 0 315 2
DIR

# add a scale bar
psscale -D0.6/6/5/0.5 -B5 -C../utec/utec.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
psbasemap $proj_text $area_text -B0 -O -K -X-13 -Y-10 >> $outfile
pstext $proj_text $area_text -O << TEXT >> $outfile
9.9 25.7 12 0.0 1 1 Depth (m)
9.8 13 12 0 1 1 Illumination
TEXT

#------------------------------------------------------------------------------#

# view the image
#kghostview $outfile
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile
