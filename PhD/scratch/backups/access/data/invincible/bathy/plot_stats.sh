#!/bin/bash
#
# script to plot the stats for the gridding of the invincible data
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

infile=./raw_data/invincible_solent.txt
image=./images/invincible_stats.ps
histogram=./images/invincible_histogram.ps

area=-R638250/638560/5622600/5622780
hist_area=-R0/30/0/25
proj=-Jx0.07
hist_proj=-JX10

mkstats(){
   xyz2grd $area $infile -I0.2 -An -G./grids/invincible_stats.grd
}

plotgrd(){
   grd2cpt $area ./grids/invincible_stats.grd -Crainbow -Z -L0/25 > stats.cpt
   gmtset D_FORMAT %.0f
      grdimage $area $proj ./grids/invincible_stats.grd -Xc -Yc -K -Cstats.cpt \
      -Ba50f25g50:"Eastings":/a50f25g50:"Northings":WeSn \
      > $image
   psscale -D23/5.5/5/0.5 -B5 -Cstats.cpt -O -K >> $image
   pstext -N $area $proj -O << TEXT >> $image
   638575 5622725 12 0 0 1 Soundings
TEXT
   gmtset D_FORMAT %g

}

mkhist(){
   grd2xyz $area ./grids/invincible_stats.grd -S | \
      awk '{print $3}' > ./grids/invincible_histogram.xyz
}

plothist(){
   pshistogram $hist_area $hist_proj ./grids/invincible_histogram.xyz \
      -Ba10f2.5g5:"Soundings per bin":/a5f2.5:,%:WeSn \
      -L1/0/0/0 -G0/100/200 -P -W1 -Xc -Yc -Z1 > $histogram
}

formats() {
   echo -n "convert the images to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$histogram" \
      "${histogram%.ps}.pdf" &> /dev/null
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$image" \
      "${image%.ps}.pdf" &> /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${histogram%.ps}.jpg" \
      "$histogram" &> /dev/null
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" &> /dev/null
   echo "done."
}

#mkstats                 # count the number of soundings per bin
plotgrd                 # plot the grid file
#mkhist                  # convert the grid file to xyz
plothist                # plot the binning density 3rd column as a histogram
formats                 # convert the output

exit 0
