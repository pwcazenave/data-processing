#! /bin/csh -f

# script to produce an a0 plot of both the 50cm grid and 1m gridded hastings
# subsets

set area_plot=-R580000/583500/95000/97500
set area_text=-R0/84/0/118
set proj_plot=-Jx0.02
set proj_text=-JX84/118
set outfile=./images/a0.ps

gmtset LABEL_FONT_SIZE 30
gmtset HEADER_FONT_SIZE 36
gmtset ANNOT_FONT_SIZE_PRIMARY 26
gmtset MEASURE_UNIT cm

gmtset D_FORMAT %6.0f

# make a colour palette file for grdimage
echo -n "colour palette... "
makecpt -Cwysiwyg -T-29/-14/1 -Z > utec.cpt
echo "done."

# 25cm original
echo -n "50cm grid image... "
grdimage $proj_plot $area_plot -I./dredge_grad.grd -Cutec.cpt \
   -Ba500f100g500:"Eastings":/a500f100g500:"Northings"::."Hastings Shingle Bank Bathymetry Subset":WeSn \
   dredge_final.grd -K -P -X5 -Y64 > $outfile
echo "done."

# 1m resampled
echo -n "1m resampled grid image... "
grdimage $proj_plot $area_plot -I./dredge_grad_resampled_1m.grd -Cutec.cpt \
   -Ba500f100g500:"Eastings":/a500f100g500:"Northings"::."Hastings Shingle Bank Bathymetry Subset":WeSn\
   dredge_final_resampled_1m.grd -O -K -Y-60 >> $outfile
echo "done."

# add a scale bar
echo -n "scale bars... "
psscale -D72/25/15/1 -B2 -Cutec.cpt -O -K >> $outfile
psscale -D72/85/15/1 -B2 -Cutec.cpt -O -K >> $outfile
echo "done."

# add labels to the images, and the label to the scale bar using pstext
echo -n "labelling... "
pstext $proj_text $area_text -O -K << TEXT >> $outfile
71.9 34 24 0.0 0 1 Depth (m)
TEXT
pstext $proj_text $area_text -O << TEXT >> $outfile
71.9 94 24 0.0 0 1 Depth (m)
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
