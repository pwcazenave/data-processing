#!/bin/bash

# script to subtract the 2007 grid from the 2006 grid. the output file names
# are indicative of which was subtracted from which; the second name was
# subtracted from the first. that's why there are generally two sets of each
# processing command.

gmtset D_FORMAT=%g
gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18

area=-R326074/331790/5621462/5625274
proj=-Jx0.0037

hsb06=../2006/raw_data/0803_Hastings_UTMZone31_Sept2006.grd
hsb07=../2007/raw_data/0863_Hastings_1m_UTMZone31_Aug2007.grd

outfile=./images/hsb_06-07_diff.ps

mkdiff(){
   grdmath $hsb06 $hsb07 SUB = ./grids/hsb_06-07_diff.grd
}

plot(){
   #makecpt -T-50/50/0.1 -Z -Cwysiwyg > ./diff.cpt
   grd2cpt ./grids/hsb_06-07_diff.grd $area -Cwysiwyg > ./diff.cpt

   # plot the image
   gmtset D_FORMAT=%.0f
   grdimage $area $proj ./grids/hsb_06-07_diff.grd \
      -Ba1000f500g1000:Eastings:/a1000f500g1000:Northings:WeSn \
      -C./diff.cpt -K -Xc -Yc > $outfile

   # add a coastline for the area
#   pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K \
#      -N1/255/255/255 -W1/255/255/255 >> $outfile

   # add the scale in
   psscale -D22.5/6.2/6/0.5 -Ba1f0.2 -C./diff.cpt -O -K >> $outfile
   pstext $area $proj -N -O << DEPTH >> $outfile
   331840 5624198 18 0 0 1 Difference (m)
DEPTH
}

formats()
{
   echo -n "converting $outfile to pdf "
   ps2pdf -sPAPERSIZE=a4 -q "$outfile" "${outfile%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile"
   echo "done."
}

#mkdiff
plot
formats

exit 0
