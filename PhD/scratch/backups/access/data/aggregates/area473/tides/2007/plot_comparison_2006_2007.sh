#!/bin/bash

# script to plot the 2007 tidal gauge data and compare it with the 2006 rtk gps
# data to see if I can find the young flood stand
# layout is as follows:
#
#       [  0  ]         0   = 2006 rtk data
#       [1] [2]
#       [3] [4]         1-6 = subsets of the 2007 gauge data
#       [5] [6]
#
# TIDESTAT (gauge) data goes from 05th Aug 17:09 to 18th Aug 00:59 2007
#

gaugein=./raw_data/TIDESTAT_formatted.awkd      # dd-mm-yy
ppkin=./raw_data/ppkraw_plot.awkd               # dd/mm/yyyy need the -M flag!
rtkin=../2006/raw_data/gps_tide_trend.txt       # dd-mm-yyyy
outfile=./images/2006-2007_rtk_gauge_comparison.ps

# [0]
prtk(){
   rarea=-R2006-09-11T09:00/2006-09-12T02:00/48/58
   rproj=-JX16cT/4
   # plot the rtk gps data at the top of the page
   gmtset INPUT_DATE_FORMAT dd-mm-yyyy
   psxy $rarea $rproj -K -Bpa3Hf1Hg3H/a2f1g2:"Height (m) WGS84":WeSn \
      -Xc -Y24 -Bsa1D/0 -P -W5/200/50/50 $rtkin > $outfile
}

gproj=-JX6cT/5

# [1]
gauge1(){
   garea=-R2007-08-07T11:00:00/2007-08-07T18:00:00/49/58

   gmtset INPUT_DATE_FORMAT dd-mm-yy
   psxy $garea $gproj -O -K \
      -Bpa2Hf1Hg1H/a2f1g2:"Water Depth (m)":WeSn \
      -X1 -Y-7 -Bsa1D/0 -M -W5/0/100/200 $gaugein >> $outfile
}

# [2]
gauge2(){
   garea=-R2007-08-08T00:00:00/2007-08-08T07:00:00/49/58

   gmtset INPUT_DATE_FORMAT dd-mm-yy
   psxy $garea $gproj -O -K \
      -Bpa2Hf1Hg1H/a2f1g2:"Water Depth (m)":wESn \
      -X8 -Bsa1D/0 -M -W5/0/100/200 $gaugein >> $outfile
}

# [3]
gauge3(){
   garea=-R2007-08-12T17:00:00/2007-08-13T00:00:00/49/58

   gmtset INPUT_DATE_FORMAT dd-mm-yy
   psxy $garea $gproj -O -K \
      -Bpa2Hf1Hg1H/a2f1g2:"Water Depth (m)":WeSn \
      -X-8 -Y-7 -Bsa1D/0 -M -W5/0/100/200 $gaugein >> $outfile
}

# [4]
gauge4(){
   garea=-R2007-08-13T05:00:00/2007-08-13T12:00:00/49/58

   gmtset INPUT_DATE_FORMAT dd-mm-yy
   psxy $garea $gproj -O -K \
      -Bpa2Hf1Hg1H/a2f1g2:"Water Depth (m)":wESn \
      -X8 -Bsa1D/0 -M -W5/0/100/200 $gaugein >> $outfile
}

# [5]
gauge5(){
   garea=-R2007-08-14T18:00:00/2007-08-15T01:00:00/49/58

   gmtset INPUT_DATE_FORMAT dd-mm-yy
   psxy $garea $gproj -O -K \
      -Bpa2Hf1Hg1H/a2f1g2:"Water Depth (m)":WeSn \
      -X-8 -Y-7 -Bsa1D/0 -M -W5/0/100/200 $gaugein >> $outfile
}

# [6]
gauge6(){
   garea=-R2007-08-15T06:00:00/2007-08-15T13:00:00/49/58

   gmtset INPUT_DATE_FORMAT dd-mm-yy
   psxy $garea $gproj -O \
      -Bpa2Hf1Hg1H/a2f1g2:"Water Depth (m)":wESn \
      -X8 -Bsa1D/0 -M -W5/0/100/200 $gaugein >> $outfile
}


formats(){
   echo -n "converting $outfile to pdf "
   ps2pdf -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" > /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

prtk            # plot the 2006 trk
gauge1          # add plot [1] of the 2007 gauge
gauge2          # add plot [2] of the 2007 gauge
gauge3          # add plot [3] of the 2007 gauge
gauge4          # add plot [4] of the 2007 gauge
gauge5          # add plot [5] of the 2007 gauge
gauge6          # add plot [6] of the 2007 gauge
formats		# convert the output
exit 0
