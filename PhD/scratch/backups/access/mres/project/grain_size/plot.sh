#! /bin/bash

# plot the grain size data over the bathy data using circles of different size as representative of the grain size. also colour code the circles to indicate fine, medium and coarse if possible

area_plot=-R578117/588284/91508/98686
proj_plot=-JX21.4/14.6
area_text=-R0/30/0/22
proj_text=-JX30c/22c
outfile=distribution.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 14

# get the background done
# plot a basemap
#psbasemap $proj_plot $area_plot -Xc -Yc -K -B0 > $outfile

# bathy image
grdimage $proj_plot $area_plot -I../bathy/utec_survey/utec/utec_grad.grd -C../bathy/utec_survey/utec/utec.cpt ../bathy/utec_survey/utec/utec_mask.grd -K > $outfile

# adornments
psscale -D22/6/5/0.5 -B5 -C../bathy/utec_survey/utec/utec.cpt -O -K >> $outfile
pstext $proj_text $area_text -O -K << TEXT >> $outfile
22 9 12 0.0 1 1 Depth (m)
TEXT

# process the grain size data
psxy $proj_plot $area_plot data.txt -O -K -Sc -W5 >> $outfile
psxy $proj_plot $area_plot data.txt -O -K -Sc0.1 -W12 >> $outfile

# add a grain size scale
psxy $proj_text $area_text -O -K -Sc -W5 << SCALE_CIRC >> $outfile
19.25 2 1
SCALE_CIRC
psxy $proj_text $area_text -O -K -Sc0.1 -W12 << SCALE_DOT >> $outfile
19.25 2
SCALE_DOT
pstext $proj_text $area_text -O -K -V << SCALE_TEXT >> $outfile
19.85 1.95 8 0.0 1 1 = 1 cm
SCALE_TEXT

# view the image
echo -n "convert output to jpeg... "
gs -sDEVICE=jpeg -r200 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
-sOutputFile=${outfile%.ps}.jpg $outfile > /dev/null
echo -n "and pdf... "
ps2pdf -sPAPERSIZE=a4 $outfile ${outfile%.ps}.pdf > /dev/null
echo "done."
                     
gs -sPAPERSIZE=a4 $outfile
