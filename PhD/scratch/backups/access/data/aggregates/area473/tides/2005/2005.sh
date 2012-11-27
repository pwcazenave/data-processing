#! /bin/csh -f

# script to plot the tidal data from various sources

set bodc_proj=-JX25cT/14
set newhaven_path=./bodc/raw_data_newhaven
set dover_path=./bodc/raw_data_dover
set wx_path=./wxtide_output

set outfile=./images/2005.ps

gmtset ANNOT_FONT_SIZE 10p
gmtset LABEL_FONT_SIZE 12p
gmtset HEADER_FONT_SIZE 14p
gmtset ANNOT_FONT_SIZE_SECONDARY 10p

# bodc newhaven and dover
gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full

set bodc_2005_area=-R2005-09-14T00:00/2005-09-22T00:00/-1/8

psbasemap  $bodc_2005_area $bodc_proj -Ba1Dg6h:"Date":/a1f0.5g1:"Height (m) CD":WeSn -K -Xc -Yc > $outfile
# newhaven
grep 2005/ $newhaven_path/2005NHA.txt | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2005_area $bodc_proj -O -K -P -W5/150/0/50 >> $outfile
# dover
grep 2005/ $dover_path/2005DOV.txt | tr "TM" " " | tr "/" "-" | awk '{print $2"T"$3, $4}' | psxy $bodc_2005_area $bodc_proj -B0wesn -O -K -P -W5/0/100/250 >> $outfile
# newhaven from wxtide
#grep -v 2005-T $wx_path/newhaven_05-06_formatted.txt | psxy $bodc_2005_area $bodc_proj -B0wesn -W5/0/0/0 -O -K -P >> $outfile
gmtset INPUT_DATE_FORMAT dd/mm/yyyy
#psxy $wx_path/newhaven_predicted_time_corrected_to_GMT.txt \
grep :00 $wx_path/newhaven_05-06_formatted_redone.txt | \
   psxy $bodc_2005_area $bodc_proj -B0wesn -W5/0/0/0 -O -K -P >> $outfile
# hastings from wxtide
#gmtset INPUT_DATE_FORMAT yyyy-mm-dd
#grep :00 $wx_path/hastings_05-06_formatted.txt | psxy $bodc_2005_area $bodc_proj -B0wesn -W5/0/200/0 -O -K -P >> $outfile
grep :00 $wx_path/hastings_05-06_formatted_redone.txt \
   | psxy $bodc_2005_area $bodc_proj -B0wesn -W5/0/200/0 -O -K -P >> $outfile

# add a key:

# set up the dimensions
set page=-R0/35/0/28
set a4=-JX35c/28c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0/0wesn -X-4 -Y-8 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
4.7 5.4 10 0.0 0 1 Newhaven Observed
10.3 5.4 10 0.0 0 1 Dover Observed
15.2 5.4 10 0.0 0 1 WXTide Newhaven Predicted
22.2 5.4 10 0.0 0 1 WXTide Hastings Predicted
TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W -W5/150/0/50 << RED_LINE >> $outfile
3.7 5.55
4.2 5.55
RED_LINE
psxy $page $a4 -O -K -W -W5/0/100/250 << BLUE_LINE >> $outfile
9.2 5.55
9.7 5.55
BLUE_LINE
psxy $page $a4 -O -K -W -W5/0/0/0 << BLACK_LINE >> $outfile
14.2 5.55
14.7 5.55
BLACK_LINE
psxy $page $a4 -O -W -W5/0/200/0 << GREEN_LINE >> $outfile
21.2 5.55
21.7 5.55
GREEN_LINE

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile ./images/`basename $outfile .ps`.pdf
gs -sPAPERSIZE=a4 -sDEVICE=jpeg -r300 -dBATCH -dNOPAUSE -sOutputFile=./images/2005.jpg $outfile > /dev/null
