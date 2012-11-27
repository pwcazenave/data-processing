#! /bin/csh

# script to plot the bathy (be it QINSy or utec) with 4 different illumination angles

set area_processing=-R578117/588284/91508/98686
set area_text=-R0/22/0/30
set area_ill=-R-10/20/-10/20
set area_plot=-R578117/588284/91508/98686
set proj_plot=-Jx0.0033
set proj_text=-JX90/64
set proj_ill=-Jx0.35
set grid_size=2
set outfile=../../images/utec_gradient_a1.ps

gmtset LABEL_FONT_SIZE 30
gmtset HEADER_FONT_SIZE 36 
gmtset ANNOT_FONT_SIZE_PRIMARY 26
gmtset MEASURE_UNIT cm 

#------------------------------------------------------------------------------#
                                                                                                   
# processing the data
                                                                                                   
# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first, then use the -I flag in grdimage to show it from a particular angle. appended point of compass is the direction from which the light source shines.
                                                                                                   
# without normalisation (doesn't look good, but is accurate)
#grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5

grdgradient -V ../utec.grd -A225 -Ggrad_south_west_g.grd
grdmath -V grad_mask$grid_size.grd grad_south_west_g.grd MUL = grad_s_w.grd
grdgradient -V ../utec.grd -A135 -Ggrad_south_east_g.grd
grdmath -V grad_mask$grid_size.grd grad_south_east_g.grd MUL = grad_s_e.grd
grdgradient -V ../utec.grd -A315 -Ggrad_north_west_g.grd
grdmath -V grad_mask$grid_size.grd grad_north_west_g.grd MUL = grad_n_w.grd
grdgradient -V ../utec.grd -A45 -Ggrad_north_east_g.grd
grdmath -V grad_mask$grid_size.grd grad_north_east_g.grd MUL = grad_n_e.grd

#------------------------------------------------------------------------------#

# plot the images

# make a colour palette
makecpt -Cwysiwyg -T-0.07/0.07/0.0001 -Z -V > true_grad.cpt

# plot bottom left image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WeSn grad_n_e.grd -Ctrue_grad.cpt -K -X7 -Y-33.5 -V > $outfile
# plot bottom right image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wESn grad_n_w.grd -Ctrue_grad.cpt -O -K -X36.5 >> $outfile
# plot top left image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WesN grad_s_e.grd -Ctrue_grad.cpt -O -K -X-36.5 -Y26.5 >> $outfile
# plot top right image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wEsN grad_s_w.grd -Ctrue_grad.cpt -O -K -X36.5 >> $outfile

# add the arrows indicating illumination direction
psxy $proj_ill $area_ill -O -K -G0/0/0 -P -Sv -X-10 -Y-5 << DIR >> $outfile
14.3 0.2 45 2
14.3 0.2 135 2
14.3 0.2 225 2
14.3 0.2 315 2
DIR

gmtset ANNOT_FONT_SIZE_PRIMARY 14

# add a scale bar
psscale -D7.3/16.2/5/0.5 -Ba0.02f0.01 -Ctrue_grad.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
psbasemap $proj_text $area_text -B0 -O -K -X-33.6 -Y-27 >> $outfile
pstext $proj_text $area_text -O << TEXT >> $outfile
9.97 21.65 16 0.0 1 1 Gradient
9.97 15.3 14 0 1 1 Illumination
TEXT

#------------------------------------------------------------------------------#

# view the image
#kghostview $outfile
gs -sPAPERSIZE=a1 $outfile
#ps2pdf $outfile
