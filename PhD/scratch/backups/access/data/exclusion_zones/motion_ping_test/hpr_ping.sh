#!/bin/csh -f

# script to check the heave, pitch and roll data recorded are not in conflict with the data recorded in the pings.

set heave_area=-R2006-09-11T17:18:30/2006-09-11T17:19:00/-0.16/0.18
set pings_area=-R2006-09-11T17:18:30/2006-09-11T17:19:00/-44.3/-41.3
set proj=-JX15cT/10

set hpr_input=./raw_data/old_files/0037_-_grid1_-_0001.motion.txt
set hpr_output=./raw_data/hpr_output.dat
set pings_input=./raw_data/old_files/0037_-_grid1_-_0001.seabat_8101.txt
set pings_output=./raw_data/pings_output.dat
set trend_output=./raw_data/pings_trend.dat
set outfile=./images/comparison.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_PRIMARY 12
gmtset COLOR_NAN 0/0/0

## pre-processing the data
# get rid of windows artefacts
#dos2unix $hpr_input
#dos2unix $pings_input

# sort the format for the heave
cat $hpr_input | tr "/:," " " | awk '{print $3"-"$2"-"$1"T"$4":"$5":"$6, $9}' | grep -v i > $hpr_output
# sort the fomat for the pings
cat $pings_input | tr "/:," " " | grep -v e | awk '{print $3"-"$2"-"$1"T"$4":"$5":"$6, $29}' > $pings_output

## plotting the graphs
# first one to check is the heave:
psbasemap $heave_area $proj -Ba5Cg1c/a0.1f0.05g0.025:"Heave (@+o@+)"::."Recorded heave from Ariel survey":WeSn -K -P -Xc -Y16 > $outfile
psxy $heave_area $proj -O -K -W1/40/10/220 $hpr_output >> $outfile

# then the pings:
psbasemap $pings_area $proj -Ba5Cg1c/a1f0.5g0.25:"Ping"::."Recorded ping from Ariel survey":WeSn -O -K -P -Y-13 >> $outfile
#trend1d $pings_output -fT -N40f -Fxm > $trend_output
psxy $pings_area $proj -O -K -W1/220/10/40 $pings_output >> $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile
