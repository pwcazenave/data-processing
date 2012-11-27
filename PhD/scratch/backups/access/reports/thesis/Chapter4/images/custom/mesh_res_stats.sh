#!/bin/bash

# Script to plot the results of the mesh analysis in Matlab and OpenOffice Calc.

gmtdefaults -D > .gmtdefaults4

gmtset ANNOT_FONT_SIZE_PRIMARY=18 LABEL_FONT_SIZE=18

proj=-JX26lc/18lc

infile=./raw_data/mesh_res_stats.txt

# make a directory for the output
if [ ! -d ./images ]; then
   mkdir ./images
fi

# add the predicted values to the raw data
# openoffice fit
awk '{print $1,$2,$3,$4,0.646*$2^2}' $infile > ${infile%.txt}_pred.txt
# libreoffice fit
#awk '{print $1,$2,$3,$4,1.24486*$2^0.49979}' $infile > ${infile%.txt}_pred.txt
# matlab curve fitting tool fit
#awk '{print $1,$2,$3,$4,0.3444*$2^2.062}' $infile > ${infile%.txt}_pred.txt


infileAdd=${infile%.txt}_pred.txt

area=$(awk '{print $2,$1/1000000}' $infileAdd | minmax -I5000)
area=-R100/35000/0.005/800

# plot the measured median side against the original input max area
# divide by a million to get km2 instead of m2. just for aesthetic resons.
awk '{print $2,$1/1000000}' $infileAdd | \
   psxy $area $proj -W5 -X3c -Y2.3c -K \
   -Ba1f3:"Median element side (m)":/a1f3:"Median element area (km@+2@+)":WeSn \
   > ./images/meshTestMeasuredSideInputArea.ps
# add symbols
awk '{print $2,$1/1000000}' $infileAdd | \
   psxy $area $proj -O -K -W3 -S+0.4 \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add the regression
awk '{print $2,$5/1000000}' $infileAdd | \
   psxy $area $proj -W5,black,- -B0 -O -K \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add symbols
awk '{print $2,$5/1000000}' $infileAdd | \
   psxy $area $proj -St0.4 -W3 -B0 -O -K \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add in the example for the latex figure
awk '{if ($1==2880000) print $2,$1/1000000}' $infileAdd | \
   psxy $area $proj -Ss0.6 -W3 -B0 -O -K \
   >> ./images/meshTestMeasuredSideInputArea.ps
# add in some text (the equations and r^2 values)
pstext $area $proj -O << TEXT >> ./images/meshTestMeasuredSideInputArea.ps
7000 350 16 0 0 1 y = 0.646x@+2@+
7000 200 16 0 0 1 R@+2@+ = 0.998
TEXT
# openoffice fit
#130 350 16 0 0 1 y = 0.646x@+2@+
#130 200 16 0 0 1 R@+2@+ = 0.998
# matlab fit (less good)
#130 350 16 0 0 1 y = 0.3444x@+2.062@+
#130 200 16 0 0 1 R@+2@+ = 0.9989

formats ./images/meshTestMeasuredSideInputArea.ps
