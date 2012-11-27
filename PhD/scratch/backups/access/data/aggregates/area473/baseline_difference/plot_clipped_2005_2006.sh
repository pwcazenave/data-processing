#!/bin/bash

# script to plot the 2005 bathy with the magic mask for ease of comparison

area=-R314695/320327/5595450/5599120 # the 2007 area (smallest)
proj=-Jx0.0039

infile05=./grids/area473_2005_clipped.grd
infile06=./grids/area473_2006_clipped.grd
infile07=./grids/area473_2007_clipped.grd
outfile05=./images/area473_2005.ps
outfile06=./images/area473_2006.ps
outfile07=./images/area473_2007.ps

# make gradient files
grdgradient $infile05 -A255 -Nt0.5 -G${infile05%.grd}_grad.grd
grdgradient $infile06 -A255 -Nt0.5 -G${infile06%.grd}_grad.grd
grdgradient $infile07 -A255 -Nt0.5 -G${infile07%.grd}_grad.grd

# make a colour palette file
makecpt -Crainbow -T39/45/0.1 -I -Z > bathy.cpt
makecpt -Crainbow -T40/46/0.1 -I -Z > bathy07.cpt

# plot the 2005 data
gmtset D_FORMAT %.0f
psbasemap $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K > $outfile05
psscale -D23.1/6.5/-5/0.5 -B1 -Cbathy.cpt -O -K >> $outfile05
pstext $proj $area -O -K -N << TEXT >> $outfile05
320575 5597900 10 0 0 1 Depth (m)
TEXT
gmtset D_FORMAT %.2f
grdimage $area $proj -I${infile05%.grd}_grad.grd \
   -Bg1000 -O -Cbathy.cpt $infile05 >> $outfile05

# plot the 2006 data
gmtset D_FORMAT %.0f
psbasemap $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K > $outfile06
psscale -D23.1/6.5/-5/0.5 -B1 -Cbathy.cpt -O -K >> $outfile06
pstext $proj $area -O -K -N << TEXT >> $outfile06
320575 5597900 10 0 0 1 Depth (m)
TEXT
gmtset D_FORMAT %.2f
grdimage $area $proj -I${infile06%.grd}_grad.grd \
   -Bg1000 -O -Cbathy.cpt $infile06 >> $outfile06

# plot the 2007 data
gmtset D_FORMAT %.0f
psbasemap $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn -Xc -Yc -K > $outfile07
psscale -D23.1/6.5/-5/0.5 -B1 -Cbathy07.cpt -O -K >> $outfile07
pstext $proj $area -O -K -N << TEXT >> $outfile07
320575 5597900 10 0 0 1 Depth (m)
TEXT
gmtset D_FORMAT %.2f
grdimage $area $proj -I${infile07%.grd}_grad.grd \
   -Bg1000 -O -Cbathy07.cpt $infile07 >> $outfile07

# convert the image formats
for i in ./images/area473_200?.ps; do
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$i" "${i%.ps}.pdf" \
      &> /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${i%.ps}.jpg" \
      "$i" &> /dev/null
   echo "done."
done

exit 0
