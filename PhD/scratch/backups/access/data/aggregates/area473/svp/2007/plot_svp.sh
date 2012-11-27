#!/bin/bash

# plot the svp profiles for 2005 survey

area=-R1513/1517/0/50
#proj=-JX16/-23
proj=-JX23/-15

fifth=./raw_data/050807.svp
sixth=./raw_data/060807.svp
seventh=./raw_data/070807.svp
eighth=./raw_data/080807.svp
ninth=./raw_data/090807.svp
ninthb=./raw_data/090807b.svp

outfile=./images/svp.ps

gmtset LABEL_FONT_SIZE 10
gmtset ANNOT_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 14

plot() {
   psxy $area $proj -K -Xc -Yc $fifth -W5/0/200/100 -Ba1f0.5g1:"Sound Velocity (ms@+-1@+)":/a5f2.5g5:"Depth (m)":WeSn > $outfile
   psxy $area $proj -O -K $fifth -Sc0.1 -W5/0/200/100 -B0 >> $outfile
   psxy $area $proj -O -K $sixth -W5/200/0/100 -B0 >> $outfile
   psxy $area $proj -O -K $sixth -Sc0.1 -W5/200/0/100 -B0 >> $outfile
   psxy $area $proj -O -K $seventh -W5/0/100/200 -B0 >> $outfile
   psxy $area $proj -O -K $seventh -Sc0.1 -W5/0/100/200 -B0 >> $outfile
   psxy $area $proj -O -K $eighth -W5/100/0/200 -B0 >> $outfile
   psxy $area $proj -O -K $eighth -Sc0.1 -W5/100/0/200 -B0 >> $outfile
   psxy $area $proj -O -K $ninth -W5/128/128/128 -B0 >> $outfile
   psxy $area $proj -O -K $ninth -Sc0.1 -W5/128/128/128 -B0 >> $outfile
   psxy $area $proj -O -K $ninthb -W5/0/0/0 -B0 >> $outfile
   psxy $area $proj -O -K $ninthb -Sc0.1 -W5/0/0/0 -B0 >> $outfile

   # add a key:

   # set up the dimensions
   page=-R0/35/0/28
   a4=-JX35c/28c

   # plot the various labels
   psbasemap $page $a4 -O -K -P -B0wesn -X-4.5 -Y-7.5 >> $outfile
   pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
   4.5 5 10 0.0 0 1 05/08/2007
   8.5 5 10 0.0 0 1 06/08/2007
   12.5 5 10 0.0 0 1 07/08/2007
   16.5 5 10 0.0 0 1 08/08/2007
   20.5 5 10 0.0 0 1 09/08/2007
   24.5 5 10 0.0 0 1 09/08/2007
TEXT

   # plot the lines for the key
   psxy $page $a4 -O -K -W5/0/200/100 << GREEN_LINE >> $outfile
   3.5 5.15
   4 5.15
GREEN_LINE
   psxy $page $a4 -O -K -W5/0/200/100 -Sc0.1 << GREEN_DOT >> $outfile
   3.75 5.15
GREEN_DOT
   psxy $page $a4 -O -K -W5/200/0/50 << RED_LINE >> $outfile
   7.5 5.15
   8 5.15
RED_LINE
   psxy $page $a4 -O -K -W5/200/0/50 -Sc0.1 << RED_DOT >> $outfile
   7.75 5.15
RED_DOT
   psxy $page $a4 -O -K -W5/0/100/200 << BLUE_LINE >> $outfile
   11.5 5.15
   12 5.15
BLUE_LINE
   psxy $page $a4 -O -K -W5/0/100/200 -Sc0.1 << BLUE_DOT >> $outfile
   11.75 5.15
BLUE_DOT
   psxy $page $a4 -O -K -W5/100/0/200 << PURPLE_LINE >> $outfile
   15.5 5.15
   16 5.15
PURPLE_LINE
   psxy $page $a4 -O -K -W5/100/0/200 -Sc0.1 << PURPLE_DOT >> $outfile
   15.75 5.15
PURPLE_DOT
   psxy $page $a4 -O -K -W5/128/128/128 << GREY_LINE >> $outfile
   19.5 5.15
   20 5.15
GREY_LINE
   psxy $page $a4 -O -K -W5/128/128/128 -Sc0.1 << GREY_DOT >> $outfile
   19.75 5.15
GREY_DOT
   psxy $page $a4 -O -K -W5/0/0/0 << BLACK_LINE >> $outfile
   23.5 5.15
   24 5.15
BLACK_LINE
   psxy $page $a4 -O -K -W5/0/0/0 -Sc0.1 << BLACK_DOT >> $outfile
   23.75 5.15
BLACK_DOT
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

