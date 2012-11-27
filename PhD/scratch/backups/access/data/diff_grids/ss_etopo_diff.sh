#!/bin/bash

# script to subtract the s&s grid from the etopo grid. the output file names
# are indicative of which was subtracted from which; the second name was
# subtracted from the first. that's why there are generally two sets of each
# processing command.

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F

area=-R-10/5/47.5/52.5
proj=-Jm1.5

outfile=./images/ss_etopo_diff.ps

# resample the etopo grid to match the s&s grid
grdsample ../etopo/etopo_bathy.grd -I2.5m -G../etopo/etopo_bathy_resampled_2.5min.grd

# subtract one grid from the other
grdmath ../etopo/etopo_bathy_resampled_2.5min.grd ../smith_and_sandwell/smithsandwell_bathy.grd SUB = ./ss_etopo_diff.grd

# make a colour palette file
grd2cpt -L-70/70 ./ss_etopo_diff.grd > ./ss_etopo_diff.cpt
#makecpt -T-70/120/0.1 -Z -Cwysiwyg > ./ss_etopo_diff.cpt

# plot the image
grdimage $area $proj ./ss_etopo_diff.grd -Ba1f0.5g1:."Difference between the ETOPO 2 minute grid and the Smith and Sandwell 2.5 minute grid depths":WeSn -C./ss_etopo_diff.cpt -K -X2 -Yc > $outfile

# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D24/6/6/0.5 -Ba20f10 -C./ss_etopo_diff.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
5.7 51.6 12 0 0 1 Difference (m)
TEXT

# convert the images to jpeg and pdf from postscript
for image in ./images/ss*.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$image" \
      "${image%.ps}.pdf" > /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" > /dev/null
   echo "done."
done

gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
