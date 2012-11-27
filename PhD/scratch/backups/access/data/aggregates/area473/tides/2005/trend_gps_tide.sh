#! /bin/csh -f

# script to try and fit a trend to the gps height data... optimistic I know...

gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set nr_infile=./export_gps_2005/nr203gps_formatted.txt
set nr_trend=./export_gps_2005/nr_trend_date.xy
set nh_obs=./2005NHA_sept.txt
set nr_times=./fortran/nr_trend_date_picked.txt_mod
set hpr_infile=./export_gps_2005/hpr300p_gps_formatted.txt
set hpr_trend=./export_gps_2005/hpr_trend_date.xy
set gps_area=-R2005-09-14T12:00/2005-09-22T12:00/45/62
set obs_area=-R2005-09-14T12:00/2005-09-22T12:00/-5/12
set gps_proj=-JX23cT/16
set outfile=./images/gps_trend.ps

# plot the gps points
psbasemap $gps_area $gps_proj -Bsa1D/0S -Bpa12Hf1Dg1D:"Date":/a2f1g2:"Height (m)":WSn -K -Xc -Yc > $outfile
awk '{if (NR%100==0) print $0}' $nr_infile | \
   psxy $gps_area $gps_proj -O -K -Sc0.1 -W1/0/200/0 >> $outfile
awk '{if (NR%100==0) print $0}' $hpr_infile | \
   psxy $gps_area $gps_proj -O -K -Sc0.1 -W1/150/0/0 >> $outfile

# calculate the trend
#trend1d -fioT -N50 -Fxym $nr_infile > $nr_trend
awk '{if (NR%10==0) print $0}' $nr_trend | \
   psxy $gps_area $gps_proj -O -K -G0/100/0 -W3/0/100/0 -Sc0.05 >> $outfile
#trend1d -fioT -N50 -Fxym $hpr_infile > $hpr_trend
awk '{if (NR%10==0) print $0}' $hpr_trend | \
   psxy $gps_area $gps_proj -O -K -G100/0/0 -W3/255/0/0 -Sc0.05 >> $outfile

# add on the times from the trend lines
#awk '{print $1"-"$2"-"$3"T"$4":"$5":00", $7}' $nr_times | psxy $gps_area $gps_proj -O -K -Sx1 -W1/0/0/255 >> $outfile

# add in the data from the observed tidal curve at newhaven for this time period
psbasemap $obs_area $gps_proj -Bp0/a2f1g2:"Height (m)":E -O -K >> $outfile
psxy $obs_area $gps_proj $nh_obs -O -K -G0/150/200 -W3/0/150/200 -Sc0.1 >> $outfile
psxy $obs_area $gps_proj $nh_obs -O -W1/0/150/200 >> $outfile

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
