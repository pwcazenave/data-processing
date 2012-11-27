#!/bin/bash
#
# script to plot the arcgis calculated slope output
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

infile=./wreck_slope_slope.xyz
outfile=./arcgis_slope.ps

area=-R585250/586000/95750/96500
proj=-Jx0.005
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
      -Cslope.cpt ${infile%.xyz}.grd -Xc -Yc -K > $outfile
   psscale -D5/2/2/0.2 -B5 -Cslope.cpt -O -K >> $outfile
   pstext $proj_text $area_text -O << TEXT >> $outfile
   12.5 8.2 12 0 0 1 Slope (@+o@+)
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
