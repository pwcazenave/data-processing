#!/bin/bash

# script to plot the 2007 inner owers bathy, with illumination from the west

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F

area=-R-0.541809/-0.385326/50.657515/50.710434
proj=-Jm155

ingrid=./EmuBathy_xyz_corrected1_2m.grd
outfile=./images/inner_owers_2007_test.ps

# make a continental shelf colour palette file
makecpt -T-25/-12/0.1 -Z -Cwysiwyg > ./emu.cpt

# cut out the region of interest
#grdcut $area -G./gebco_cut.grd $infile -fg

# clip out the land areas
#grdlandmask $area -Ggebco_landmask.grd -I1m -Df -N1/NaN

# make a gradient grid
#grdgradient $ingrid -G${ingrid%.grd}_grad.grd -Nt0.7 -E270/50

# clip the gradient and bathy grids
#grdmath gebco_cut.grd gebco_landmask.grd MUL = gebco_bathy.grd
#grdmath gebco_grad_all.grd gebco_landmask.grd MUL = gebco_grad.grd

# plot the image
grdimage $area $proj ./$ingrid -Ba0.02f0.005g1/a0.01f0.005WeSn -C./emu.cpt \
   -X2 -Yc -K -I${ingrid%.grd}_grad.grd > $outfile

# add a coastline for the area
#pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D25.5/6/6/0.5 -B2 -C./emu.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
-0.379 50.698 12 0 0 1 Depth (m)
TEXT

# make a geotiff from the grid files
#echo "making a geotiff... "
#mbgrdtiff -Igebco_bathy.grd -Kgebco_grad.grd -Cshelf.cpt -Ogebco_bathy.tif
#echo "done."

# convert the images to jpeg and pdf from postscript
for image in ./images/*.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 "$image" "${image%.ps}.pdf" 2> /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" -q \
      "$image" 2> /dev/null
   echo "done."
done

#gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
