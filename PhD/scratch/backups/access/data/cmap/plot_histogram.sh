#!/bin/bash
#
# script to plot the distribution of depths for the English Channel based
# on the gebco bathy (highest res).
#

gmtset LABEL_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

infile=./raw_data/gebco_channel.xyz
infile=./raw_data/corrected_CMAP_bathy.xyz
outfile=./images/bathy_histogram.ps

area=-R-110/15/0/3
q_area=-R-110/15/0/100
proj=-JX16/10
q_proj=-JX16/10

conv(){
   grd2xyz ./gebco_bathy.grd > $infile
}

hist(){
   echo -n "plot the histogram... "
   # normal
#   awk '{print $1,$2,$3*-1}' $infile | \
   pshistogram $area $proj -Ba10f5:"Depth (m)":/a0.5f0.25:,%:WeSn -P \
      -L1 -G200/200/200 -T2 -Z1 -K -Xc -Y17 -W1 $infile > $outfile
   # cumulative histogram
#   awk '{print $1,$2,$3*-1}' $infile | \
   pshistogram $q_area $q_proj -Ba10f5:"Depth (m)":/a10f5:,%:WeSn \
      -L1 -G200/200/200 -T2 -Z1 -O -Q -W1 -Y-14 $infile >> $outfile
   echo "done."
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

#conv            # convert the gridded data to xyz
hist            # plot the histogram
formats         # convert the output

exit 0
