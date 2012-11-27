#!/bin/bash

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset PAPER_MEDIA=a4

area=-R578106/588473/91505/98705
proj=-Jx0.00215
gres=-I1

infile=./raw_data/all_lines_blockmedian_1m.txt
outfile=./images/hsb_bathy.ps

formats(){
   echo -n "converting to pdf, "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "png, "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r30 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $outfile
   echo "done."
}

process(){
   gmtset D_FORMAT=%.10f
   surface $area $gres -S5 -T0.25 $infile -G./grids/$(basename ${infile%.*}_surface.grd) 2>&1 > /dev/null
   grdmask $area $gres $infile -S5 -G./grids/$(basename ${infile%.*}_mask.grd)
   grdmath ./grids/$(basename ${infile%.*}_surface.grd) ./grids/$(basename ${infile%.*}_mask.grd) \
      MUL = ./grids/$(basename ${infile%.*}.grd)
   grdgradient ./grids/$(basename ${infile%.*}.grd) -Nt0.7 -E250/50 -G./grids/$(basename ${infile%.*}_grad.grd)
}

plot(){
   gmtset D_FORMAT=%g
#   makecpt $(grdinfo -T1 ./grids/$(basename ${infile%.*}.grd)) -Cgray > ./cpts/$(basename ${infile%.*}.cpt)
   makecpt -T-60/-14/1 -Cgray > ./cpts/$(basename ${infile%.*}.cpt)

   gmtset D_FORMAT=%.0f
   psbasemap $area $proj -Xc -Yc -K -B0 > $outfile
   grdimage $area $proj -Xc -Yc -K ./grids/$(basename ${infile%.*}.grd) \
      -C./cpts/$(basename ${infile%.*}.cpt) -I./grids/$(basename ${infile%.*}_grad.grd) \
      -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn > $outfile
   psxy $area $proj -W5 -O -K << BOX >> $outfile
586106 96505
586356 96505
586356 96255
586106 96255
586106 96505
BOX
   # Add in subsets too
   psxy $area $proj -W5 -O -K << BOX >> $outfile
579000 97000
582000 97000
582000 95000
579000 95000
579000 97000
BOX
   psxy $area $proj -W5 -O -K << BOX >> $outfile
585000 97000
586500 97000
586500 95500
585000 95500
585000 97000
BOX
   # Add in some labels
   pstext $area $proj -O -K -D0.15/0.15 -WwhiteO0,white << TEXT >> $outfile
586106 96255 10 0 0 1 A
579000 95000 10 0 0 1 B
585000 95500 10 0 0 1 C
TEXT
   
   psscale -D23.2/8/7/0.5 -B10:"Depth (m)": -C./cpts/$(basename ${infile%.*}.cpt) -I -O -K >> $outfile
   
   # Add in a location map
   gmtset BASEMAP_TYPE=plain
   psbasemap -R-11/2/48/59 -Jm0.28 -B0 -O -K -X18.65 >> $outfile
   pscoast -R -J -Di -Gwhite -B0 -W -O -K >> $outfile
   # Add box for location
#   psxy -R -J -W2,black -O -K -L << BOX >> $outfile
#0.524340  50.691114
#0.674988  50.726135
#0.658286  50.774940
#0.509767  50.745585
#BOX
   pstext -R -J -O -K -D-2.8/-0.66 -WwhiteO0,white << HSB >> $outfile
0.6 50.74 10 0 0 1 Hastings
HSB
   psxy -R -J -O -Svs0.03/0.3/0.08 -Gwhite -W2,black << POINT >> $outfile
-4 49.5 0.6 50.74
POINT

   formats $outfile
}

#process
plot
