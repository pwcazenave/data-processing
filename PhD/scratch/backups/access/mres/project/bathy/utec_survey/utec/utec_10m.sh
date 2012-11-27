#! /bin/csh

# script to grid data from the output of the QINSy processing. raw data has been exported into ./raw_data/*.txt.

#set area_processing=-R578117.5/596476.5/91508.5/104445.5
set area_processing=-R578117/588284/91508/98686
set area_text=-R0/22/0/30
set area_plot=-R578117/588284/91508/98686
set proj_plot=-JX5.2/4
set proj_text=-JX22c/30c
set grid_size=10
set outfile=../images/utec_$grid_size.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset MEASURE_UNIT inch

#------------------------------------------------------------------------------#

# data processing of xyz file from utec survey
# increase the ascii file precision to avoid surface complaining that the data haven't been run through blockmean. 
gmtset D_FORMAT %.10lf

# concatenate several files into one, then use awk to generate input file with the correct columns. next preprocess the data with blockmean to assign a single value to every point, and finally grid this data using surface:
# NOTE: GRID INTERVAL IS CURRENTLY SET AS 2 METRES - THIS IS IMPORTANT! it may be that the data look better gridded at 2 metre interval actually...

#cat ../raw_data/0*.txt >! ../raw_data/lines.txt

#blockmedian ../raw_data/lines.txt -V -I2 $area_processing | surface -Gutec.grd -V -I2 $area_processing -T0.3
blockmedian ../raw_data/lines.txt -V -I$grid_size $area_processing > ../raw_data/lines_blockmeaned_$grid_size.txt
surface -Gutec$grid_size.grd -V -I$grid_size $area_processing -T0.25 ../raw_data/lines_blockmeaned_$grid_size.txt

# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first, then use the -I flag in grdimage to show it from a particular angle.
grdgradient -V utec$grid_size.grd -A250 -Nt0.7 -Gutec_grad$grid_size.grd

# removing the interpolated data from the grid
grdmask ../raw_data/lines_blockmeaned_$grid_size.txt -Gmask$grid_size.grd -I$grid_size $area_processing -V -N/NaN/1/1 -S5
grdmath -V mask$grid_size.grd utec$grid_size.grd MUL = utec_mask$grid_size.grd

# returning D_FORMAT to no decimal places so that the axes aren't labelled with numbers whose values are 10 decimal places long. 
gmtset D_FORMAT %.0lf

#------------------------------------------------------------------------------#

# plotting the images
# adding the basemap with labels
psbasemap $proj_plot $area_plot -B1500:"Eastings":/1500:"Northings"::."Hastings Shingle Bank Bathymetry":WeSn -Xc -Y6 -P -K > $outfile

# make a colour palette file for grdimage
makecpt -Cwysiwyg -T-52/-14/1 -Z -V > utec.cpt

# plot the image
grdimage $proj_plot $area_plot -Iutec_grad$grid_size.grd -Cutec.cpt utec_mask$grid_size.grd -O -K >> $outfile
# no illumination:
#grdimage $proj_plot $area_plot -Cutec.cpt utec_mask.grd -O -K >> $outfile
#grdcontour $proj_plot $area_plots utec_mask.grd -A1+um+g255/255/255 -C0.5 -V -O -K >> $outfile

# add a scale bar
psscale -D5.8/2/2/0.2 -B5 -Cutec.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
pstext $proj_text $area_text -O << TEXT >> $outfile
14.2 8.2 12 0.0 1 1 Depth (m)
TEXT

#------------------------------------------------------------------------------#

# clean up
#\rm utec.grd 
#\rm mask.grd 
#\rm lines.txt 
#\rm utec_grad.grd 
#\rm utec_mask.grd

#------------------------------------------------------------------------------#

# view the image
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile
