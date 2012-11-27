#!/bin/bash

# script to plot the matlab analysis results

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset PAPER_MEDIA=a4

area=-R578106/588473/91505/98705
harea=-R0/179.99/0.001/10
pfact=0.00215
proj=-Jx$pfact
hproj=-JX6/3.75
gres=-I1

infile=../hsb_2005_300m_subset_results.csv
outfile=./images/$(basename ${infile%.*}_vectors.ps)
grd=./grids/all_lines_blockmedian_1m.grd
grad=./grids/all_lines_blockmedian_1m_grad.grd
cpt=./cpts/all_lines_blockmedian_1m.cpt

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
#   echo -n "and jpeg... "
#   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
#      -sOutputFile=${1%.ps}.jpg $outfile
   echo "done."
}

plot(){
   gmtset D_FORMAT=%.0f
   psbasemap $area $proj -Xc -Yc -K \
      -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn > $outfile
   grdimage $area $proj -O -K $grd -C$cpt -I$grad -B0 >> $outfile
   psscale -D23.2/8/7/0.5 -B10:"Depth (m)": -C$cpt -I -O -K >> $outfile
   awk -F, '{print $1,$2,$4,0.5*(log($3)/log(10))}' $infile | \
      psxy $area $proj -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $outfile
   # add in a key
   echo "578750 98250 90 20" | awk '{print $1,$2,$3,0.5*(log($4)/log(10))}' | \
      psxy $area $proj -O -K -SVb0/0/0 -W5 -Gblack >> $outfile
   pstext $area $proj -O -K -D0.75/-0.15 -WwhiteO0,white << LABEL >> $outfile
   578750 98250 14 0 0 1 20 m wavelength
LABEL
   pshistogram $harea $hproj $infile -W5 -Ggray -L1 -O -T3 -Z1 \
      -Ba45f10:,"-@+o@+":/a5f1:,"-%":WN -X16.25 -Y0.03 >> $outfile
   formats $outfile

}

plot
