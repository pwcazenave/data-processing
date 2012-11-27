#!/bin/bash

# script to add tracklines over the difference grid

area=-R314695/320327/5595450/5599120 # the 2007 area (smallest)
proj=-Jx0.0039

outfile=./images/tracklines_diff_2006.ps

plot() {
   # plot the image
   echo -n "plot the difference grid... "
   gmtset D_FORMAT %g
   #makecpt -Crainbow -T-4/22/0.1 -I -Z > ./diff.cpt
   #grd2cpt ./grids/area473_07-06.grd -Crainbow $area -L-2/7 -Z > ./diff.cpt
   gmtset D_FORMAT %.0f
   psbasemap $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K > $outfile
   grdimage $area $proj -Bg1000 -Cdiff.cpt ./grids/area473_07-06.grd -O -K \
      >> $outfile
   gmtset D_FORMAT %g
   psscale -D23.2/6/5/0.5 -B0.5 -Cdiff.cpt -O -K >> $outfile
   for line in ./tracklines/2006/*.pfl; do
      psxy $area $proj -O -K -B0 -Sc0.025 -G255/255/255 -W3/255/255/255 $line \
         >> $outfile
   done
   pstext $proj $area -O -N << TEXT >> $outfile
   320500 5597800 10 0 0 1 Difference (m)
TEXT
   echo "done."
}

formats() {
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" \
      "${outfile%.ps}.pdf" &> /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" &> /dev/null
   echo "done."
}


plot            # plot the difference grid
formats         # convert the output

exit 0
