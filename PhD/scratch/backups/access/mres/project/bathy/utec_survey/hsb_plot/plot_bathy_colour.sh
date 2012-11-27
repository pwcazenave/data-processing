#!/bin/bash

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset PAPER_MEDIA=a4
gmtset ANNOT_OFFSET_PRIMARY=0.1c LABEL_OFFSET=0.05c

area=-R578106/588473/91505/98705
proj=-Jx0.00215
gres=-I1

infile=./raw_data/all_lines_blockmedian_1m.txt
outfile=./images/hsb_bathy_colour.ps

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
#   surface $area $gres -S5 -T0.25 $infile -G./grids/$(basename ${infile%.*}_surface.grd) 2>&1 > /dev/null
   grdmask $area $gres $infile -NNaN/1/1 -S5 -G./grids/$(basename ${infile%.*}_mask.grd)
   grdmath ./grids/$(basename ${infile%.*}_surface.grd) ./grids/$(basename ${infile%.*}_mask.grd) \
      MUL = ./grids/$(basename ${infile%.*}.grd)
#   grdgradient ./grids/$(basename ${infile%.*}.grd) -Nt0.7 -E250/50 -G./grids/$(basename ${infile%.*}_grad.grd)
}

plot(){
   gmtset D_FORMAT=%g
#   makecpt $(grdinfo -T1 ./grids/$(basename ${infile%.*}.grd)) -Cseis > ./cpts/$(basename ${infile%.*}.cpt)
   makecpt -T-50/-14/1 -Crainbow > ./cpts/$(basename ${infile%.*}_colour.cpt)

   gmtset D_FORMAT=%.0f
   psbasemap $area $proj -Xc -Yc -K -B0 > $outfile
   grdimage $area $proj -Xc -Yc -K ./grids/$(basename ${infile%.*}.grd) \
      -C./cpts/$(basename ${infile%.*}_colour.cpt) -I./grids/$(basename ${infile%.*}_grad.grd) \
      -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn > $outfile
#   psxy $area $proj -W5 -O -K << BOX >> $outfile
#586106 96505
#586356 96505
#586356 96255
#586106 96255
#586106 96505
#BOX
   psscale -D23.2/8/7/0.5 -B10:"Depth (m)": -C./cpts/$(basename ${infile%.*}_colour.cpt) -I -O >> $outfile

   formats $outfile
}

#process
plot
