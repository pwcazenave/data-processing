#!/bin/bash
#
# script to 
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g
gmtset COLOR_FOREGROUND 0/0/0
gmtset MEASURE_UNIT cm

infile=../lines_blockmeaned_0.25.txt
outfile=../images/gradient.ps

area=-R586100/587000/95500/96000
proj=-Jx0.016

mkgrad(){
   grdgradient -Dc -S./grids/slope_S.grd -G./grids/slope_D.grd \
      ../grids/utec_mask.grd
   grdmath ./grids/slope_S.grd ATAN = ./grids/tmp.grd
   grdmath ./grids/tmp.grd 57.295577951 MUL = ./grids/slope_degrees.grd
   \rm -f ./grids/slope_S.grd ./grids/tmp.grd
}

plot(){
   grd2cpt $area ./grids/slope_degrees.grd -Crainbow -L0/30 -Z > mag.cpt
   grd2cpt $area ./grids/slope_D.grd -Crainbow -L0/360 -Z > dir.cpt
   gmtset D_FORMAT %.0f
   # S = magnitude of maximum slopes - converted to degrees (grdmath)
   grdimage $proj $area -P \
      -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
      -Cmag.cpt ./grids/slope_degrees.grd -K -Xc -Y16 \
      > $outfile
   gmtset D_FORMAT %g
   psscale -D15.3/3.5/4/0.5 -B5 -Cmag.cpt -O -K >> $outfile
   pstext $proj $area -O -K -N << TEXT >> $outfile
   587050 95900 12 0 0 1 Slope (@+o@+)
TEXT
   # D = direction of maximum slopes
   grdimage $proj $area \
      -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
      -Cdir.cpt ./grids/slope_D.grd -O -K -Y-12 \
      >> $outfile
   psscale -D15.3/3.5/4/0.5 -B60 -Cdir.cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   587050 95900 12 0 0 1 Direction (@+o@+)
TEXT
   gmtset D_FORMAT %g
}

formats(){
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

mkgrad
plot
formats

exit 0
