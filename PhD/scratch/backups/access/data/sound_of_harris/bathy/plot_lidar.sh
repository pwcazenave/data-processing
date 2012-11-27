#!/bin/bash
#
# script to convert and plot the sound of harris bathy data
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g
gmtset COLOR_NAN 128/128/128

original=./raw_data/soh_original_longlat.txt
infile=${original%longlat.txt}utm.txt
outfile=./images/lidar.ps

name=soh

latlong=-R-7.22054/-6.96312/57.638/57.7834
area=-R606044/621301/6390000/6406272
proj=-Jx0.0009
gres=-I1

mproj(){
   gmtset D_FORMAT %.2f
   echo -n "from lat/long to utm... "
   mapproject $original -Ju29/1:1 $latlong -C -F \
      > $infile
   gmtset D_FORMAT %g
   echo "done."
}

bm(){
   gmtset D_FORMAT %.2f
   echo -n "blockmedian the data... "
   blockmedian $area $gres $infile > ${infile%.txt}.bmd
   gmtset D_FORMAT %g
   echo "done."
}

mksurf(){
   echo -n "make a surface... "
   surface $area $gres ${infile%.txt}.bmd -G./grids/"$name"_interp.grd
   echo "done."
}

mkgrad(){
   echo -n "making the gradient file... "
   grdgradient ./grids/"$name"_interp.grd -A35 -Nt0.7 -G./grids/"$name"_grad.grd
   echo "done."
}

mkmask(){
   echo -n "making a mask... "
   grdmask $area ${infile%.txt}.bmd -G./grids/"$name"_mask.grd $gres \
      -N/NaN/1/1 -S5
   echo "done."
}

clip(){
   echo -n "apply the mask to the data... "
   grdmath ./grids/"$name"_interp.grd ./grids/"$name"_mask.grd \
      MUL = ./grids/"$name".grd
   echo "done."
}

plot(){
   echo -n "plot an image... "
   gmtset D_FORMAT %.0f
   psbasemap $proj $area -P \
      -Ba2000f1000:"Eastings":/a1000f500:"Northings":WeSn \
      -Xc -Y12 -K > $outfile
   gmtset D_FORMAT %g
   makecpt -Crelief -T-40/33/1 -I -Z > ."$name".cpt
   grdimage $proj $area -Bg2000 -I./grids/"$name"_grad.grd \
      -C."$name".cpt ./grids/"$name".grd -O -K >> $outfile
   psscale -D15/8/-6/0.5 -B10 -C."$name".cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   582550 94850 12 0 0 1 Depth (m)
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

mproj                   # convert from to wgs84 to utm zone 29
bm                      # blockmedian the data
mksurf                  # make an interpolated surface
mkgrad			# make a gradient file
mkmask                  # make a mask
clip                    # clip the interpolated data with the mask
plot                    # plot the clipped grid
formats                 # convert the output to pdf and jpeg

exit 0
