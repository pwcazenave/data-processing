#!/bin/bash

# script to grid data from the output of the QINSy processing. raw data has been exported into ./raw_data/*.txt.

# bank slope
area_processing=-R581750/582500/94250/95000
area_text=-R0/22/0/30
proj_plot=-JX4.5/4.5
proj_text=-JX22c/30c
grid_size=0.25
outfile=bank_slope.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset MEASURE_UNIT inch

#------------------------------------------------------------------------------#

# data processing of xyz file from utec survey
# increase the ascii file precision to avoid surface complaining that the data haven't been run through blockmean. 
gmtset D_FORMAT %.2f

# concatenate several files into one, then use awk to generate input file with the correct columns. next preprocess the data with blockmean to assign a single value to every point, and finally grid this data using surface:

bm(){
   blockmedian ../../raw_data/lines.txt -I$grid_size $area_processing \
      > ./raw_data/lines_blockmeaned_$grid_size.txt
}

mksurf(){
   surface -Gutec.grd -I$grid_size $area_processing -T0.25 \
      ./raw_data/lines_blockmeaned_$grid_size.txt
}

mkgrad(){
   grdgradient utec.grd -A250 -Nt0.7 -Gutec_grad.grd
}

mkmask(){
   grdmask ./raw_data/lines_blockmeaned_$grid_size.txt -Gmask.grd -I$grid_size \
      $area_processing -N/NaN/1/1 -S5
}

clip(){
   grdmath mask.grd utec.grd MUL = utec_mask.grd
}

plot(){
   gmtset D_FORMAT %.0f
   psbasemap $proj_plot $area_processing \
      -Ba200f100:"Eastings":/a200f100:"Northings":WeSn -Xc -Y6 -P -K \
      > $outfile
   makecpt -Cwysiwyg -T-35/-16/1 -Z > utec.cpt
   grdimage $proj_plot $area_processing -Bg100 -Iutec_grad.grd \
      -Cutec.cpt utec_mask.grd -O -K >> $outfile
   psscale -D5/2/2/0.2 -B5 -Cutec.cpt -O -K >> $outfile
   pstext $proj_text $area_text -O << TEXT >> $outfile
   12.2 8.2 12 0 0 1 Depth (m)
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
mksurf
mkgrad
mkmask
clip
plot
formats

exit 0
