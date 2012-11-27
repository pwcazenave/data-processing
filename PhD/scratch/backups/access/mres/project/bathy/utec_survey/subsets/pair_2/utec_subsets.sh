#! /bin/bash

# script to grid data from the output of the QINSy processing. raw data has 
# been exported into ./raw_data/*.txt.

area=-R586500/587000/95500/96000
proj=-Jx0.02
grid_size=0.25
outfile=./images/pair_2_wreck.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset MEASURE_UNIT cm

bm(){
   blockmedian ../../raw_data/lines.txt -I$grid_size $area \
      > ./raw_data/lines_blockmeaned_$grid_size.txt
}

mksurf(){
   surface -G./grids/utec_interp.grd -I$grid_size $area -T0.25 \
      ./raw_data/lines_blockmeaned_$grid_size.txt
}

mkgrad(){
grdgradient ./grids/utec_interp.grd -A250 -Nt0.7 -G./grids/utec_grad.grd
}

mkmask(){
   grdmask ./raw_data/lines_blockmeaned_$grid_size.txt -G./grids/mask.grd \
      -I$grid_size $area -N/NaN/1/1 -S5
}

clip(){
   grdmath ./grids/utec_interp.grd ./grids/mask.grd MUL = ./grids/utec.grd
}

plot(){
   gmtset D_FORMAT %.0f
   psbasemap $proj $area \
      -Ba200f100:"Eastings":/a100f50:"Northings":WeSn \
      -Xc -Yc -K -P > $outfile
   gmtset D_FORMAT %g
   makecpt -Cwysiwyg -T-42/-34/0.1 -Z > .utec.cpt
   grdimage $proj $area -Bg200 -I./grids/utec_grad.grd \
      -C.utec.cpt ./grids/utec.grd -O -K >> $outfile
   psscale -D11.2/4.5/5/0.5 -B2 -C.utec.cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   587050 95875 12 0 0 1 Depth (m)
TEXT
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

#bm
#mksurf
#mkgrad
#mkmask
#clip
plot
formats

exit 0
