#!/bin/bash

# plot the svp profile for 2006 survey

area=-R1515/1516/0/26
#proj=-JX16/-23
proj=-JX23/-15

infile=./raw_data/area473_2006.svp

outfile=./images/svp.ps

gmtset LABEL_FONT_SIZE 10
gmtset ANNOT_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 14

plot() {
   psxy $area $proj -K -Xc -Yc $infile -W5/0/100/200 -Ba0.1f0.05g0.1:"Sound Velocity (ms@+-1@+)":/a5f2.5g5:"Depth (m)":WeSn > $outfile
   psxy $area $proj -O -K $infile -Sc0.1 -W5/0/100/200 -B0 >> $outfile
}

formats() {
echo -n "convert the image to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" \
   &> /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" &> /dev/null
echo "done."
}

plot
formats

