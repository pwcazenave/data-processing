#!/bin/bash

# script to plot two transects taken through the invincible bathy
# at the angles identified by the fft

area=-R0/105/-0.8/0.8
proj=-JX23/13

trans4=./invincible_zTrans4.xy
trans5=./invincible_zTrans5.xy
ampM=./invincible_ampM.xy
rms=./invincible_rms.xy
flemming=./invincible_flemming.xy

outfile=./images/invincible_trans.ps

psbasemap $area $proj -Xc -Yc -K \
   -Ba20g20:"Distance along line (m)":/a0.2g0.2:"Height (m)":WeSn > $outfile
psxy $area $proj -W8/150/0/50 $trans4 -O -K >> $outfile
psxy $area $proj -W8/50/0/150 $trans5 -O -K >> $outfile
psxy $area $proj -W8/0/0/0 $ampM -O -K >> $outfile
awk '{print $1,$2*-1}' $ampM | \
   psxy $area $proj -W8/0/0/0 -O -K >> $outfile
psxy $area $proj -W8/0/200/0 $rms -O -K >> $outfile
awk '{print $1,$2*-1}' $rms | \
   psxy $area $proj -W8/0/200/0 -O -K >> $outfile
psxy $area $proj -W8/200/0/0 $flemming -O -K >> $outfile
awk '{print $1,$2*-1}' $flemming | \
   psxy $area $proj -W8/200/0/0 -O -K >> $outfile

pstext $area $proj -N -O -K -D0.3/0.3 -WwhiteO0,white << ampM >> $outfile
$(head -n1 $ampM) 16 0 0 1 DFT Measured Amplitude
ampM
pstext $area $proj -N -O -K -D0.3/0.3 -G0/200/0 -WwhiteO0,white << ampM \
   >> $outfile
$(head -n1 $rms) 16 0 0 1 Root Mean Square
ampM
pstext $area $proj -N -O -D0.3/0.3 -G200/0/0 -WwhiteO0,white << ampM \
   >> $outfile
$(head -n1 $flemming) 16 0 0 1 Predicted Height (Flemming, 1988)
ampM

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $outfile
   echo "done."
}

formats $outfile
