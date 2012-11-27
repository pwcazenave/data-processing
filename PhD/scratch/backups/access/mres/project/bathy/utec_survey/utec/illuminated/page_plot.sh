#! /bin/csh

# plot of the slope angle on a single page, to be turned into a GeoTIFF by Justin.

set area_plot=-R578117/588284/91508/98686
#set proj_plot=-Jx0.0022
set proj_plot=-Jx0.01
set area_text=-R0/110/0/90
set proj_text=-JX110/90
set outfile=plot.ps

gmtset LABEL_FONT_SIZE 30
gmtset HEADER_FONT_SIZE 36
gmtset ANNOT_FONT_SIZE_PRIMARY 26
gmtset MEASURE_UNIT cm

# plot the image
grdimage $proj_plot $area_plot -Ba1000f500:"Eastings":/a1000f500:"Northings":WeSn grad_n_w.grd -Ctrue_grad.cpt -K -X10 -Y-57 > $outfile

# add a scale
psscale -D103/35/10/1 -Ba0.02f0.01 -Ctrue_grad.cpt -O -K >> $outfile

# add labels to the images, and the label to the scale bar using pstext
#psbasemap $proj_text $area_text -B0 -O -K -X-33.6 -Y-27 >> $outfile
pstext $proj_text $area_text -O << TEXT >> $outfile
103 41 26 0.0 1 1 Gradient
TEXT

# view the image
gs -sPAPERSIZE=a0 $outfile
