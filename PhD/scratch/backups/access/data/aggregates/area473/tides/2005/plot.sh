#! /bin/csh

gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set outfile=./images/tidal_times.ps
set nh_pred_in=./fortran/newhaven_05-06_pred_input.txt
set nh_pred_highs=./fortran/newhaven_05-06_pred_highs.txt
set nh_pred_picked=./fortran/newhaven_05-06_pred_picked.txt
set nh_obs_in=./fortran/newhaven_05-06_obs_input.txt
set nh_obs_highs=./fortran/newhaven_05-06_obs_highs.txt
set nh_obs_picked=./fortran/newhaven_05-06_obs_picked.txt

## top graph
# plot the newhaven predicted tidal curve data
set area1=-R2005-09-13T00:00/2005-09-23T00:00/0/8
# pred
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $nh_pred_highs | psxy $area1 -JX15cT/10 -W1/100/149/237 -K -P -Ba2Df1Dg1D:"Date":/a0.5f0.5g0.5WeSn:"Height (m) CD"::."Tidal Curves for Newhaven": -Xc -Y17 > $outfile
# obs
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $nh_obs_highs | psxy $area1 -JX15cT/10 -W1/220/0/0 -O -K -P >> $outfile

# plot the values it's picked out for newhaven pred and obs
# pred
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", "7.75"}' $nh_pred_picked | psxy $area1 -JX15cT/10 -W1/100/149/237 -O -K -Sx0.1 >> $outfile
# obs
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", "7.75"}' $nh_obs_picked | psxy $area1 -JX15cT/10 -W1/220/0/0 -O -K -Sx0.1 >> $outfile

## bottom graph
# plot the residual from my fortran program
set area2=-R2005-09-13T00:00/2005-09-23T00:00/0/8
# pred
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $nh_pred_picked | psxy $area2 -JX15cT/10 -W1/100/149/237 -O -K -Ba2Df1Dg1D:"Date":/a0.5f0.5g0.5WeSn:"Height (m) CD"::."Max Flood and Ebb tidal Heights": -Y-14 -Sp0.1 >> $outfile
# obs
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $nh_obs_picked | psxy $area2 -JX15cT/10 -W1/220/0/0 -O -K -Sp0.1 >> $outfile

# plot the values it's picked out
#awk '{print $1"-"$2"-"$3"T"$4":"$5":00", "3.75"}' $nh_pred_picked | psxy $area2 -JX15cT/10 -W1/100/149/237 -O -K -Sx0.1 >> $outfile
#awk '{print $1"-"$2"-"$3"T"$4":"$5":00", "3.75"}' $nh_obs_picked | psxy $area2 -JX15cT/10 -W1/220/0/0 -O -K -Sx0.1 >> $outfile

# add a key:

# set up the dimensions
set page=-R0/28/0/35
set a4=-JX28c/35c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0/0wesn -X-4 -Y-7.5 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
3.7 5.4 10 0.0 1 1 Newhaven Observed Tidal Curve
12.7 5.4 10 0.0 1 1 New Haven Predicted Tidal Curve
TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W -W2/220/0/0 << RED_LINE >> $outfile
2.7 5.5
3.2 5.5
RED_LINE
psxy $page $a4 -O -K -W -W2/220/0/0 -Sp0.1 << RED_DOT >> $outfile
2.95 5.5
RED_DOT
psxy $page $a4 -O -K -W -W2/100/149/237 << BLUE_LINE >> $outfile
11.7 5.5
12.2 5.5
BLUE_LINE
psxy $page $a4 -O -K -W -W2/100/149/237 -Sp0.1 << BLUE_DOT >> $outfile
11.95 5.5
BLUE_DOT

# display the image
gs -sPAPERSIZE=a4 $outfile

