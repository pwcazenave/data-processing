#!/bin/bash

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset PAPER_MEDIA=a4

gres=2
ingrd=./grids/7878_Area481_${gres}m_Jan2009_UTMZone31.grd
outfile=./images/$(basename ${ingrd%.*})_colour.ps

area=$(grdinfo -I1 $ingrd)
proj=-Jx0.00225

formats(){
   echo -n "converting to pdf, "
   ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "png, "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo -n "jpeg, "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $outfile
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

plot(){
   gmtset D_FORMAT=%g
#   grdgradient -E15/50 -Nt0.7 $ingrd -G${ingrd%.*}_grad.grd
#   makecpt $(grdinfo -T1 ./grids/$(basename ${ingrd%.*}.grd)) -Cgray > ./cpts/$(basename ${ingrd%.*}.cpt)
   makecpt -T-32/-10/0.1 -Crainbow > ./cpts/$(basename ${ingrd%.*}_colour.cpt)

   gmtset D_FORMAT=%.0f
   psbasemap -P $area $proj -Xc -Yc -K -B0 > $outfile
   grdimage -P $area $proj -Xc -Yc -K ./grids/$(basename ${ingrd%.*}.grd) \
      -C./cpts/$(basename ${ingrd%.*}_colour.cpt) -I./grids/$(basename ${ingrd%.*}_grad.grd) \
      -Ba2000f500:"Eastings":/a2000f500:"Northings":WeSn > $outfile

   # Add in the test subset area
#   psxy $area $proj -W5 -O -K -Gwhite << BOX >> $outfile
#609507 5621850
#609844 5621850
#609844 5621433
#609507 5621433
#609507 5621850
#BOX
   # Add in the two subset areas too
#   psxy $area $proj -W5 -O -K << BOX >> $outfile
#613500 5624500
#615900 5624500
#615900 5623000
#613500 5623000
#613500 5624500
#BOX
#   psxy $area $proj -W5 -O -K << BOX >> $outfile
#608000 5622000
#610000 5622000
#610000 5619400
#608000 5619400
#608000 5622000
#BOX

   # Some text labels might help...
#   pstext $area $proj -D0.05/0.07 -O -K << TEXT >> $outfile
#609507 5621433 10 0 0 1 A
#TEXT
#   pstext $area $proj -D0.15/0.15 -O -K -WwhiteO0,white << TEXT >> $outfile
#613500 5623000 10 0 0 1 B
#608000 5619400 10 0 0 1 C
#TEXT

   psscale -P -D15.2/9/7/0.5 -B5:"Depth (m)": -C./cpts/$(basename ${ingrd%.*}_colour.cpt) -I -O -K >> $outfile

   # Add in a location map
   gmtset BASEMAP_TYPE=plain
   psbasemap -P -R-7.5/2/50/59.5 -Jm0.3 -B0 -O -K -Y12.887 >> $outfile
   pscoast -R -J -Dh -Ggray -B0 -W -O -K >> $outfile
   pstext -R -J -O -K -D-2.3/-0.66 -WwhiteO0,white << HSB >> $outfile
0.661307 53.268568 12 0 0 1 Area 481
HSB
   psxy -R -J -O -Svs0.05/0.3/0.1 -Gblack -W2,white << POINT >> $outfile
-1.25 52.6 0.661307 53.268568
POINT

   formats $outfile
}

plot
