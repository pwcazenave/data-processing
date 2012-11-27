#! /bin/csh -f

# script to produce an a0 plot of both the 50cm grid and 1m gridded hastings
# subsets

set area_plot=-R578106/588291/91503/98688
set area_text=-R0/118/0/84
set proj_plot=-Jx0.01
set proj_text=-JX118/84
set outfile=./images/a0_bathy.ps

gmtset LABEL_FONT_SIZE 30
gmtset HEADER_FONT_SIZE 36
gmtset ANNOT_FONT_SIZE_PRIMARY 26
gmtset MEASURE_UNIT cm
gmtset PAPER_MEDIA a0+
gmtset D_FORMAT %6.0f

# make a colour palette file for grdimage
echo -n "colour palette... "
makecpt -Crainbow -T-53/-13/1 -Z > 50cm_utec.cpt
echo "done."

# 25cm original
echo -n "50cm grid image... "
psbasemap $proj_plot $area_plot \
   -B0 -K -Xc -Yc > $outfile
grdimage $proj_plot $area_plot -I./50cm_bathy_grad.grd -C50cm_utec.cpt \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Hastings Shingle Bank Bathymetry Subset":WeSn \
   50cm_bathy_final.grd -O -K >> $outfile
echo "done."

# add a scale bar
echo -n "scale bars... "
psscale -D105/36/15/1 -B2 -Cutec.cpt -O -K >> $outfile
echo "done."

# add labels to the images, and the label to the scale bar using pstext
echo -n "labelling... "
pstext $proj_text $area_text -O -K << TEXT >> $outfile
104.9 46 24 0.0 0 1 Depth (m)
TEXT
echo "done."

# view the image
echo -n "display and convert to: pdf "
ps2pdf -sPAPERSIZE=a0 -dBATCH -dNOPAUSE $outfile \
   ./images/`basename $outfile .ps`.pdf > /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/`basename $outfile .ps`.jpg \
   $outfile > /dev/null
echo "done."
gs -sPAPERSIZE=a0 $outfile > /dev/null
