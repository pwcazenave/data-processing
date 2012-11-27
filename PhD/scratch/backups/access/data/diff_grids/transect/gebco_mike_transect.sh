#!/bin/bash

# script to plot difference between GEBCO, CMAP and ETOPO.

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT=F
gmtset ANNOT_FONT_SIZE=12
gmtset LABEL_FONT_SIZE=12
gmtset HEADER_FONT_SIZE=14
gmtset ANNOT_FONT_SIZE_SECONDARY=12

area=-R-10/5/47.5/52.5
proj=-Jm1

gebco_1min=../../gebco/plot/gebco_bathy.grd
etopo_1min=../../etopo/etopo_bathy_resampled_1min.grd
cmap_1min=../../cmap/grids/cmap_bathy.grd
outfile=../images/gebco_vs_etopo_transect.ps

# make a transect (fairly long)
slat=49.3
slong=-6.5
elat=50.5
elong=1
echo -n "making the profile... "
project -C$slong/$slat -E$elong/$elat -G1 -Q > ./onemin_transect.trk
echo "done."

# get the values from the grid
echo -n "take the depth values from the grids... 1 "
grdtrack ./onemin_transect.trk -G$gebco_1min -S > ./g_onemin_transect.pfl
echo -n "2 "
grdtrack ./onemin_transect.trk -G$etopo_1min -S > ./e_onemin_transect.pfl
echo -n "3 "
grdtrack ./onemin_transect.trk -G$cmap_1min -S > ./c_onemin_transect.pfl
echo "done."

# plot the profiles
echo -n "plot the profiles... "
p_area=$(awk '{print $3, $4}' ./g_onemin_transect.pfl | minmax -I5)
p_proj=-JX15c/9c

awk '{print $3, $4}' ./g_onemin_transect.pfl | \
   psxy $p_area $p_proj \
   -Ba100f50g100:,-km::"Distance along line":/a20f10g20:,-m::"Depth":WSn \
   -K -Xc -Y18 -W3/50/50/200 -P > $outfile
#awk '{print $3, $4}' ./e_onemin_transect.pfl | \
#   psxy $p_area $p_proj -B0 -O -K -W3/50/200/50 >> $outfile
# add in the mike mesh output profile
echo -n "adding cmap... "
#psxy $p_area $p_proj -B0 -O -K -W3/0/0/0 ./MIKE_transect.txt >> $outfile
#psxy $p_area $p_proj -B0 -O -K -W3/100/100/100 ./MIKE_transect_3.txt >> $outfile
awk '{print $3, $4}' ./c_onemin_transect.pfl | \
   psxy $p_area $p_proj -B0 -O -K -W3/200/150/150 >> $outfile

# add labels
end_x=$(echo "scale=4; $(echo $p_area | cut -f2 -d"/")-30" | bc -l)
pstext -N $p_area $p_proj -O -K -W255/255/255 << LABELS >> $outfile
10 -30 12 0 0 1 A
$end_x -30 12 0 0 1 B
LABELS
echo "done."

# add in the error using a subsampled version of the 1 minute profile
#echo -n "calculating errors... "
#awk '{print $3, $4}' ./g_onemin_transect.pfl > sub1.pfl
#echo -n "formatting... "
#awk '{print $3, $4}' ./e_onemin_transect.pfl > sub2.pfl
#paste sub1.pfl sub2.pfl | awk '{print $1, $2-$4}' > eg_error.pfl
#d_area=$(minmax ./eg_error.pfl -I3)
#echo -n "plotting... "
#psxy $d_area $p_proj -O -K -B0/a5f2.5E -W2/200/50/50 eg_error.pfl >> $outfile
## add in a red axis label
#pstext -N -O -K $p_area $p_proj -G200/50/50 << RED_LABEL >> $outfile
#625 -99 12 90 0 1 Difference in depth values (m)
#RED_LABEL
#echo "done."

# plot the profile on a map
echo -n "add the location... "
grdimage $area $proj -Ba1f0.5g1WeSn -O -K -C../../gebco/plot/shelf.cpt ../../gebco/plot/gebco_bathy.grd -Y-13 -I../../gebco/plot/gebco_grad.grd >> $outfile
# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile
# add the profile location
psxy ./onemin_transect.trk $area $proj -W5/255/255/255 -B0 -O -K \
   >> $outfile
psxy ./onemin_transect.trk $area $proj -W3/0/0/0 -B0 -O -K \
   >> $outfile
echo "done."

# label the profile start and end
pstext $area $proj -D0/-0.4 -B0 -O -K -W255/255/255O0.1/255/255/255 \
   << TRANS_LAB >> $outfile
   $slong $slat 10 0 0 1 A
   $elong $elat 10 0 0 1 B
TRANS_LAB

# add a scale bar
echo -n "add a scale bar... "
psscale -D7.5/-1.6/13/0.5h -P -C../../gebco/plot/shelf.cpt -O -K -B20:"Depth (m)": >> $outfile
echo "done."

# add in the key
echo -n "add the labels... "
page=-R0/23/0/34
a4=-JX23c/34c
psxy $page $a4 -X-3.1 -Y-5.5 -O -K -B0 -W5/50/50/200 << BLUE >> $outfile
6 15.8
6.5 15.8
BLUE
#psxy $page $a4 -O -K -B0 -W3/50/200/50 << GREEN >> $outfile
#7 15.4
#7.5 15.4
#GREEN
#psxy $page $a4 -O -K -B0 -W3/0/0/0 << BLACK >> $outfile
#11 15.6
#11.5 15.6
#BLACK
#psxy $page $a4 -O -K -B0 -W3/100/100/100 << GREY >> $outfile
#11 15.4
#11.5 15.4
#GREY
psxy $page $a4 -O -K -B0 -W5/200/150/150 << PINK >> $outfile
13 15.8
13.5 15.8
PINK
#psxy $page $a4 -O -K -B0 -W3/200/50/50 << RED >> $outfile
#15 15.4
#15.5 15.4
#RED
pstext $page $a4 -O -K << BLUE >> $outfile
6.7 15.67 12 0 0 1 GEBCO
BLUE
#pstext $page $a4 -O -K << GREEN >> $outfile
#7.7 15.27 12 0 0 1 ETOPO 1 minute
#GREEN
pstext $page $a4 -O -K << BLACK >> $outfile
13.7 15.67 12 0 0 1 C-MAP
BLACK
#pstext $page $a4 -O << GREEN >> $outfile
#15.7 15.27 10 0 0 1 Depth difference
#GREEN
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
