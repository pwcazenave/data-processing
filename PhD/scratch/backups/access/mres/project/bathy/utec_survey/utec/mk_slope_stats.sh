#!/bin/bash

# script to plot a histogram of the slope grid files

area=-R578117/588357/91508/98708
hist_slope_area=-R0/18/0/30
qhist_slope_area=-R0/20/0/100
hist_dir_area=-R0/360/0/6
dir_area=-R0/
proj=-JX14/11

inslope=./utec_mask2_deg.grd
indir=./utec_mask2_dir.grd

outfile=./images/hastings_stats.ps

mkxyz(){
   echo -n "grid to xyz... "
   grd2xyz $area ${inslope%.grd}.grd -S > ${inslope%.grd}.xyz
   grd2xyz $area ${indir%.grd}.grd -S > ${indir%.grd}.xyz
   echo "done."
}

plot(){
   gmtset D_FORMAT %g
#   echo -n "slope histogram... "
   echo -n "slope histogram: 1... "
##   psbasemap $hist_slope_area $proj -Ba2f0.5g2:"Slope":/a5f1g5:,%:WeSn -Xc -Y17 -K -P \
##      > $outfile
   pshistogram $hist_slope_area $proj ${inslope%.grd}.xyz -W0.57 \
      -G100/100/100 \
      -L0/0/0 -Ba2f0.5g2:,-"@+o@+"::"Slope":/a5f1g5:,-%:WeSn \
      -T2 -Z1 -Xc -Y17 -K -P > $outfile
   echo -n "2... "
   pshistogram $qhist_slope_area $proj ${inslope%.grd}.xyz -W0.57 \
      -G100/100/100 \
      -L0/0/0 -Ba2f0.5g2:,-"@+o@+"::"Slope":/a25f5g25:,-%:WeSn \
      -T2 -Q -Z1 -Y-13.5 -O >> $outfile
#   echo -n "direction histogram... "
##   psbasemap $qhist_slope_area $proj -Ba2f0.5g2:"Slope":/a25f5g25:,%:WeSn -O -Y-13.5 \
##      >> $outfile
#   pshistogram $hist_dir_area $proj ${indir%.grd}.xyz -W1 -G100/100/100 \
#      -L0/0/0 \
#      -Ba90f10g90:,-"@+o@+"::"Direction":/a1f0.2g1:,-%:WeSn \
#      -T2 -Z1 -Y-12 -O >> $outfile
   echo "done."
}

formats(){
   echo -n "convert output to jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q\
      -sOutputFile=${outfile%.ps}.jpg $outfile
   echo -n "and pdf... "
   ps2pdf -q -sPAPERSIZE=a4 $outfile ${outfile%.ps}.pdf
   echo "done."
}

#mkxyz # takes a very long time!
plot
formats

exit 0
