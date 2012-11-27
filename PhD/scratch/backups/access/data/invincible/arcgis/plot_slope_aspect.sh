#!/bin/bash

# script to take the horrible ascii output fom arcmap and make a 4 column
# file which reads in the slope and aspect for the same coordinate, and then
# plots a graph.

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE_PRIMARY 12
gmtset HEADER_FONT_SIZE 16

asc2xyz="python $HOME/bin/grd2xyz2.py"

area=-R0/360/0/38
slope_area=-R0/35/0/40
aspect_area=-R0/360/0/3
proj=-JX24/16
hist_proj=-JX17/12

slopein=./raw_data/invin_slope.xyz
aspectin=./raw_data/invin_aspect.xyz
slope_aspectin=./raw_data/invin_slope_aspect.xyzz
outfile=./images/slope_vs_aspect.ps
histogram=./images/histogram.ps

pythonning()
{
   $asc2xyz ${slopein%.xyz}.txt | awk '{if ($3!=-9999) print $0}' > $slopein
   $asc2xyz ${aspectin%.xyz}.txt | awk '{if ($3!=-9999) print $0}' > $aspectin
}


formatting()
{
   awk '{print $3}' $aspectin | paste $slopein - | awk '{print $4,$3}' |\
      sort -g > $slope_aspectin
}

plot()
{
   psxy $area $proj $slope_aspectin \
      -Ba20f5:"Direction (@+o@+)":/a10f2:"Slope (@+o@+)":WeSn \
      -Sc0.05 -G0/0/0 > $outfile
   pshistogram $slope_area $hist_proj $slope_aspectin -Xc -Y16 -Z1 -T1 -W1.15 \
      -G100/100/100 -L0/0/0 -K -P \
      -Ba10f2:"Slope"::,-@+o@+:/a10f2:,-%:WeSn > $histogram
   pshistogram $aspect_area $hist_proj $slope_aspectin -Y-14 -Z1 -T0 -W1 \
      -G100/100/100 -L0/0/0 -O \
      -Ba90f10:"Slope Aspect"::,-@+o@+:/a0.5f0.25:,-%:WeSn >> $histogram
}

formats()
{
   ps2pdf -sPAPERSIZE=a4 $outfile \
      ${outfile%.ps}.pdf
   ps2pdf -sPAPERSIZE=a4 $histogram \
      ${histogram%.ps}.pdf
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      -sOutputFile=${outfile%.ps}.jpg \
      $outfile > /dev/null
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      -sOutputFile=${histogram%.ps}.jpg \
      $histogram > /dev/null
}

pythonning
formatting
plot
formats

exit 0
