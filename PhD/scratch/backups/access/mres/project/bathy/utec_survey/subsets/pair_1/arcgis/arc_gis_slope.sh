#!/bin/bash
#
# script to plot the arcgis calculated slope output
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

infile=../raw_data/pair_1_slope.xyz
outfile=../images/arcgis_slope.ps

area=-R586100/587000/95500/96000
proj=-Jx0.016
area_text=-R0/22/0/30
proj_text=-JX22c/30c

mksurf(){
   echo -n "make a surface... "
   xyz2grd $area -I0.25 $infile -G${infile%.xyz}.grd
   mv ${infile%.xyz}.grd ../grids/
}

plot(){
   file=../grids/$(basename $infile .xyz).grd
   echo -n "plotting the grid... "
   grd2cpt $file $area -Crainbow -Z -L0/30 > slope.cpt
   grdimage $area $proj -P \
      -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
      -Cslope.cpt $file -Xc -Y16c -K > $outfile
   psscale -D15.3/3.5/4/0.5 -B5 -Cslope.cpt -O -K >> $outfile
   pstext $proj $area -O -K -N << TEXT >> $outfile
   587050 95900 12 0 0 1 Slope (@+o@+)
TEXT
   grdimage $area $proj -C../.utec.cpt -O -K -Y-12 ../grids/utec.grd \
      -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
      -I../grids/utec_grad.grd >> $outfile
   psscale -D15.3/3.5/4/0.5 -B2 -C../.utec.cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   587050 95900 12 0 0 1 Depth (m)
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
