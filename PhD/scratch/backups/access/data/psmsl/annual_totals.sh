#!/bin/bash

# script to determine the total number of stations for each year

area=-R1800/2003/0/25
proj=-JX22/14
annot=-Ba20f5g20:"Year":/a5f1g5:Frequency\ count::.PSMSL\ annual\ sea\ level\ curve\ data\ distribution\ for\ the\ model\ domain:WeSn
outfile=./images/annual_data_histogram.ps

cat ./extracted_annual/*.rlrdata | cut -f2 -d" " | \
   pshistogram $area $proj "$annot" -W1 -G128/128/128 -L2 -F -T0 -Z0 -Xc -Yc \
   > $outfile

# convert the images
echo -n "converting to pdf "
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
   ${outfile%.ps}.pdf
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" > /dev/null
echo "done."

