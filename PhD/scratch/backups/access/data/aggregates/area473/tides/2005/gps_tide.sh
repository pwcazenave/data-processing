#! /bin/csh

# script to plot the height from the gps recorded height

gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set gps_area=-R2005-09-13T00:00/2005-09-23T00:00/0/8
set gps_proj=-JX23cT/13
set nr_infile=./export_gps_2005/nr203gps_formatted.txt
set nr_trend=./export_gps_2005/nr_trend_date.xy
set nr_times=./fortran/nr_trend_date_picked.txt
set hpr_infile=./export_gps_2005/hpr300p_gps_formatted.txt
set hpr_trend=./export_gps_2005/hpr_trend_date.xy
set nh_obs_picked=./fortran/newhaven_05-06_obs_picked.txt
set nh_obs_highs=./fortran/newhaven_05-06_obs_highs.txt
set nh_pred_picked=./fortran/newhaven_05-06_pred_picked.txt
set nh_pred_highs=./fortran/newhaven_05-06_pred_highs.txt2
set dov_obs_highs=./fortran/dover_05-06_obs_highs.txt
set dov_obs_picked=./fortran/dover_05-06_obs_picked.txt
set has_pred_highs=./fortran/hastings_05-06_pred_highs.txt
set has_pred_picked=./fortran/hastings_05-06_pred_picked.txt
set outfile=./images/gps_tide_2005.ps

# get the basics in
psbasemap $gps_area $gps_proj -Bsa1D/0 -Bpa12Hf6Hg6H:"Date":/a2f1g1:"Height (m)":WeSn -K -Xc -Y5 > $outfile

# overlay the tidal curves
# newhaven predicted
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, $7}' $nh_pred_highs | psxy $gps_area $gps_proj -W1/100/149/237 -O -K -P >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, $7}' $nh_pred_highs | psxy $gps_area $gps_proj -W1/100/149/237 -O -K -P -Sp0.05 >> $outfile
# newhaven obs
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $nh_obs_highs | psxy $gps_area $gps_proj -W1/220/0/0 -O -K -P >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $nh_obs_highs | psxy $gps_area $gps_proj -W1/220/0/0 -O -K -P -Sp0.05 >> $outfile
# dover obs
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $dov_obs_highs | psxy $gps_area $gps_proj -W1/0/220/0 -O -K -P >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $dov_obs_highs | psxy $gps_area $gps_proj -W1/0/220/0 -O -K -P -Sp0.05 >> $outfile
# hastings predicted
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $has_pred_highs | psxy $gps_area $gps_proj -W1/0/0/220 -O -K -P >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $has_pred_highs | psxy $gps_area $gps_proj -W1/0/0/220 -O -K -P -Sp0.05 >> $outfile
# plot the gps heights
#awk '{if (NR%10==0) print $1, $2}' $nr_infile | psxy $gps_area $gps_proj -O -K -Sp0.01 -W1/34/139/34 >> $outfile
#awk '{if (NR%10==0) print $1, $2}' $hpr_infile | psxy $gps_area $gps_proj -Ba2Df1Dg1D:"Date":/a5f2.5g2.5:"Height (m)":WeSn -O -K -Sp0.01 -W1/139/34/34 >> $outfile

# plot the gps trends
#awk '{if (NR%50==0) print $1, ($2-51)}' $nr_trend | psxy $gps_area $gps_proj -O -K -W1/34/139/34 -Sp0.01 >> $outfile
#awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, $7}' $nr_trend | psxy $gps_area $gps_proj -O -K -W1/34/139/34 -Sp0.01 >> $outfile
#awk '{if (NR%50==0) print $1, $2}' $hpr_trend | psxy $gps_area $gps_proj -O -K -W1/139/34/34 -Sp0.01 >> $outfile


# plot the peak times from the fortran
# newhaven predicted
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", "7.5"}' $nh_pred_picked | psxy $gps_area $gps_proj -W1/100/149/237 -O -K -Sd0.2 -H1 >> $outfile
# newhaven obs
awk '{if ($2==9) print $1"-"$2"-"$3"T"$4":"$5":00", "7.5"}' $nh_obs_picked | psxy $gps_area $gps_proj -W1/220/0/0 -O -K -Sh0.2 -H1 >> $outfile
# dover obs
awk '{if ($2==9) print $1"-"$2"-"$3"T"$4":"$5":00", "7.5"}' $dov_obs_picked | psxy $gps_area $gps_proj -W1/0/220/0 -O -K -Sc0.2 -H1 >> $outfile
# nr gps
#awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, "7.5"}' $nr_times | psxy $gps_area $gps_proj -W1/34/139/34 -O -K -Sx0.3 >> $outfile
# hastings predicted
awk '{print $1"-"$2"-"$3"T"$4":"$5":00", "7.5"}' $has_pred_picked | psxy $gps_area $gps_proj -W1/0/0/220 -O -K -St0.2 -H1 >> $outfile

# add a key:

# set up the dimensions
set page=-R0/35/0/28
set a4=-JX35c/28c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0/0wesn -X-8 -Y-7 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
8.2 4.4 10 0.0 1 1 Newhaven Predicted
14.3 4.4 10 0.0 1 1 Newhaven Observed
20.2 4.4 10 0.0 1 1 Dover Observed
25.7 4.4 10 0.0 1 1 Hastings Predicted
TEXT

#pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
#11.7 4.4 10 0.0 1 1 Newhaven Predicted
#17.2 4.4 10 0.0 1 1 Newhaven Observed
#22.7 4.4 10 0.0 1 1 Dover Observed
#TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W -W2/100/149/237 -Sd0.3 << BLUE_DOT >> $outfile
7.7 4.53
BLUE_DOT
psxy $page $a4 -O -K -W -W2/220/0/0 -Sh0.3 << RED_DOT >> $outfile
13.7 4.53
RED_DOT
psxy $page $a4 -O -K -W -W2/0/220/0 -Sc0.3 << GREEN_DOT >> $outfile
19.7 4.53
GREEN_DOT
psxy $page  $a4 -O -K -W -W2/0/0/220 -St0.3 << BLUE_DOT >> $outfile
25.2 4.53
BLUE_DOT

# plot the lines for the key
psxy $page $a4 -O -K -W -W1/100/149/237 << BLUE_LINE >> $outfile
7.2 4.53
7.7 4.53
BLUE_LINE
psxy $page $a4 -O -K -W -W1/220/0/0 << RED_LINE >> $outfile
13.2 4.53
13.7 4.53
RED_LINE
psxy $page $a4 -O -K -W -W1/0/220/0 << GREEN_LINE >> $outfile
19.2 4.53
19.7 4.53
GREEN_LINE
psxy $page $a4 -O -W -W1/0/0/220 << BLUE_LINE >> $outfile
24.7 4.53
25.2 4.53
BLUE_LINE

# display the image
gs -sPAPERSIZE=a4 $outfile
