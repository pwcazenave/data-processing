#!/bin/bash

# script to plot the wind vectors

echo -n "plot vectors... "
for infile in ./2007-07/vectors/fortran_input/*.out; do
   area=-R-10/5/47.5/52.5
   proj=-Jm1.5
   year=$(echo $infile | cut -c33-36)
   day=$(echo $infile | cut -c38-40)
   outfile=./2007-07/vectors/images/$(basename $infile .out).ps
   # add a coastline for the area
#      -Ba1f0.5g1:."Wind speed and direction for day $day (July $year)":WeSn\
   pscoast $area $proj \
      -Ba1f0.5g1WeSn\
      -Df -G0/0/0 -K -X2.4 -Yc \
      -N1/255/255/255 -W1/255/255/255 > $outfile
   # plot the vectors
   makecpt -T0/24/0.001 -Z -Cwysiwyg > ./vectors.cpt
   awk '{print $1, $2, $3, $4, $3/10}' $infile | \
      psxy $area $proj -B0WeSn -Sv0.02/0.3/0.1 -O -K -W2 -C./vectors.cpt \
      -H1 >> $outfile
   # add the colour scale
   psscale -D24/6/6/0.5 -B2 -C./vectors.cpt -O -K >> $outfile
   pstext $area $proj -N -O << TEXT >> $outfile
   5.65 51.6 12 0 0 1 Speed (ms@+-1@+)
TEXT

done
echo "done."

# convert postscipt to pdf
echo -n "convert images to pdf and jpeg... "
for i in ./2007-07/vectors/images/*.ps; do
   ps2pdf -sPAPERSIZE=a4 $i ./2007-07/vectors/images/$(basename $i .ps).pdf
   gs -sDEVICE=jpeg -r80 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${i%.ps}.jpg" \
   $i > /dev/null
done
echo "done."

exit 0

