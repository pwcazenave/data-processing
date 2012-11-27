#!/bin/bash

# script to plot the britned bathy from justin

gmtset LABEL_FONT_SIZE 18
gmtset ANNOT_FONT_SIZE 18
gmtset HEADER_FONT_SIZE 20
gmtset PLOT_DEGREE_FORMAT F

area=-R338400/613800/5690200/5814800
proj=-Jx0.00008
g_area=-R0.5/5/51/53
g_proj=-Jm5

infile=./raw_data/BritNed_bathy_modeledited.dat
wgs84in=./raw_data/britned_bathy_wgs84.txt
outfile=./images/britned_bathy_200m.ps
wgs84out=./images/britned_bathy_wgs84.ps

gmtset D_FORMAT %.2f

# make the grid
echo -n "make the grid... "
#xyz2grd $area $infile -Gbritned_bathy.grd -I200
#xyz2grd $g_area $wgs84in -Gbritned_bathy_wgs84.grd -I0.003
echo "done."

# make the gradient file
echo -n "make the gradient file... "
#grdgradient ./britned_bathy.grd -Gbritned_grad.grd -Nt0.1 -E270/50
#grdgradient ./britned_bathy_wgs84.grd -Gbritned_wgs84_grad.grd -Nt0.1 -E270/50
echo "done."

# make a colour palette
#grd2cpt britned_bathy.grd -Cwysiwyg -Z -L-70/0 $area > shelf.cpt
makecpt -T-75/0/0.1 -Z -Cwysiwyg > shelf.cpt

# make a coastline file
#gmtset D_FORMAT %g
#pscoast -Jm1 -R-10/5/47.5/52.5 -M -Df -W > tmp.txt
#gmtset D_FORMAT %.2f
#mapproject -R-10/5/47.5/52.5 -Ju31/1 -F -C -M tmp.txt \
#   > ./raw_data/coastline.xy
#\rm -f ./tmp.txt

gmtset D_FORMAT %.0f

# plot the image
echo -n "plot the image... "
grdimage $area $proj ./britned_bathy.grd \
   -Ba30000f15000g30000:"Eastings":/a30000f15000g30000:"Northings":WeSn \
   -Cshelf.cpt -Xc -Yc -K -I./britned_grad.grd > $outfile
grdimage $g_area $g_proj ./britned_bathy_wgs84.grd \
   -Ba1f0.5g1/a0.5f0.25g0.5WeSn \
   -Cshelf.cpt -Xc -Yc -K -I./britned_wgs84_grad.grd > $wgs84out
pscoast $g_area $g_proj -Ba1f0.5g1/a0.5f0.25g0.5WeSn -Df -G0/0/0 -O -K \
   -N1/255/255/255 -W1/255/255/255 >> $wgs84out
echo "done."

# add the scale in
psscale -D23/4.6/6/0.5 -B20 -C./shelf.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
623350 5795000 12 0 0 1 Depth (m)
TEXT
psscale -D23.6/6/6/0.5 -B20 -C./shelf.cpt -O -K >> $wgs84out
pstext $g_area $g_proj -N -O << TEXT >> $wgs84out
5.15 52.2 18 0 0 1 Depth (m)
TEXT

# display and convert the image
echo -n "convert the image to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$wgs84out" "${wgs84out%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${outfile%.ps}.jpg" "$outfile"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${wgs84out%.ps}.jpg" "$wgs84out"
echo "done."

#gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
