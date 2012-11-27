#! /bin/csh

# script to plot the bathy (be it QINSy or utec) with 4 different illumination angles

#set area_processing=-R578106/588290/91506/98686
set area_processing=-R578117/588284/91508/98686
set area_text=-R0/22/0/30
set area_ill=-R-10/10/-10/10
#set area_plot=-R578106/588290/91506/98686
set area_plot=-R578117/588284/91508/98686
set proj_plot=-JX9/6.4
set proj_text=-JX30/22
set proj_ill=-JX3
set grid_size=10
set outfile=../../images/utec_gradient.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 12
gmtset MEASURE_UNIT cm

#------------------------------------------------------------------------------#

# processing the data

# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first, then use the -I flag in grdimage to show it from a particular angle. appended point of compass is the direction from which the light source shines.

# without normalisation (doesn't look good, but is accurate)
grdgradient -V ../utec10.grd -A225 -Ggrad_south_west.grd
grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
grdmath -V grad_mask$grid_size.grd grad_south_west.grd MUL = grad_s_w.grd
grdgradient -V ../utec10.grd -A135 -Ggrad_south_east.grd
grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
grdmath -V grad_mask$grid_size.grd grad_south_east.grd MUL = grad_s_e.grd
grdgradient -V ../utec10.grd -A315 -Ggrad_north_west.grd
grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
grdmath -V grad_mask$grid_size.grd grad_north_west.grd MUL = grad_n_w.grd
grdgradient -V ../utec10.grd -A45 -Ggrad_north_east.grd
grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
grdmath -V grad_mask$grid_size.grd grad_north_east.grd MUL = grad_n_e.grd

# with normalisation to 0.7
#grdgradient -V ../utec10.grd -A225 -Nt0.7 -Ggrad_south_west.grd
#grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
#grdmath -V grad_mask$grid_size.grd grad_south_west.grd MUL = grad_s_w.grd
#grdgradient -V ../utec10.grd -A135 -Nt0.7 -Ggrad_south_east.grd
#grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
#grdmath -V grad_mask$grid_size.grd grad_south_east.grd MUL = grad_s_e.grd
#grdgradient -V ../utec10.grd -A315 -Nt0.7 -Ggrad_north_west.grd
#grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
#grdmath -V grad_mask$grid_size.grd grad_north_west.grd MUL = grad_n_w.grd
#grdgradient -V ../utec10.grd -A45 -Nt0.7 -Ggrad_north_east.grd
#grdmask ../../raw_data/lines_blockmeaned.txt -Ggrad_mask$grid_size.grd -I$grid_size $area_plot -V -N/NaN/1/1 -S5
#grdmath -V grad_mask$grid_size.grd grad_north_east.grd MUL = grad_n_e.grd

#------------------------------------------------------------------------------#

# plot the images

# make a colour palette
makecpt -Cwysiwyg -T-0.07/0.07/0.0001 -Z -V > true_grad.cpt

# plot bottom left image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WeSn grad_n_e.grd -Ctrue_grad.cpt -K -X4 -Y2.6 > $outfile
# plot bottom right image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wESn grad_n_w.grd -Ctrue_grad.cpt -O -K -X12 >> $outfile
# plot top left image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":WesN grad_s_e.grd -Ctrue_grad.cpt -O -K -X-12 -Y9.4 >> $outfile
# plot top right image
grdimage $proj_plot $area_plot -B2000:"Eastings":/2000:"Northings":wEsN grad_s_w.grd -Ctrue_grad.cpt -O -K -X12 >> $outfile

# add the arrows indicating illumination direction
psxy $proj_ill $area_ill -O -K -G0/0/0 -P -Sv -X-3 -Y-3 << DIR >> $outfile
0 0 45 2
0 0 135 2
0 0 225 2
0 0 315 2
DIR

# add a scale bar
psscale -D0.5/6/5/0.5 -Ba0.02 -Ctrue_grad.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
psbasemap $proj_text $area_text -B0 -O -K -X-13 -Y-10 >> $outfile
pstext $proj_text $area_text -O << TEXT >> $outfile
10 25.7 12 0.0 1 1 Gradient
9.8 13 12 0 1 1 Illumination
TEXT

#------------------------------------------------------------------------------#

# view the image
#kghostview $outfile
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile
