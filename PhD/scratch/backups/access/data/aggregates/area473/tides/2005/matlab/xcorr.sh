#!/bin/csh -f

# script to plot the ouput of the matlab cross-correlation and
# the amplitude difference

##----------------------------------------------------------------------------##

# what it looks like
set tide_area=-R2005-09-12T23:15:00/2005-09-27T00:45:00/-1/8
#set xcorr_area=-R-1300/1300/-5000/5000
set xcorr_area=-R-1300/1300/-1.1/1.1
set proj=-JX8/5

# labelling etc.
gmtset ANNOT_FONT_SIZE 8p
gmtset LABEL_FONT_SIZE 10p
gmtset HEADER_FONT_SIZE 10p
gmtset HEADER_OFFSET 0c
gmtset ANNOT_FONT_SIZE_SECONDARY 8p
gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full

# i/o
# time
set time=./raw_data/time.dat
set x_time=./raw_data/x_time.dat
# tides
set nh_obs=./raw_data/newhaven.dat
set nh_pre=./raw_data/w_newhaven.dat
set do_obs=./raw_data/dover.dat
set ha_pre=./raw_data/hastings.dat
# cross-correlation output
set nh_nh_corr=./raw_data/norm_nh_nh.asc
set nh_do_corr=./raw_data/norm_nh_do.asc
set nh_ha_corr=./raw_data/norm_nh_ha.asc
# set amplitude input files
set nh_nh_amp=./raw_data/amp_nh_nh.asc
set nh_do_amp=./raw_data/amp_nh_do.asc
set nh_ha_amp=./raw_data/amp_nh_ha.asc
# set outputs
set outfile=./images/xcorr.ps

##----------------------------------------------------------------------------##

# newhaven newhaven
psbasemap  $tide_area $proj -Ba4Dg1D:"Date":/a1f0.5g1:"Height (m) CD"::."2005 Newhaven Observed and Predicted Tidal Curves":WeSn -K -P -X2 -Y21 > $outfile
paste $time $nh_obs | \
	psxy $tide_area $proj -B0 -O -K -W2/200/50/0 >> $outfile
paste $time $nh_pre | \
	psxy $tide_area $proj -B0 -O -K -W2/0/50/200 >> $outfile
# plot the cross-correlation output
paste $x_time $nh_nh_corr | \
	psxy $xcorr_area $proj -Ba500f250g500h:"Time":/a0.2f0.1g0.2:."Normalised Repeatability of Tidal Curve Data":WeSn -O -K -W2/0/50/200 -X10 >> $outfile

##----------------------------------------------------------------------------##

# newhaven dover
psbasemap  $tide_area $proj -Ba4Dg1D:"Date":/a1f0.5g1:"Height (m) CD"::."2005 Newhaven and Dover Observed Tidal Curves":WeSn -O -K -P -X-10 -Y-8.5 >> $outfile
paste $time $nh_obs | \
	psxy $tide_area $proj -B0 -O -K -W2/200/50/0 >> $outfile
paste $time $do_obs | \
	psxy $tide_area $proj -B0 -O -K -W2/0/50/200 >> $outfile
# plot the cross-correlation output
paste $x_time $nh_do_corr | \
	psxy $xcorr_area $proj -Ba500f250g500h:"Time":/a0.2f0.1g0.2:."Normalised Repeatability of Tidal Curve Data":WeSn -O -K -W2/0/50/200 -X10 >> $outfile

##----------------------------------------------------------------------------##

# newhaven hastings
psbasemap  $tide_area $proj -Ba4Dg1D:"Date":/a1f0.5g1:"Height (m) CD"::."2005 Newhaven Observed and Hastings Predicted Tidal Curves":WeSn -O -K -P -X-10 -Y-8.5 >> $outfile
paste $time $nh_obs | \
	psxy $tide_area $proj -B0 -O -K -W2/200/50/0 >> $outfile
paste $time $ha_pre | \
	psxy $tide_area $proj -B0 -O -K -W2/0/50/200 >> $outfile
# plot the cross-correlation output
paste $x_time $nh_ha_corr | \
	psxy $xcorr_area $proj -Ba500f250g500h:"Time":/a0.2f0.1g0.2:."Normalised Repeatability of Tidal Curve Data":WeSn -O -K -W2/0/50/200 -X10 >> $outfile

##----------------------------------------------------------------------------##

# display the output
kghostview $outfile >/dev/null
gs -sPAPERSIZE=a4 -sDEVICE=jpeg -r200 -dBATCH -dNOPAUSE -sOutputFile=./images/xcorr.jpg $outfile >/dev/null
