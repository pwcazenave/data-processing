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
infile=./raw_data/soh_utm.txt
outfile=./images/lidar_points.ps

name=soh

latlong=-R-7.22054/-6.96312/57.638/57.7834
area=-R612000/612200/6396500/6396600
proj=-Jx0.2

mproj(){
   gmtset D_FORMAT %.2f
   echo -n "from lat/long to utm... "
   mapproject $original -Ju29/1:1 $latlong -C -F > ${infile%latlong.txt}utm.txt
   gmtset D_FORMAT %g
   echo "done."
}

plot(){
   echo -n "plot a graph of points... "
   gmtset D_FORMAT %.0f
   psbasemap $proj $area \
      -Ba100f50:"Eastings":/a100f50:"Northings":WeSn \
      -Xc -Yc -K > $outfile
   gmtset D_FORMAT %g
   psxy $proj $area -K -Sc0.01 -Bg10 $infile > $outfile
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

#mproj                   # convert from to wgs84 to utm zone 29
plot                    # plot the clipped grid
formats                 # convert the output to pdf and jpeg

exit 0
