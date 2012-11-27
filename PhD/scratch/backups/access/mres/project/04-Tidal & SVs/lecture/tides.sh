#!/bin/csh -f

# script to plot the predicted, observed, and hopefully the GPS tide for the Hastings Shingle Bank survey.

# let's get it on...

gmtset MEASURE_UNIT cm
gmtset ANNOT_FONT_SIZE 10p
gmtset LABEL_FONT_SIZE 12p
gmtset HEADER_FONT_SIZE 16p
gmtset ANNOT_FONT_SIZE_SECONDARY 10p
gmtset PLOT_CLOCK_FORMAT hh:mm

set area=-R2005-06-27T00:00/2005-07-07T00:00/0/8
set proj=-JX25cT/14
set pred=./raw_data/pred.txt
set obs=./raw_data/obs.txt
set gps=./raw_data/gps3.txt
set gps1=./raw_data/1.txt
set gps2=./raw_data/2.txt
set gps3=./raw_data/3.txt
set outfile=./images/tides.ps

# start plotting the data:
psbasemap $area $proj -Bsa1Dg1D/0 -Bpa12H/1f0.5g1:"Height (m)"::."Tidal Curves for Hastings relative to Chart Datum":WeSn -K -Xc -Y4 > $outfile
psxy $area $proj -O -K -W1/200/0/0 $pred >> $outfile #red pred line
psxy $area $proj -O -K -Sc0.05 -W1/200/0/0 $pred >> $outfile #red pred dots

psxy $area $proj -O -K -W1/0/0/200 $obs >> $outfile #blue obs line
psxy $area $proj -O -K -Sc0.05 -W1/0/0/200 $obs >> $outfile #blue obs dots

#psxy $area $proj -O -K -W1/0/200/0 $gps >> $outfile #green obs line
#psxy $area $proj -O -K -Sc0.05 -W1/0/200/0 $gps >> $outfile #green obs dots

psxy $area $proj -O -K -W1/0/200/0 $gps1 >> $outfile #green obs line
psxy $area $proj -O -K -Sc0.05 -W1/0/200/0 $gps >> $outfile #green obs dots
psxy $area $proj -O -K -W1/0/200/0 $gps2 >> $outfile #green obs line
psxy $area $proj -O -K -Sc0.05 -W1/0/200/0 $gps >> $outfile #green obs dots
psxy $area $proj -O -K -W1/0/200/0 $gps3 >> $outfile #green obs line
psxy $area $proj -O -K -Sc0.05 -W1/0/200/0 $gps >> $outfile #green obs dots

# add a key:

# set up the dimensions
set page=-R0/35/0/28
set a4=-JX35c/28c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0/0wesn -X-3 -Y-5 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
7 3 10 0.0 1 1 Predicted Tidal Curve
13 3 10 0.0 1 1 Observed Tidal Curve
19 3 10 0.0 1 1 GPS Height
TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W -W1/0/0/200 << BLUE_LINE >> $outfile
6 3.1
6.5 3.1
BLUE_LINE
psxy $page $a4 -O -K -W -W1/200/0/0 << RED_LINE >> $outfile
12 3.1
12.5 3.1
RED_LINE
psxy $page $a4 -O -K -W -W1/0/200/0 << GREEN_LINE >> $outfile
18 3.1
18.5 3.1
GREEN_LINE

# view the image
gs -sPAPERSIZE=a4 $outfile

