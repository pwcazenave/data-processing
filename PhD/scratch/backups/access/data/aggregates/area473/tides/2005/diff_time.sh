#! /bin/csh

# script to plot a bar graph of the differences in time between each tidal peak and trough

gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set area=-R-1/8/2005-09-13T00:00/2005-09-23T00:00
set proj=-JX23/13cT
set nh_obs=./fortran/newhaven_05-06_obs_picked.txt
set nh_pred=./fortran/newhaven_05-06_pred_picked.txt
set dov_obs=./fortran/dover_05-06_obs_picked.txt
set has_pred=./fortran/hastings_05-06_pred_picked.txt
set outfile=./images/time_diff.ps

psbasemap $area $proj -B1WeSn -K -Xc -Y5 > $outfile
awk '{print $7, $1"-"$2"-"$3"T"$4":"$5":"$6}' $nh_pred | psxy $area $proj -W5/100/149/237 -O -K -Sp0.2 -fi1T >> $outfile
awk '{print $7, $1"-"$2"-"$3"T"$4":"$5":"$6}' $nh_obs | psxy $area $proj -W5/220/0/0 -O -K -Sp0.2 -fi1T >> $outfile
awk '{print $7, $1"-"$2"-"$3"T"$4":"$5":"$6}' $dov_obs | psxy $area $proj -W5/0/220/0 -O -K -Sp0.2 -fi1T >> $outfile
awk '{print $7, $1"-"$2"-"$3"T"$4":"$5":"$6}' $has_pred | psxy $area $proj -W5/0/0/220 -O -K -Sp0.2 -fi1T >> $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile
