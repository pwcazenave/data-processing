#!/bin/csh -f

# script to plot the single beam record vs. the heave, pitch and roll records

##----------------------------------------------------------------------------##

## let's get the basics in
# i/o
set input=./raw_data/0018_-_473_E_W_6.txt
set outfile=./images/motion_single_beam_check.ps

# processing parameters
set area=-R2005-09-16T21:40/2005-09-16T21:41/-5/6
set area_single=-R2005-09-16T21:40/2005-09-16T21:41/-50/-45
set proj=-JX24cT/14

# some quick changes to input and output formats
gmtset INPUT_DATE_FORMAT dd-mm-yyyy
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm

##----------------------------------------------------------------------------##

# preprocess the data to get the format right:

# determine average value for a column to normalise it:
# heave
set heave_mean=`awk '{print $3}' $input | ./average.awk`
# pitch
set pitch_mean=`awk '{print $4}' $input | ./average.awk`
# roll
set roll_mean=`awk '{print $5}' $input | ./average.awk`
# single beam
set single_mean=`awk '{print $6}' $input | ./average.awk`

# plot the data
# heave - red
#awk '{print $1"T"$2, $3/'$heave_mean'}' $input | psxy $area $proj -Bpa5cf1cg5c/a0f1g2WS -Bs1M/0 -K -W1/200/50/0 > $outfile
awk '{print $1"T"$2, $3}' $input | psxy $area $proj -Bpa5cf1cg5c/a0f1g2WS -Bs1M/0:."Heave (red), pitch (green) and roll (blue) against single beam bathymetry (black) 16/09/2005": -K -W1/200/50/0 -Y3 > $outfile
# pitch - green
#awk '{print $1"T"$2, $4/'$pitch_mean'}' $input | psxy $area $proj -Bpa5cf1cg5c/a0f1g2WS -Bs1M/0 -O -K -W1/50/200/0 >> $outfile
awk '{print $1"T"$2, $4-2.5}' $input | psxy $area $proj -Bpa5cf1cg5c/a0f1g2WS -Bs1M/0 -O -K -W1/50/200/0 >> $outfile
# roll - blue
#awk '{print $1"T"$2, $5/'$roll_mean'}' $input | psxy $area $proj -Bpa5cf1cg5c/a0f1g2WS -Bs1M/0 -O -K -W1/0/50/200 >> $outfile
awk '{print $1"T"$2, $5}' $input | psxy $area $proj -Bpa5cf1cg5c/a0f1g2WS -Bs1M/0 -O -K -W1/0/50/200 >> $outfile
# single beam - black
#awk '{print $1"T"$2, $6/'$single_mean'}' $input |  psxy $area $proj -Bpa5cf1cg5c/a0f1g2WS -Bs1M/0 -O -K >> $outfile
awk '{print $1"T"$2, $6*-1}' $input |  psxy $area_single $proj -Bpa5cf1cg5c/a0f1ES -Bs1M/0 -O -G0/0/0 -Sc0.05 >> $outfile

##----------------------------------------------------------------------------##

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
