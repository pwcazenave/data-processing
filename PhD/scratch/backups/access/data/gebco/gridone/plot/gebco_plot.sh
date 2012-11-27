#!/bin/bash

# script to plot the gebco bathy, with illumination from the west

gmtset LABEL_FONT_SIZE 18
gmtset ANNOT_FONT_SIZE 18
gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F

area=-R-10/5/47.5/52.5
proj=-Jm1.6

infile=./raw_data/GridOne.grd
outfile=./images/gebco_bathy.ps

# make a continental shelf colour palette file
makecpt -T-200/0/0.1 -Z -Cwysiwyg > shelf.cpt

# cut out the region of interest
grdcut $area -G./gebco_cut.grd $infile -fg

# clip out the land areas
grdlandmask $area -Ggebco_landmask.grd -I1m -Df -N1/NaN

# make a gradient grid
grdgradient ./gebco_cut.grd -Ggebco_grad_all.grd -Nt0.7 -E270/50

# clip the gradient and bathy grids
grdmath gebco_cut.grd gebco_landmask.grd MUL = gebco_bathy.grd
grdmath gebco_grad_all.grd gebco_landmask.grd MUL = gebco_grad.grd

# plot the image
grdimage $area $proj ./gebco_bathy.grd -Ba1f0.5g1WeSn -Cshelf.cpt -X2 -Yc -K -I./gebco_grad.grd > $outfile

# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D24.9/5.8/6/0.5 -B20 -C./shelf.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
5.4 51.4 18 0 0 1 Depth (m)
TEXT

# make a geotiff from the grid files
#echo "making a geotiff... "
#mbgrdtiff -Igebco_bathy.grd -Kgebco_grad.grd -Cshelf.cpt -Ogebco_bathy.tif
#echo "done."

# convert the images to jpeg and pdf from postscript
echo -n "converting $outfile to pdf "
ps2pdf -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" > /dev/null
echo "done."

#gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
