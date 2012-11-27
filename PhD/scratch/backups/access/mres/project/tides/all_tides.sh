#! /bin/csh

# script to plot 4 tidal curves for the same area (Hastings Shingle Bank) during the same time period (the time during which the bathymetry survey was conducted: end of June 2005 - beginning of July 2005)

# just setting up the .gmtdefaults file how I like it...

gmtset MEASURE_UNIT cm
gmtset ANNOT_FONT_SIZE 10p
gmtset LABEL_FONT_SIZE 12p
gmtset HEADER_FONT_SIZE 16p
gmtset ANNOT_FONT_SIZE_SECONDARY 10p

# need to do a bit of housework on the input files:

#-----------------------------------------------------------------------------#

# raw data variables:
set adcp_site2_raw=Site2_Data.txt
set adcp_site3_raw=Site3_Data.txt
set utec_raw=534A_text.txt

# processed data variables:
set adcp_site2_formatted=adcp_site2_formatted
set adcp_site2=adcp_site2
set adcp_site3_formatted=adcp_site3_formatted
set adcp_site3=adcp_site3
set obs=utec_observed_formatted
set pred=utec_predicted_formatted
set obs_file=utec_observed
set pred_file=utec_predicted

# output files:
set output=tides.ps

#-----------------------------------------------------------------------------#

# adcp data:

# cut the correct columns from the adcp data and format accordingly
# site2 data:
grep -v D $adcp_site2_raw | awk '{print $2, $3}' > site2_date.tmp
grep -v D $adcp_site2_raw | awk '{printf "%2.2f\n", (($19+$20)-25.5)}' > site2_depth.tmp
paste site2_date.tmp site2_depth.tmp > $adcp_site2_formatted

# format the date column in the correct manner (yyy-mm-ddThh:mm:ss):
awk -F/ '{print $1, $2, $3, $4}' $adcp_site2_formatted | awk '{printf "%4s-%2s-%2sT%8s %2.2f\n", $3, $2, $1, $4, $5}' > $adcp_site2

# site3 data:
grep -v D $adcp_site3_raw | awk '{print $2, $3}' > site3_date.tmp
grep -v D $adcp_site3_raw | awk '{printf "%2.2f\n", (($19+$20)-31.1)}' > site3_depth.tmp
paste site3_date.tmp site3_depth.tmp > $adcp_site3_formatted

# format the date column in the correct manner (yyy-mm-ddThh:mm:ss):
awk -F/ '{print $1, $2, $3, $4}' $adcp_site3_formatted | awk '{printf "%4s-%2s-%2sT%8s %2.2f\n", $3, $2, $1, $4, $5}' > $adcp_site3

# clean up
\rm *.tmp
#\rm *_formatted

#-----------------------------------------------------------------------------#

# utec data:

# extracting the correct columns from the utec raw data textfile (534A_text.txt)
# need to remove the negative depth values from the observed tidal curve data, hence the grep statement
cat $utec_raw | grep -v D | grep -v - | awk '{print $1, $2, $12}' > $obs
#cat $utec_raw | grep -v D | awk '{print $14, $15, $18}' > $pred

# format the output to the necessary format to be plotted in psxy (yyy-mm-ddThh:mm)
#awk -F/ '{print $1, $2, $3, $4}' $obs | awk '{printf "%4s-%2s-%2sT%5s %2.2f\n", $3, $2, $1, $4, $5}' > $obs_file
#awk -F/ '{print $1, $2, $3, $4}' $pred | awk '{printf "%4s-%2s-%2sT%5s %2.2f\n", $3, $2, $1, $4, $5}' | grep -v 0.00 > $pred_file

#-----------------------------------------------------------------------------#

# ahh, sod that: just use psxy to plot the date from the original file:

# something of the order of this should do the trick for the basemap:
# plotting the data

# setting the input format to match that of the data
gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full

# setting the output date format to match that of the input date format
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set area=-R2005-06-26T00:00/2005-07-08T00:00/-8/8
set proj=-JX15cT/10

# top graph
psbasemap $area $proj -Ba2Dg1D/1f0.5g1:"Height (m)"::."Tidal Curves for Hastings relative to Chart Datum":WeSn -K -P -Xc -Y16 > $output
psxy $area $proj -O -K -W1/255/0/0 $adcp_site2 >> $output #red
psxy $area $proj -O -K -W1/0/255/0 $adcp_site3 >> $output #green
psxy $area $proj -O -K -W1/0/0/255 $obs_file >> $output #blue
psxy $area $proj -O -K -W1/0/0/0 $pred_file >> $output #black

# add a key:

# set up the dimensions
set page=-R0/28/0/35
set a4=-JX28c/35c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0/0wesn -X-4 -Y-16 >> $output
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $output
4 14 10 0.0 1 1 Site 2 ADCP Observed Tidal Curve
4 13.5 10 0.0 1 1 Site 3 ADCP Observed Tidal Curve
13 14 10 0.0 1 1 UTEC Observed Tidal Curve
13 13.5 10 0.0 1 1 UTEC Predicted Tidal Curve
TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W -W1/0/255/0 << GREEN_LINE >> $output
3.2 13.6
3.7 13.6
GREEN_LINE
psxy $page $a4 -O -K -W -W1/255/0/0 << RED_LINE >> $output
3.2 14.1
3.7 14.1
RED_LINE
psxy $page $a4 -O -K -W -W1/0/0/255 << BLUE_LINE >> $output
12.2 13.6
12.7 13.6
BLUE_LINE
psxy $page $a4 -O -K -W -W1/0/0/0 << BLACK_LINE >> $output
12.2 14.1
12.7 14.1
BLACK_LINE

# bottom left-hand graph
set bl_proj=-JX7cT/7.5
set bl_area=-R2005-06-30T00:00/2005-07-01T00:00/0/8

psbasemap $bl_area $bl_proj -Bs1D/0 -Bpa6Hf3Hg1H/1f0.5g1:"Height (m)":WeSn -O -K -P -X2 -Y4.3 >> $output
psxy $bl_area $bl_proj -O -K -W1/255/0/0 $adcp_site2 >> $output #red
psxy $bl_area $bl_proj -O -K -W1/0/255/0 $adcp_site3 >> $output #green
psxy $bl_area $bl_proj -O -K -W1/0/0/255 $obs_file >> $output #blue
psxy $bl_area $bl_proj -O -K -W1/0/0/0 $pred_file >> $output #black

# bottom right-hand graph
set br_proj=-JX7cT/7.5
set br_area=-R2005-06-30T09:00/2005-06-30T15:01/0/8

psbasemap $br_area $br_proj -Bs1D/0 -Bpa60Mf30Mg10M/1f0.5g1:"Height (m)":WeSn -O -K -P -X10 >> $output
psxy $br_area $br_proj -O -K -W1/255/0/0 $adcp_site2 >> $output #red
psxy $br_area $br_proj -O -K -W1/0/255/0 $adcp_site3 >> $output #green
psxy $br_area $br_proj -O -K -W1/0/0/255 $obs_file >> $output #blue
psxy $br_area $br_proj -O -W1/0/0/0 $pred_file >> $output #black

# view the image
gs -sPAPERSIZE=a4 $output
#ps2pdf $output tides.pdf
