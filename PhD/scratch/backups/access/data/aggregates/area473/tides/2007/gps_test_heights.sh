#!/bin/bash

gmtset D_FORMAT=%g

gmtset INPUT_DATE_FORMAT dd-mm-yy
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm
gmtset PLOT_DATE_FORMAT yyyy-mm-dd

gps_area=-R2007-08-09T21:20/2007-08-10T09:30/34/48
proj=-JX24cT/13

infile=./raw_data/processing_formatted.txt
outfile=./images/gps_test.ps

awk '{if ($3>34) print $1"T"$2, $3}' $infile | \
   psxy $gps_area $proj -W3/0/200/100 -Xc -Yc \
   -Bpa30M/a2f1g2:"Height (m) WGS84"::."Area 473 2007 Survey GPS Height":WeSn \
   -Bsa2Hf1Hg2H/0 > $outfile

# make pdfs and jpegs
for image in ./images/*test.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 "$image" "${image%.ps}.pdf" > /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" > /dev/null
   echo "done."
done

exit 0
