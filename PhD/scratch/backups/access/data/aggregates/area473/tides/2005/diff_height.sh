#! /bin/csh

# script to plot a bar graph of the differences in height between each tidal peak and trough

gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set area=-R2005-09-14T00:00/2005-09-16T00:00/0/8
set proj=-JX23cT/13
set nh_obs=./fortran/newhaven_05-06_obs_picked.txt
set nh_pred=./fortran/newhaven_05-06_pred_picked.txt
set dov_obs=./fortran/dover_05-06_obs_picked.txt
set has_pred=./fortran/hastings_05-06_pred_picked.txt
set outfile=./images/height_diff.ps

psbasemap $area $proj -Bsa1D/0 -Bpa6-2Hf6Hg6H:"Date":/a1f0.5g0.25:"Height (m)":WeSn -K -Xc -Y5 > $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, $7}' $nh_pred | psxy $area $proj -W5/100/149/237 -O -K -Sb0.2 >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, $7}' $nh_obs | psxy $area $proj -W5/220/0/0 -O -K -Sb0.2 >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, $7}' $dov_obs | psxy $area $proj -W5/0/220/0 -O -K -Sb0.2 >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, $7}' $has_pred | psxy $area $proj -W5/0/0/220 -O -K -Sb0.2 >> $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile

