#! /bin/csh

# script to plot the tidal data from various sources

set bodc_proj=-JX15cT/5
set newhaven_path=./bodc/raw_data_newhaven
set dover_path=./bodc/raw_data_dover
set wx_path=./wxtide_output

set outfile=./images/tides.ps

gmtset ANNOT_FONT_SIZE 10p
gmtset LABEL_FONT_SIZE 12p
gmtset HEADER_FONT_SIZE 14p
gmtset ANNOT_FONT_SIZE_SECONDARY 10p

# bodc newhaven and dover
gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full

## 2003
set bodc_2003_area=-R2003-06-01T00:00/2003-07-01T00:00/0/8

psbasemap  $bodc_2003_area $bodc_proj -Ba6Dg2D:"Date":/a1f0.5g1:"Height (m) CD"::."June 2003 Tidal Curve":WeSn -K -P -Xc -Y22 > $outfile
# newhaven
grep 2003/ $newhaven_path/2003NHA.txt | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2003_area $bodc_proj -W0.5/150/0/50 -K -O -P >> $outfile
# dover
grep 2003/ $dover_path/2003DOV.txt | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2003_area $bodc_proj -B0wesn -O -K -P -W0.5/50/0/150 >> $outfile
# hastings from wxtide
#psxy $wx_path/newhaven_03-06_formatted.txt $bodc_2003_area $bodc_proj -B0wesn -W0.5/0/200/0 -O -K -P >> $outfile
# newhaven from wxtide
#psxy $wx_path/newhaven_03-06_formatted.txt $bodc_2003_area $bodc_proj -B0wesn -W0.5/0/0/0 -O -K -P >> $outfile

## 2005
set bodc_2005_area=-R2005-09-14T00:00/2005-09-22T00:00/-1/8

psbasemap  $bodc_2005_area $bodc_proj -Ba1dg12h:"Date":/a1f0.5g1:"Height (m) CD"::."September 2005 Tidal Curve":WeSn -O -K -P -Y-9 >> $outfile
# newhaven
grep 2005/ $newhaven_path/2005NHA.txt | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2005_area $bodc_proj -O -K -P -W0.5/150/0/50 >> $outfile
# dover
grep 2005/ $dover_path/2005DOV.txt | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2005_area $bodc_proj -B0wesn -O -K -P -W0.5/50/0/150 >> $outfile
# hastings from wxtide
grep :00 $wx_path/hastings_05-06_formatted.txt | psxy $bodc_2005_area $bodc_proj -B0wesn -W0.5/0/200/0 -O -K -P >> $outfile
# newhaven from wxtide
grep :00 $wx_path/newhaven_05-06_formatted.txt | psxy $bodc_2005_area $bodc_proj -B0wesn -W0.5/0/0/0 -O -K -P >> $outfile

## 2006
set bodc_2006_area=-R2006-06-01T00:00/2006-07-01T00:00/0/7

psbasemap  $bodc_2006_area $bodc_proj -Ba6Dg2D:"Date":/a1f0.5g1:"Height (m) CD"::."June 2006 Tidal Curve":WeSn -O -K -P -Y-9 >> $outfile
# newhaven
cat $newhaven_path/NHA060* | grep 2006/ | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2006_area $bodc_proj -W0.5/150/0/50 -O -K -P >> $outfile
# dover
cat $dover_path/DOV060* | grep 2006/ | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2006_area $bodc_proj -B0wesn -W0.5/50/0/150 -O -K -P >> $outfile
# hastings from wxtide
psxy $wx_path/hastings_06-06_formatted.txt $bodc_2006_area $bodc_proj -B0wesn -W0.5/0/200/0 -O -K -P >> $outfile
# newhaven from wxtide
psxy $wx_path/newhaven_06-06_formatted.txt $bodc_2006_area $bodc_proj -B0wesn -W0.5/0/0/0 -O -K -P >> $outfile

# add a key:

# set up the dimensions
set page=-R0/28/0/35
set a4=-JX28c/35c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0/0wesn -X-4 -Y-8 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
3.7 5.4 10 0.0 1 1 Newhaven Observed Tidal Curve
3.7 4.9 10 0.0 1 1 WXTide Newhaven Predicted Curve
12.7 5.4 10 0.0 1 1 Dover Observed Tidal Curve
12.7 4.9 10 0.0 1 1 WXTide Dover Predicted Curve
TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W -W2/150/0/50 << RED_LINE >> $outfile
2.7 5.5
3.2 5.5
RED_LINE
psxy $page $a4 -O -K -W -W2/0/200/0 << GREEN_LINE >> $outfile
2.7 5
3.2 5
GREEN_LINE
psxy $page $a4 -O -K -W -W2/50/0/150 << BLUE_LINE >> $outfile
11.7 5.5
12.2 5.5
BLUE_LINE
psxy $page $a4 -O -W -W2/0/0/0 << BLACK_LINE >> $outfile
11.7 5
12.2 5
BLACK_LINE

# display the image
gs -sPAPERSIZE=a4 $outfile
