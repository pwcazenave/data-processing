#!/bin/bash

# script to subtract the gebco grid from the etopo grid. the output file names
# are indicative of which was subtracted from which; the second name was
# subtracted from the first. that's why there are generally two sets of each
# processing command.

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F

area=-R-10/5/47.5/52.5
proj=-Jm1.5

outfile=./images/etopo_gebco_diff.ps # lo res upsampled
#outfile=./images/gebco_etopo_diff.ps # hi res downsampled

# resample the etopo bathy to a 1 minute grid to match that of the gebco data
grdsample ../etopo/etopo_bathy.grd -I1m -G../etopo/etopo_bathy_resampled_1min.grd
# do it the other way around
#grdsample ../gebco/gebco_bathy.grd -I2m -G../gebco/gebco_bathy_resampled_2min.grd

# subtract one grid from the other
grdmath ../etopo/etopo_bathy_resampled_1min.grd ../gebco/gebco_bathy.grd \
   SUB = ./etopo_gebco_diff.grd
# do it the other way around
#grdmath ../gebco/gebco_bathy_resampled_2min.grd ../etopo/etopo_bathy.grd \
#   SUB = ./gebco_etopo_diff.grd

# make a colour palette file
#makecpt -T-50/50/0.1 -Z -Cwysiwyg > ./diff.cpt
grd2cpt ./etopo_gebco_diff.grd -L-10/10 $area > ./diff.cpt
#grd2cpt ./gebco_etopo_diff.grd -L-10/10 $area > ./diff.cpt

# plot the image
grdimage $area $proj ./etopo_gebco_diff.grd -Ba1f0.5g1:."Difference between the ETOPO 2 minute grid and the GEBCO 1 minute grid depths":WeSn -C./diff.cpt -K -X2 -Yc > $outfile
#grdimage $area $proj ./gebco_etopo_diff.grd -Ba1f0.5g1:."Difference between the ETOPO 2 minute grid and the GEBCO 1 minute grid depths":WeSn -C./diff.cpt -K -X2 -Yc > $outfile

# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D24/6/6/0.5 -Ba2f1 -C./diff.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
5.7 51.6 12 0 0 1 Difference (m)
TEXT

# convert the images to jpeg and pdf from postscript
for image in ./images/*gebco*.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$image" "${image%.ps}.pdf" > /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" > /dev/null
   echo "done."
done

gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
