#!/bin/bash

# script to plot the etopo bathy, with illumination from the west

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F

area=-R-10/5/47.5/52.5
proj=-Jm1.6

infile=./raw_data/bathy.txt
outfile=./images/etopo_bathy.ps

# make a continental shelf colour palette file
makecpt -T-200/0/0.1 -Z -Cwysiwyg > shelf.cpt

# make a surface of the etopo data
#surface $area -I2m -Getopo_raw.grd $infile

# clip out the land areas
grdlandmask $area -Getopo_landmask.grd -I2m -Df -N1/NaN

# make a gradient grid
grdgradient ./etopo_bathy.grd -Getopo_grad_all.grd -Nt0.7 -E270/50

# clip the gradient and bathy grids
grdmath etopo_raw.grd etopo_landmask.grd MUL = etopo_bathy.grd
grdmath etopo_grad_all.grd etopo_landmask.grd MUL = etopo_grad.grd

# plot the grid
grdimage $area $proj etopo_bathy.grd -Ba1f0.5g1WeSn -Cshelf.cpt -X2 -Yc -K -I./etopo_grad.grd > $outfile

# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D25.5/6/6/0.5 -B20 -C./shelf.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
5.9 51.6 12 0 0 1 Depth (m)
TEXT

# make a geotiff from the grid files
echo "making a geotiff... "
mbgrdtiff -Ietopo_bathy.grd -Ketopo_grad.grd -Cshelf.cpt -Oetopo_bathy.tif
echo "done."

# convert the images to jpeg and pdf from postscript
for image in ./images/*.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 "$image" "${image%.ps}.pdf" > /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" > /dev/null
   echo "done."
done

gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
