#!/bin/bash

# script to plot a histogram of the slope grid files

gmtset LABEL_FONT_SIZE 14
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 14
gmtset D_FORMAT %g

area=-R578117/588357/91508/98708
xy_area=-R0/360/0/38
hist_asp_area=-R0/360/0/5
hist_dir_area=-R0/35/0/40
proj=-JX15/10

infile=./grids/invincible.grd
outfile=./images/invincible_slope_aspect.ps

mkgrad()
{
   echo -n "make the gradient and aspect files... "
   grdgradient $infile -G${infile%.grd}_dir.grd -D -S${infile%.grd}_slope.grd
   echo "done."
}

mkdegrees()
{
   echo -n "convert slope to degrees... "
   grdmath ${infile%.grd}_slope.grd ATAN 57.29577951 MUL = \
      ${infile%.grd}_deg.grd
   echo "done."
}

processing()
{
   echo -n "slope vs. aspect... "
   grd2xyz -S ${infile%.grd}_deg.grd | awk '{print $3}' > ./invincible_slope.z
   grd2xyz -S ${infile%.grd}_dir.grd | awk '{print $3}' | \
      paste - ./invincible_slope.z \
      > ./invincible_slope_aspect.xy
   \rm -f ./invincible_slope.z
   echo "done."
}

plot()
{
   echo -n "plot direction vs. slope... "
   gmtset D_FORMAT %g
   pshistogram ./invincible_slope_aspect.xy \
      $hist_asp_area $proj -W1 -G100/100/100 \
      -Ba90f10g90:,-@+o@+::"Slope Aspect":/a1f0.25g1:,-%:WeSn \
      -L0/0/0 -T0 -Z1 -P -Y17 -K > $outfile
#   psxy $xy_area $proj ./invincible_slope_aspect.xy \
#      -Ba90f10:,-"@+o@+"::"Direction":/a10f2:,-@+o@+::"Slope":WeSn \
#      -Xc -Y17 -K -P -G0/0/0 -Sc0.01 > $outfile
   echo -n "and the direction histogram... "
   grd2xyz -S ${infile%.grd}_deg.grd | \
      pshistogram $hist_dir_area $proj -W1 -G100/100/100 \
      -Ba5f1g5:,-@+o@+::"Slope":/a10f0.5g10:,-%:WeSn \
      -L0/0/0 -T2 -Z1 -Y-14 -O >> $outfile
   echo "done."
}

formats()
{
   echo -n "convert output to jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      -sOutputFile=${outfile%.ps}.jpg $outfile > /dev/null
   echo -n "and pdf... "
   ps2pdf -sPAPERSIZE=a4 $outfile ${outfile%.ps}.pdf > /dev/null
   echo "done."
}

#mkgrad
#mkdegrees
#processing
plot
formats

exit 0
