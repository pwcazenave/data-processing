#! /bin/csh

# script to plot the difference values from the total fortan output

gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set area=-R2005-09-13T00:00/2005-09-23T00:00/-1/1
set proj=-JX23cT/13
set dover_obs=./fortran/dover_05-06_obs_highs.txt
set nh_obs=./fortran/newhaven_05-06_obs_highs.txt
set nh_pred=./fortran/newhaven_05-06_pred_highs.txt
set outfile=./images/residual_sign.ps

# get the basics in
psbasemap $area $proj -Ba1Df12hg12h:"Date":/a2f1g1:"Height (m)":WeSn -K -Xc -Y5 > $outfile

# print the sign values
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $8}' $dover_obs | psxy $area $proj -O -K -Ba1Df12hg12h:"Date":/a2f1g1:"Height (m)":WeSn -W1/255/0/0 >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $8}' $nh_obs | psxy $area $proj -O -K -W1/0/255/0 >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $8}' $nh_pred | psxy $area $proj -O -K -W1/0/0/255 >> $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile
