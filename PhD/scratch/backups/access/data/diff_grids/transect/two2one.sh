#!/bin/bash

# script to check the differences in depth being generated during the regridding
# from 2 to 1 minutes of the ETOPO bathy grid.

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F
gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 10

area=-R-10/5/47.5/52.5
proj=-Jm1

twomin=../../etopo/etopo_bathy.grd
onemin=../../etopo/etopo_bathy_resampled_1min.grd
outfile=../images/two2one_conversion_transect.ps

# make a transect (fairly long)
echo -n "making the profile... "
project -C-6.5/49.3 -E1/50.5 -G1 -Q > ./long_transect_onemin.trk
project -C-6.5/49.3 -E1/50.5 -G2 -Q > ./long_transect_twomin.trk
echo "done."

# get the values from the grid
echo -n "take the depth values from the grids... 1 "
grdtrack ./long_transect_onemin.trk -G$onemin -S > ./long_transect_onemin.pfl
echo -n "2 "
grdtrack ./long_transect_twomin.trk -G$twomin -S > ./long_transect_twomin.pfl
echo "done."

# plot the profiles
echo -n "plot the profiles... "
p_area=$(awk '{print $3, $4}' ./long_transect_onemin.pfl | minmax -I2)
p_proj=-JX15c/9c

awk '{print $3, $4}' ./long_transect_onemin.pfl | psxy $p_area $p_proj -Ba100f50g100:"Distance along line (km)":/a20f10:"Depth (m)"::."Profile through the English Channel with Error":WSn -K -Xc -Y18 -W3/50/50/200 -P > $outfile
awk '{print $3, $4}' ./long_transect_twomin.pfl | psxy $p_area $p_proj -B0 -O -K -W3/50/200/50 >> $outfile
# add in the mike mesh output profile
echo -n "adding dave's... "
awk '{print $1, $2}' ./MIKE_transect.txt | psxy $p_area $p_proj -B0 -O -K -W3/0/0/0 >> $outfile
echo "done."

# add in the error using a subsampled version of the 1 minute profile
echo -n "calculating errors... "
sed -n '1~2p' ./long_transect_onemin.pfl | awk '{print $3, $4}' > sub1.pfl
echo -n "formatting... "
awk '{print $3, $4}' ./long_transect_twomin.pfl > sub2.pfl
paste sub1.pfl sub2.pfl | awk '{print $1, $2-$4}' > error.pfl
d_area=$(minmax ./error.pfl -I0.2)
echo -n "plotting... "
psxy $d_area $p_proj -O -K -B0/a0.1f0.05E -W3/200/50/50 error.pfl >> $outfile
# add in a red axis label
pstext -N -O -K $p_area $p_proj -G200/50/50 << RED_LABEL >> $outfile
625 -99 12 90 0 1 Difference in depth values (m)
RED_LABEL
echo "done."

# plot the profiles on a map
echo -n "add the location... "
grdimage $area $proj -Ba1f0.5g1:."Profile Location":WeSn -O -K -C../../etopo/shelf.cpt ../../gebco/gebco_bathy.grd -Y-13 -I../../gebco/gebco_grad.grd >> $outfile
# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile
# add the profiles
psxy ./long_transect_onemin.trk $area $proj -W3/0/0/0 -B0 -O -K >> $outfile
echo "done."

# add a scale bar
echo -n "add a scale bar... "
psscale -D7.5/-1.6/13/0.5h -P -C../../etopo/shelf.cpt -O -K -B20:"Depth (m)": >> $outfile
echo "done."
# add in the key
echo -n "add the labels... "
page=-R0/23/0/33
a4=-JX23c/33c
psxy $page $a4 -X-3.1 -Y-5 -O -K -B0 -W3/50/50/200 << BLUE >> $outfile
3 15.4
3.5 15.4
BLUE
psxy $page $a4 -O -K -B0 -W3/50/200/50 << GREEN >> $outfile
7 15.4
7.5 15.4
GREEN
psxy $page $a4 -O -K -B0 -W3/0/0/0 << BLACK >> $outfile
11 15.4
11.5 15.4
BLACK
psxy $page $a4 -O -K -B0 -W3/200/50/50 << RED >> $outfile
15 15.4
15.5 15.4
RED
pstext $page $a4 -O -K << BLUE >> $outfile
3.7 15.27 10 0 0 1 1 minute profile
BLUE
pstext $page $a4 -O -K << RED >> $outfile
7.7 15.27 10 0 0 1 2 minute profile
RED
pstext $page $a4 -O -K << BLACK >> $outfile
11.7 15.27 10 0 0 1 C-MAP profile
BLACK
pstext $page $a4 -O << GREEN >> $outfile
15.7 15.27 10 0 0 1 Depth difference
GREEN
echo "done."

# convert the images
echo -n "converting to pdf "
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
   ${outfile%.ps}.pdf
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" > /dev/null
echo "done."

exit 0
