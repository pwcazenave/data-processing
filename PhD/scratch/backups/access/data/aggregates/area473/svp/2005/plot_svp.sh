#!/bin/bash

# plot the svp profiles for 2005 survey

area=-R1508/1516/0/50
#proj=-JX16/-23
proj=-JX23/-15

fourteenth=./raw_data/14-09-05.svp
nineteenth=./raw_data/19-09-05.svp

outfile=./images/svp.ps

gmtset LABEL_FONT_SIZE 10
gmtset ANNOT_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 14

plot() {
   psxy $area $proj -K -Xc -Yc $fourteenth -W5/200/0/100 -Ba1f0.5g1:"Sound Velocity (ms@+-1@+)":/a5f2.5g5:"Depth (m)":WeSn > $outfile
   psxy $area $proj -O -K $fourteenth -Sc0.1 -W5/200/0/100 -B0 >> $outfile
   psxy $area $proj -O -K $nineteenth -W5/0/100/200 -B0 >> $outfile
   psxy $area $proj -O -K $nineteenth -Sc0.1 -W5/0/100/200 -B0 >> $outfile

   # add a key:

   # set up the dimensions
   page=-R0/35/0/28
   a4=-JX35c/28c

   # plot the various labels
   psbasemap $page $a4 -O -K -P -B0wesn -X-4.5 -Y-7.5 >> $outfile
   pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
   7.5 4.9 12 0.0 0 1 Sound Velocity Profile 14/09/2005
   16.5 4.9 12 0.0 0 1 Sound Velocity Profile 19/09/2005
TEXT

   # plot the lines for the key
   psxy $page $a4 -O -K -W5/200/0/50 << RED_LINE >> $outfile
   6.5 5
   7 5
RED_LINE
   psxy $page $a4 -O -K -W5/200/0/50 -Sc0.1 << RED_DOT >> $outfile
   6.75 5
RED_DOT
   psxy $page $a4 -O -K -W5/0/100/200 << BLUE_LINE >> $outfile
   15.5 5
   16 5
BLUE_LINE
   psxy $page $a4 -O -W5/0/100/200 -Sc0.1 << BLUE_DOT >> $outfile
   15.75 5
BLUE_DOT
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

