#! /bin/csh

# script to check the offset values for the timing error in the utec survey data

#------------------------------------------------------------------------------#

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_SECONDARY 12

#------------------------------------------------------------------------------#

set off_area=-R0/2775/-30/0
set area1=-R0/1200/-26/-14
set proj1=-JX16/10
set area2=-R0/260/-35/-15 
set proj2=-JX16/10
set map_area=-R0.5922/0.5981/50.726/50.7342
set map_proj=-JM2

set outfile=offsets.ps

#------------------------------------------------------------------------------#

psbasemap $off_area $proj1 -Ba400f100g100:"Distance along line (m)":/a2f1g1WeSn:"Depth (m) CD"::."Hastings Shingle Bank Transect": -Xc -Y15 -P -K >! $outfile

# restore it to the original script (naughty naughty - should have copied this instead of modifying it...
awk '{print $1, $4}' 03.07.05_offsets.pts | psxy $off_area $proj1 -O -K -H2 -W1/255/0/0 >> $outfile

# plot my transect taken from rob's coordinates
#awk '{print $1, $4}' from_robs_coords.pts | psxy $area1 $proj1 -O -K -H2 -W1/255/0/0 >> $outfile

# plot rob's data (that which he sent)
#cat robs_data.pts | grep -v class | tr "," " " | tr "<br />" " " | awk '{print $2, $7}' > tmp
#psxy $area1 $proj1 -O -K -W1/0/200/0 tmp >> $outfile

# add in a little map of the coordinates from robs_data.pts showing his transect
#cat robs_data.pts | grep -v class | tr "," " " | tr "<br />" " " | awk '{print $3, $4}' > tmp2
#psbasemap $map_area $map_proj -O -K -X14 -Ba0.001f0.0005g0.0005 >> $outfile
#psxy $map_area $map_proj -O -K -W1/0/0/150 tmp2 >> $outfile


#------------------------------------------------------------------------------#

# need to add in the tidal curves for the relevant days...

# some housework,,,
gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set tide_data=~/scratch/project/tides/utec_observed
set day_29_06=-R2005-06-29T06:00/2005-06-29T12:30/0/8
set day_30_07=-R2005-07-03T08:00/2005-07-03T22:00/0/8
set proj_tide=-JX7T/7

psxy $day_30_07 $proj_tide -O -K -W1/0/100/0 -Y-10 -Bs1D/0 -Bpa6Hf3Hg1H/1f0.5g1:"Height (m)":WeSn $tide_data >> $outfile
psxy $day_29_06 $proj_tide -O -W1/0/100/0 -X9 -Bs1D/0 -Bpa2Hf1Hg30M/1f0.5g1:"Height (m)":WeSn $tide_data >> $outfile

#------------------------------------------------------------------------------#

#psbasemap $area2 $proj2 -Y-10 -O -K -Ba20f10g10:"Distance along line (m)":/a1f0.5g0.5WeSn:"Depth (m) CD": >> offsets.ps

#awk '{print $1, $4}' 1.pts | psxy $area2 $proj2 -Ba20f10g10:"Distance along line (m)":/a1f0.5g0.5WeSn:"Depth (m) CD": -O -K -H2 -W1/255/0/0 -Y-13 >> $outfile
#awk '{print $1, $4}' 2.pts | psxy $area2 $proj2 -O -K -H2 -W1/0/255/0 >> $outfile
#awk '{print $1, $4}' 3.pts | psxy $area2 $proj2 -O -H2 -W1/0/0/255 >> $outfile

#------------------------------------------------------------------------------#

gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile
