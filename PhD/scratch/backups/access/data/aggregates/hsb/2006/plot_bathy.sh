#!/bin/bash

# script to plot the 2007 hsb bathy, with illumination from the southwest

gmtset LABEL_FONT_SIZE 18
gmtset ANNOT_FONT_SIZE 18
gmtset D_FORMAT=%g

area=-R326074/331790/5621462/5625274
proj=-Jx0.0037
gres=-I1.5
infile=./raw_data/0803_Hastings_UTMZone31_Sept2006.xyz
outfile=./images/hsb_dredge_2006.ps

mkgrids()
{
   xyz2grd $area $infile $gres -G${infile%.xyz}.grd -H9
   grdgradient ${infile%.xyz}.grd -G${infile%.xyz}_grad.grd -Nt0.7 -A250
}

plot()
{
   makecpt -Cwysiwyg -T14/31/0.1 -Z -I > ./hsb.cpt
   gmtset D_FORMAT=%.0f
   grdimage $area $proj -K -C./hsb.cpt -Xc -Yc ${infile%.xyz}.grd \
      -Ba1000f500g1000:Eastings:/a1000f500g1000:Northings:WeSn \
      -I${infile%.xyz}_grad.grd \
      > $outfile
   psscale -D22.9/6.2/-6/0.5 -Ba5f1 -C./hsb.cpt -O -K >> $outfile
   pstext $area $proj -N -O << DEPTH >> $outfile
   332090 5624198 18 0 0 1 Depth (m)
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

#mkgrids
plot
formats

exit 0
