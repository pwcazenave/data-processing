#! /bin/csh -f

# script to produce an a0 plot of both the 50cm grid and 1m gridded hastings
# subsets

# dredging subset
set area_plot=-R580000/584000/95000/98000
# four corners
set sw_area=-R578106/583198.5/91503/95095.5
set se_area=-R583198.5/588291/91503/95095.5
set nw_area=-R578106/583198.5/95095.5/98688
set ne_area=-R583198.5/588291/95095.5/98688
# decorations
set area_text=-R0/118/0/84
set proj_plot=-Jx0.02
set proj_dredge=-Jx0.025
set proj_text=-JX118/84
# outfiles
set outfile=./images/geotiffs/a0_hastings_dredge.ps
set sw_outfile=./images/geotiffs/a0_hastings_sw.ps
set se_outfile=./images/geotiffs/a0_hastings_se.ps
set nw_outfile=./images/geotiffs/a0_hastings_nw.ps
set ne_outfile=./images/geotiffs/a0_hastings_ne.ps

# make it look pretty
gmtset LABEL_FONT_SIZE 30
gmtset HEADER_FONT_SIZE 36
gmtset ANNOT_FONT_SIZE_PRIMARY 26
gmtset MEASURE_UNIT cm
gmtset PAPER_MEDIA a0+
gmtset D_FORMAT %6.0f

# make a colour palette file for all the grdimages
echo -n "colour palette... "
makecpt -Crainbow -T-53/-13/1 -Z > 50cm_utec.cpt
echo "done."

# dredge
echo -n "dredge... "
psbasemap $proj_dredge $area_plot \
   -B0 -K -Xc -Yc > $outfile
grdimage $proj_dredge $area_plot -I./50cm_bathy_grad.grd -C50cm_utec.cpt \
   -B0 50cm_bathy_final.grd -O -K >> $outfile
# sw
echo -n "sw plot... "
psbasemap $proj_plot $sw_area \
   -B0 -K -Xc -Yc > $sw_outfile
grdimage $proj_plot $sw_area -I./50cm_bathy_grad.grd -C50cm_utec.cpt \
   -B0 50cm_bathy_final.grd -O -K >> $sw_outfile
 se
#echo -n "se plot... "
psbasemap $proj_plot $se_area \
   -B0 -K -Xc -Yc > $se_outfile
grdimage $proj_plot $se_area -I./50cm_bathy_grad.grd -C50cm_utec.cpt \
   -B0 50cm_bathy_final.grd -O -K >> $se_outfile
 nw
#echo -n "nw plot... "
psbasemap $proj_plot $nw_area \
   -B0 -K -Xc -Yc > $nw_outfile
grdimage $proj_plot $nw_area -I./50cm_bathy_grad.grd -C50cm_utec.cpt \
   -B0 50cm_bathy_final.grd -O -K >> $nw_outfile
# ne
echo -n "ne plot... "
psbasemap $proj_plot $ne_area \
   -B0 -K -Xc -Yc > $ne_outfile
grdimage $proj_plot $ne_area -I./50cm_bathy_grad.grd -C50cm_utec.cpt \
   -B0 50cm_bathy_final.grd -O -K >> $ne_outfile
echo "done."

# add a scale bar
echo -n "scale bars... "
psscale -D104/36/15/1 -B2 -Cutec.cpt -O -K >> $outfile
psscale -D105/36/15/1 -B2 -Cutec.cpt -O -K >> $sw_outfile
psscale -D105/36/15/1 -B2 -Cutec.cpt -O -K >> $se_outfile
psscale -D105/36/15/1 -B2 -Cutec.cpt -O -K >> $nw_outfile
psscale -D105/36/15/1 -B2 -Cutec.cpt -O -K >> $ne_outfile
echo "done."

# add labels to the images, and the label to the scale bar using pstext
echo -n "labelling... "
pstext $proj_text $area_text -O -K << TEXT >> $outfile
103.9 46 24 0.0 0 1 Depth (m)
TEXT
pstext $proj_text $area_text -O -K << TEXT >> $sw_outfile
104.9 46 24 0.0 0 1 Depth (m)
TEXT
pstext $proj_text $area_text -O -K << TEXT >> $se_outfile
104.9 46 24 0.0 0 1 Depth (m)
TEXT
pstext $proj_text $area_text -O -K << TEXT >> $nw_outfile
104.9 46 24 0.0 0 1 Depth (m)
TEXT
pstext $proj_text $area_text -O -K << TEXT >> $ne_outfile
104.9 46 24 0.0 0 1 Depth (m)
TEXT
echo "done."

# view the image
echo -n "display and convert to: pdf "
ps2pdf -sPAPERSIZE=a0 -dBATCH -dNOPAUSE $outfile \
   ./images/geotiffs/`basename $outfile .ps`.pdf > /dev/null
ps2pdf -sPAPERSIZE=a0 -dBATCH -dNOPAUSE $sw_outfile \
   ./images/geotiffs/`basename $sw_outfile .ps`.pdf > /dev/null
ps2pdf -sPAPERSIZE=a0 -dBATCH -dNOPAUSE $se_outfile \
   ./images/geotiffs/`basename $se_outfile .ps`.pdf > /dev/null
ps2pdf -sPAPERSIZE=a0 -dBATCH -dNOPAUSE $nw_outfile \
   ./images/geotiffs/`basename $nw_outfile .ps`.pdf > /dev/null
ps2pdf -sPAPERSIZE=a0 -dBATCH -dNOPAUSE $ne_outfile \
   ./images/geotiffs/`basename $ne_outfile .ps`.pdf > /dev/null
#echo -n "and jpeg... "
#gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
#   -sOutputFile=./images/geotiffs/`basename $outfile .ps`.jpg \
#   $outfile
#gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
#   -sOutputFile=./images/geotiffs/`basename $sw_outfile .ps`.jpg \
#   $sw_outfile
#gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
#   -sOutputFile=./images/geotiffs/`basename $se_outfile .ps`.jpg \
#   $se_outfile
#gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
#   -sOutputFile=./images/geotiffs/`basename $nw_outfile .ps`.jpg \
#   $nw_outfile
#gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
#   -sOutputFile=./images/geotiffs/`basename $ne_outfile .ps`.jpg \
#   $ne_outfile
echo "done."
#gs -sPAPERSIZE=a0 $outfile > /dev/null
