#!/bin/bash

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset PAPER_MEDIA=a4

gres=1
ingrd=./grids/ws_${gres}m_blockmean.grd
outfile=./images/ws_${gres}m_bathy_colour.ps

area=$(grdinfo -I1 $ingrd)
proj=-Jx0.001

outfile=./images/ws_bathy_colour.ps

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
#   makecpt $(grdinfo -T1 ./grids/$(basename ${ingrd%.*}.grd)) -Cgray > ./cpts/$(basename ${ingrd%.*}.cpt)
   makecpt -T0/60/0.1 -I -Crainbow > ./cpts/$(basename ${ingrd%.*}_colour.cpt)

   gmtset D_FORMAT=%.0f
   psbasemap $area $proj -Xc -Yc -K -B0 > $outfile
   grdimage $area $proj -Xc -Yc -K ./grids/$(basename ${ingrd%.*}.grd) \
      -C./cpts/$(basename ${ingrd%.*}_colour.cpt) -I./grids/$(basename ${ingrd%.*}_grad.grd) \
      -Ba4000f1000:"Eastings":/a2000f1000:"Northings":WeSn > $outfile

   # Add in the IOW and Hampshire coastlines
   psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/iow_coastline.txt -: >> $outfile
   psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/south_coastline.txt >> $outfile
   # Add Yarmouth and Lymington markers
   psxy $area $proj -O -K -Sc0.3 -Gwhite -W5,black << YAR >> $outfile
606109 5618009
602347 5623890
YAR
   pstext $area $proj -O -K -D0.4/-0.4 -WwhiteO0,white << LABEL >> $outfile
606009 5618039 10 0 0 1 Yarmouth
LABEL
   pstext $area $proj -O -K -D-1.9/0.15 -WwhiteO0,white << LABEL >> $outfile
602347 5623890 10 0 0 1 Lymington
LABEL

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

   psscale -D22/7/-7/0.5 -B10:"Depth (m)": -C./cpts/$(basename ${ingrd%.*}_colour.cpt) -I -O -K >> $outfile

   # Add in a location map
   gmtset BASEMAP_TYPE=plain
   psbasemap -R-5/1/50/52 -Jm1.25 -B0 -O -K -X13.225 >> $outfile
   pscoast -R -J -Dh -Ggray -B0 -W -O -K >> $outfile
   pstext -R -J -O -K -D-2.5/-0.66 -WwhiteO0,white << HSB >> $outfile
-1.473573  50.730233 10 0 0 1 W. Solent
HSB
   psxy -R -J -O -Svs0.05/0.3/0.1 -Gblack -W2,white << POINT >> $outfile
-2.2 50.45 -1.473573 50.730233
POINT

   formats $outfile
}

plot
