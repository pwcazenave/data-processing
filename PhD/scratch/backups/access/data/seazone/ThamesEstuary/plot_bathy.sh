#!/bin/bash
#
# script to plot the seazone bathy data
#

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18 HEADER_FONT_SIZE=18
gmtset PLOT_DATE_FORMAT=dd/mm/yyyy
gmtset D_FORMAT=%g
gmtset OUTPUT_DEGREE_FORMAT=+D PLOT_DEGREE_FORMAT=F

if [ -e ./Bathy/gridded_bathy/bathy.xyz ]; then
   echo -n "make a single bathy file... "
   awk '{if ($3<1) print $1,$2,$3}' ./Bathy/gridded_bathy/N*.txt \
      > ./Bathy/gridded_bathy/bathy.xyz
   echo "done."
fi

infile=./Bathy/gridded_bathy/bathy.xyz
outfile=./images/seazone_bathy.ps
name=seazone

area=-R-2.1/2.1/49.9/52.1
proj=-Jm5

mkgrd(){
   echo -n "make a surface... "
   awk '{if ($3<1) print $1,$2,$3}' $infile | \
      xyz2grd $area -G./grids/"$name".grd -I0.002
   echo "done."
}

mkgrad(){
   echo -n "making the gradient file... "
   grdgradient ./grids/"$name".grd -A35 -Nt0.7 -G./grids/"$name"_grad.grd
   echo "done."
}

mktiff(){
   echo -n "make a geotiff... "
   mbgrdtiff -C./."$name".cpt -K./grids/"$name"_grad.grd -I./grids/"$name".grd \
      -O${outfile%.ps}.tif
   echo "done."
}

plot(){
   echo -n "plot an image... "
   gmtset D_FORMAT %.2f
   psbasemap $proj $area \
      -Ba1f0.5/a0.5f0.25WeSn \
      -Xc -Yc -K > $outfile
   gmtset D_FORMAT %g
   makecpt -Cwysiwyg -T-90/10/1 -Z > ."$name".cpt
   grdimage $proj $area -I./grids/"$name"_grad.grd \
      -C."$name".cpt ./grids/"$name".grd -O -K >> $outfile
   pscoast $area $proj -Bg1 -Df -G0/0/0 -O -K \
      -N1/255/255/255 -W1/255/255/255 >> $outfile
   psscale -D22.3/8/6/0.5 -B20 -C."$name".cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   2.26 51.4 18 0 0 1 Depth (m)
TEXT
   echo "done."
}

formats() {
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

#mkgrd		# convert xyz to grd
#mkgrad		# make a gradient file
#mktiff		# make a geotiff
plot		# plot the bathy grid
formats		# convert the output

exit 0
