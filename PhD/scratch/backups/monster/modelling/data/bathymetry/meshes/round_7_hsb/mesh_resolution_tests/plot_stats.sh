#!/bin/bash

# Script to plot the results of the mesh analysis in Matlab and OpenOffice Calc.

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

gmtset ANNOT_FONT_SIZE_PRIMARY=18 LABEL_FONT_SIZE=18

proj=-JX22l/16

infile=./raw_data/mesh_res_stats.txt

# make a directory for the output
if [ ! -d ./images ]; then
   mkdir ./images
fi

# add the predicted values to the raw data
# openoffice fit
#awk '{print $1,$2,$3,$4,0.646*$2^2}' $infile > ${infile%.txt}_pred.txt
# matlab curve fitting tool fit
awk '{print $1,$2,$3,$4,0.3444*$2^2.062}' $infile > ${infile%.txt}_pred.txt


infileAdd=${infile%.txt}_pred.txt

area=$(awk '{print $2,$1/1000000}' $infileAdd | minmax -I5000)
area=-R100/35000/0/800

# plot the measured median side against the original input max area
# divide by a million to get km2 instead of m2. just for aesthetic resons.
awk '{print $2,$1/1000000}' $infileAdd | \
   psxy $area $proj -W10/0/50/200 -Xc -Yc -K \
   -Ba1f3g1:"Median Element Side (m)":/a100f20g100:"Median Element Area (km@+2@+)":WeSn \
   > ./images/meshTestMeasuredSideInputArea.ps
# add symbols
awk '{print $2,$1/1000000}' $infileAdd | \
   psxy $area $proj -G0/50/200 -O -K -Sc0.4 \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add the regression
awk '{print $2,$5/1000000}' $infileAdd | \
   psxy $area $proj -W10/200/0/50 -B0 -O -K \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add symbols
awk '{print $2,$5/1000000}' $infileAdd | \
   psxy $area $proj -G200/0/50 -Ss0.4 -B0 -O -K \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add in the example for the latex figure
awk '{if ($1==2880000) print $2,$1/1000000}' $infileAdd | \
   psxy $area $proj -W10/0/200/50 -Sc0.6 -B0 -O -K \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add in some text (the equations and r^2 values)
pstext $area $proj -O << TEXT >> ./images/meshTestMeasuredSideInputArea.ps
130 760 18 0 0 1 y = 0.3444x@+2.062@+
130 720 18 0 0 1 R@+2@+ = 0.9989
TEXT

formats ./images/meshTestMeasuredSideInputArea.ps
