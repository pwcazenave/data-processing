#!/bin/bash
#
# script to plot the arcgis calculated slope output
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

infile=./protruding_geology_slope.xyz
outfile=./arcgis_slope.ps

area=-R585200/586250/94000/95250
proj=-Jx0.009
area_text=-R0/22/0/30
proj_text=-JX22c/30c

mksurf(){
   echo -n "make a surface... "
   xyz2grd $area -I0.25 $infile -G${infile%.xyz}.grd
}

plot(){
   echo -n "plotting the grid... "
   grd2cpt ${infile%.xyz}.grd $area -Crainbow -Z -L0/30 > slope.cpt
   grdimage $area $proj \
      -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
      -Cslope.cpt ${infile%.xyz}.grd -X3c -Yc -K > $outfile
   psscale -D10/5/5/0.4 -B5 -Cslope.cpt -O -K >> $outfile
   pstext $proj $area -O -K -N << TEXT >> $outfile
   586300 94900 12 0 0 1 Slope (@+o@+)
TEXT
   grdimage $area $proj -Cutec.cpt -O -K -X14.5c utec_mask.grd \
      -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
      -Iutec_grad.grd >> $outfile
   psscale -D10/5/5/0.4 -B1 -Cutec.cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   586300 94900 12 0 0 1 Depth (m)
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

#mksurf          # make a grid from the arcgis output
plot            # plot said output
formats         # convert it to the holy trinity

exit 0
