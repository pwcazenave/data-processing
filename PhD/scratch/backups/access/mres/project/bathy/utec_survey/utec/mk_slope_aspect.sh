#!/bin/bash

# script to plot a histogram of the slope grid files

gmtset LABEL_FONT_SIZE 14
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 14

area=-R578117/588357/91508/98708
xy_area=-R0/360/0/80
hist_dir_area=-R0/360/0/20
proj=-JX15/10

inslope=./utec_mask2_deg.xyz
indir=./utec_mask2_dir.xyz

outfile=./images/hastings_slope_aspect.ps

processing()
{
   echo -n "slope vs. aspect... "
   awk '{print $3}' $inslope > ./hastings_slope.z
   awk '{print $3}' $indir | \
      paste - ./hastings_slope.z > ./hastings_slope_aspect.xy
   echo "done."
}

plot()
{
   echo -n "plot direction vs. slope... "
   gmtset D_FORMAT %g
   psxy $xy_area $proj ./hastings_slope_aspect.xy \
      -Ba90f10g90:,-"@+o@+"::"Aspect":/a10f2g10:,-@+o@+::"Slope":WeSn \
      -Xc -Y17 -K -P -G0/0/0 -Sc0.01 > $outfile
   echo -n "and the slope vs. direction... "
   awk '{print $2,$1}' ./hastings_slope_aspect.xy | \
      psxy $xy_area $proj ./hastings_slope_aspect.xy \
      -Ba90f10g90:,-"@+o@+"::"Aspect":/a10f2g10:,-@+o@+::"Slope":WeSn \
      -Y-14 -O -G0/0/0 -Sc0.01 >> $outfile
#   echo -n "and the direction histogram... "
#   pshistogram $hist_dir_area $proj $indir -W1 -G100/100/100 \
#      -Ba20f10g20:,-@+o@+::"Slope":/a5f0.5g5:,-%:WeSn \
#      -L0/0/0 -T2 -Z1 -Y-14 -O >> $outfile
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

#processing
plot
formats

exit 0
