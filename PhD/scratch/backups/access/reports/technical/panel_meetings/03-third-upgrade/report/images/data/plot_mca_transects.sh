#!/bin/bash

# script to plot two transects taken through the mca bathy
# at the angles identified by the fft

area=-R0/200/-0.8/0.8
proj=-JX23/13

infile=./mca_profile.csv
outfile=./mca_profile.ps

gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18

psbasemap $area $proj -Xc -Yc -K \
   -Ba20:"Distance along line (m)":/a0.2:"Height (m)":WeSn > $outfile
cut -f3,4 -d, $infile | psxy $area $proj -W10/0/50/250 -O -K >> $outfile
cut -f3,5 -d, $infile | psxy $area $proj -W10/0/0/0 -O -K >> $outfile
awk -F, '{print $3,$5*-1}' $infile | \
   psxy $area $proj -W10/0/0/0 -O -K >> $outfile
cut -f3,6 -d, $infile | psxy $area $proj -W10/0/200/0 -O -K >> $outfile
awk -F, '{print $3,$6*-1}' $infile | \
   psxy $area $proj -W10/0/200/0 -O -K >> $outfile
cut -f3,7 -d, $infile | psxy $area $proj -W10/200/0/0 -O -K >> $outfile
awk -F, '{print $3,$7*-1}' $infile | \
   psxy $area $proj -W10/200/0/0 -O -K >> $outfile

#pstext $area $proj -N -O -K -D0.3/0.3 -WwhiteO0,white << ampM >> $outfile
#$(cut -f3,5 -d, $infile | head -n1 | tr "," " " ) 18 0 0 1 DFT Measured Amplitude
#ampM
#pstext $area $proj -N -O -K -D0.3/0.3 -G0/200/0 -WwhiteO0,white << ampM \
#   >> $outfile
#$(cut -f3,6 -d, $infile | sed -n '139p' | tr "," " " ) 18 0 0 1 Crest-Trough Analysis
#ampM
#pstext $area $proj -N -O -D0.3/0.3 -G200/0/0 -WwhiteO0,white << ampM \
#   >> $outfile
#$(cut -f3,7 -d, $infile | head -n1 | tr "," " " ) 18 0 0 1 Predicted Height (Flemming, 1988)
#ampM

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf || exit 1
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile || exit 1
   echo "done."
}

formats $outfile
