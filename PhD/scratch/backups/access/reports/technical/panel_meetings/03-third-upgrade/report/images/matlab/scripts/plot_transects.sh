#!/bin/bash

# script to plot two transects taken through the mca bathy
# at the angles identified by the fft

infile=../"$1"_profile_weighted.csv
infile=../"$1"_profile_ifft.csv
results=../"$1"_heights.csv
outfile=./images/$(basename ${infile%.*}.ps)
area=$(cut -f3,4 -d, $infile | minmax -I0.1)
proj=-JX23/13

gmtset ANNOT_FONT_SIZE=20 LABEL_FONT_SIZE=22

psbasemap $area $proj -Xc -Yc -K \
   -Ba20:"Distance along line (m)":/a0.2:"Height (m)":WeSn > $outfile
# profile
cut -f3,4 -d, $infile | psxy $area $proj -W7 -O -K >> $outfile
# heights
# flat top
#cut -f1,2 -d, $results | psxy $area $proj -W7,-. -O -K >> $outfile
#awk -F, '{print $1,$2*-1}' $results | \
#   psxy $area $proj -W7,-. -O -K >> $outfile
# 2nd deriv 1-D
#cut -f1,3 -d, $results | psxy $area $proj -W7,0/20/0,- -O -K >> $outfile
#awk -F, '{print $1,$3*-1}' $results | \
#   psxy $area $proj -W7,0/20/0,- -O -K >> $outfile
# 2nd deriv 2-D
#cut -f1,4 -d, $results | psxy $area $proj -W7,20/0/0,.- -O -K >> $outfile
#awk -F, '{print $1,$4*-1}' $results | \
#   psxy $area $proj -W7,20/0/0,.- -O -K >> $outfile
# zero crossing 2-D
#cut -f1,6 -d, $results | psxy $area $proj -W7,150/150/0 -O -K >> $outfile
#awk -F, '{print $1,$6*-1}' $results | \
#   psxy $area $proj -W7,150/150/0 -O -K >> $outfile
# 2nd deriv Butterworth
#cut -f1,7 -d, $results | psxy $area $proj -W7,200/150/0 -O -K >> $outfile
#awk -F, '{print $1,$7*-1}' $results | \
#   psxy $area $proj -W7,200/150/0 -O -K >> $outfile
# zero crossing Butterworth
cut -f1,8 -d, $results | psxy $area $proj -W7,. -O -K >> $outfile
awk -F, '{print $1,$8*-1}' $results | \
   psxy $area $proj -W7,. -O -K >> $outfile
# Flemming
#cut -f1,9 -d, $results | psxy $area $proj -W7,128/128/128 -O -K >> $outfile
#awk -F, '{print $1,$9*-1}' $results | \
#   psxy $area $proj -W7,128/128/128 -O -K >> $outfile
# rms
#cut -f1,10 -d, $results | psxy $area $proj -W7,0/255/0 -O -K >> $outfile
#awk -F, '{print $1,$10*-1}' $results | \
#   psxy $area $proj -W7,0/255/0 -O >> $outfile

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
