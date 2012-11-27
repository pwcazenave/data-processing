#!/bin/bash

# script to plot the tide as a coloured trackline

area=-R314695/320327/5595450/5599120 # the 2007 area (smallest)
proj=-Jx0.0039

infile=./tracklines/2006/tide_diff_coords.txt
outfile=./images/2006_diff_with_tide.ps

grid(){
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
   psscale -D23.2/10.5/5/0.5 -B0.5 -Cdiff.cpt -O -K >> $outfile
   psscale -D23.2/3/5/0.5 -B1 -Ctide.cpt -O -K >> $outfile
   pstext $proj $area -O -K -N << TEXT >> $outfile
   320500 5599000 10 0 0 1 Difference (m)
   320450 5597100 10 0 0 1 Tidal Height (m)
TEXT
   echo "done."
}

tidal(){
   # get the relevant bits of the inputfile and plot
   makecpt -Crainbow -T0.5/7.5/0.01 -Z > tide.cpt
   awk 'NR%80==0 { if ($5!="") print $3,$4,$2,$2/35}' $infile | \
      psxy $area $proj -O -K -W2/0/0/0 -Sc -Ctide.cpt -B0 >> $outfile
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


grid            # plot the gridded difference data
tidal           # add the tidal height along track
formats         # convert the output files
