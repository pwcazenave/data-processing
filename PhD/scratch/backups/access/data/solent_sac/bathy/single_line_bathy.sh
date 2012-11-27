#! /bin/csh

# script to plot the single line bathymetry from the channel coastal observatory data repository.

#-----------------------------------------------------------------------------#

# set up the .gmtdefaults file

gmtset LABEL_FONT_SIZE 12p
gmtset HEADER_FONT_SIZE 16p
gmtset ANNOT_FONT_SIZE 10p

#------------------------------------------------------------------------------#

set west_area=-R428761/454124/84040/100651
set west_area_plot=-R428761/449803/84040/97770
set east_area=-R448377/484956/86430/105427
set north_area=-R428761/449804/84040/97771
set area_plot=-R429613/467032/84830.6/110152
set proj=-JX23/7
set outfile=./images/solent_bathy.ps

set west=raw_data/cco/cco_data-20060629170734/data/hydrographic/
set east=raw_data/cco/cco_data-20060629171021/data/hydrographic/
set north=raw_data/cco/cco_data-20060629171431/data/hydrographic/

set iow_area=-R433489/458648/89693/97770
set iow=raw_data/iow_cco_data-20060630173449/data/hydrographic/

#------------------------------------------------------------------------------#

# data processing:

# increase the ascii file precision to avoid surface complaining that the data haven't been run through blockmean.
gmtset D_FORMAT %.10lf

# need to cat all the files together to blockmean the data and then create a surface.

#cat raw_data/old_raw_data/iow_cco_data-20060630173449/data/hydrographic/*.txt | grep -v O | awk '{print $1,$2,$3}' > /tmp/iow_bathy.xyz
#cat $west*.txt | grep -v O | awk '{print $1, $2, $3}' > /tmp/west_cco_bathy.txt
#cat $east*.txt | grep -v O | awk '{print $1, $2, $3}' > /tmp/east_cco_bathy.txt
#cat $north*.txt | grep -v O | awk '{print $1, $2, $3}' > /tmp/north_cco_bathy.txt

blockmean /tmp/iow_bathy.xyz -V -I5 $iow_area | surface -Giow_surface.grd -V -I5 $iow_area -T0.3
#blockmean /tmp/west_cco_bathy.txt -V -I5 $west_area | surface -Gwest_surface.grd -V -I5 $west_area -T0.2
#blockmean /tmp/east_cco_bathy.txt -V -I5 $east_area | surface -Geast_surface.grd -V -I5 $east_area -T0.2
#blockmean /tmp/north_cco_bathy.txt -V -I5 $north_area | surface -Gnorth_surface.grd -V -I5 $north_area -T0.2

# trying with removal of interpolated data from the grid - this is likely to remove vast tracts of the data since this is generally only single beam bathy... let's see what it's like first...
grdmask /tmp/iow_bathy.xyz -Giow_mask.grd -I5 $iow_area -V -N/NaN/1/1 -S50
#grdmask /tmp/west_cco_bathy.txt -Gwest_cco_mask.grd -I5 $west_area -V -N/NaN/1/1 -S40
#grdmask /tmp/east_cco_bathy.txt -Geast_cco_mask.grd -I5 $east_area -V -N/NaN/1/1 -S2
#grdmask /tmp/north_cco_bathy.txt -Gnorth_cco_mask.grd -I5 $north_area -V -N/NaN/1/1 -S2

grdmath -V iow_mask.grd iow_surface.grd MUL = iow.grd
#grdmath -V west_cco_mask.grd west_surface.grd MUL = west_cco_data.grd
#grdmath -V east_cco_mask.grd east_surface.grd MUL = east_cco_data.grd
#grdmath -V north_cco_mask.grd north_surface.grd MUL = north_cco_data.grd

# returning D_FORMAT to no decimal places so that the axes aren't labelled with numbers whose values are 10 decimal places long.
gmtset D_FORMAT %.0lf

# clean up
#\rm /tmp/*_cco_bathy.txt
#\rm *_cco_mask.grd

#------------------------------------------------------------------------------#

# plot the data:
# make a colour palette file:
makecpt -Cwysiwyg -T-62/2/1 -Z -V > cco.cpt

# generate a basemap
psbasemap $proj $iow_area -Ba1000f500:"Eastings":/a1000f500:"Northings"::."Single Beam Bathymetry":WeSn -Xc -Yc -K > $outfile

# add the gridded data
grdimage $proj $iow_area -Ccco.cpt iow.grd -Bg500 -O -K >> $outfile

# trying pscoast for the isle of wight... this could be terrible...
#psxy iow_coastline.txt $proj $iow_area -G100/200/50 -O -K -W -V >> $outfile

# to plot the coastline in eastings and northings, need to use the -M flag - don't quite know how yet though...
#pscoast -Ju31/1:1000 -R433489/458648/89693/97770 -M -Df -W
#pscoast $proj $west_area_plot -B4000 -Df -O -K -P -G0/255/0 -W1/0/255/0 >> $outfile
#pscoast $proj $iow_area -Df -G30/200/10 -W1 -O -K -V >> $outfile

# add a scale:
psscale -D20/10/5/0.2 -B10 -Ccco.cpt -O >> $outfile

#------------------------------------------------------------------------------#

# view the image
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile

