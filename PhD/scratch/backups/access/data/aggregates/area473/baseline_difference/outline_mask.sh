#!/bin/bash

# script to plot the mask as an outline rather than a mask

area=-R314695/320327/5595450/5599120 # the 2007 area (smallest)
proj=-Jx0.0039
outfile=./images/mask_outline.ps

mkmask(){
   gmtset D_FORMAT %.2f
   # seemingly the -N option in grdmask hasn't been well tested (according to
   # then anyway, so, a more rudimentary approach is necessary.
   grd2xyz ./grids/magic_mask.grd | grep -v NaN > ./grids/magic_mask.xy
   awk '{print $1}' ./grids/magic_mask.xy | sort -ug > ./x.along
   awk '{print $2}' ./grids/magic_mask.xy | sort -ug > ./y.along
   for axis in x.along y.along; do
      count=1
      total=$(wc -l < $axis)
      for coord in $(<$axis); do
         echo "$coord $count of $total"
         awk '/'$coord'/' ./grids/magic_mask.xy | \
         minmax -C | awk '{print $1,$3"\n"$2,$4}' >> ./grids/outline.xy
         count=$((count+1))
      done
   done
#   \rm -f ./x.along ./y.along ./grids/magic_mask.xy
}

plot() {
   # plot the image
   echo -n "plot the mask outline... "
   gmtset D_FORMAT %g
   gmtset D_FORMAT %.0f
   psbasemap $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K > $outfile
   gmtset D_FORMAT %g
   gmtset D_FORMAT %.2f
   psxy $area $proj -Sc0.05 -O -W2/0/200/100 ./grids/outline.xy >> $outfile
   echo "done."
}

formats() {
echo -n "convert the image to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" \
   &> /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" &> /dev/null
echo "done."
}

mkmask          # make the mask as an outline
plot            # plot the grid
formats         # convert the output

exit 0
