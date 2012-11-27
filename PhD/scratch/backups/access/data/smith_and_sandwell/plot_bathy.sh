#!/bin/bash

# script to plot the smith and sandwell bathymetry

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F

area=-R-10/5/47.5/52.5
proj=-Jm1.5
gres=-I2.5m

infile=./smith_and_sandwell.txt
outfile=./images/2min_bathy.ps

# make a grid file
echo -n "make the grid file... "
awk '{if ($1>5) print $1-360, $2, $3; else print $0}' $infile | xyz2grd $area $gres -Gsmithsandwell_all.grd
echo "done."

# make a color palette file
makecpt -T-200/0/0.1 -Z -Cwysiwyg > shelf.cpt

# clip out the land areas
echo -n "mask the land... "
grdlandmask $area -Gsmithsandwell_landmask.grd $gres -Df -N1/NaN
echo "done."

# make a gradient grid
echo -n "make the gradient grid... "
grdgradient smithsandwell_all.grd -Gsmithsandwell_grad_all.grd -Nt0.7 -E270/50
echo "done."

# clip the gradient and bathy grids
echo -n "clip the bathy with the landmask... "
grdmath smithsandwell_all.grd smithsandwell_landmask.grd MUL \
   = smithsandwell_bathy.grd
grdmath smithsandwell_grad_all.grd smithsandwell_landmask.grd MUL \
   = smithsandwell_grad.grd
echo "done."

# plot said bathy
echo -n "plot the bathy... "
grdimage $area $proj ./smithsandwell_bathy.grd -Ba1f0.5g1:."Smith and Sandwell 2.5 minute Bathymetry":WeSn -Cshelf.cpt -X2 -Yc -K -I./smithsandwell_grad.grd > $outfile

# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D24/6/6/0.5 -B20 -C./shelf.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
5.9 51.6 12 0 0 1 Depth (m)
TEXT
echo "done."

# make a geotiff from the grid files
echo "making a geotiff... "
mbgrdtiff -Ismithsandwell_bathy.grd -Ksmithsandwell_grad.grd -Cshelf.cpt -Osmithsandwell_bathy.tif
echo "done."

# convert the images to jpeg and pdf from postscript
for image in ./images/*.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$image" "${image%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" > /dev/null
   echo "done."
done

gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
