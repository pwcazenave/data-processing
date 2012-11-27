#!/bin/bash

# Script to plot a map of the world with land in grey and sea in blue with
# 4 coordinates plotted on it. Labels every 30 degrees and frame ticks every
# 10 degrees.

gmtset PLOT_DEGREE_FORMAT=F

#area=-R-180/180/-90/90
area=-R100/400/0/85
#proj=-Jr0.068
#proj=-Jm0.05
proj=-Jx0.087d

#outfile=./map_box.ps
outfile=./map.ps

psbasemap $area $proj -K -Xc -Yc -Ba30f10 > $outfile
pscoast $area $proj -O -A1000 -Di -G128/128/128 >> $outfile

# add the coordinates
#psxy $area $proj -O -W5black -L << POINTS >> $outfile
#psxy $area $proj -O -Gblack -Sc0.1 << POINTS >> $outfile
#100 0
#40 0
#40 85
#100 85
#100 0
#POINTS

ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/screen $outfile
gs -sDEVICE=jpeg -r600 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile=${outfile%.*}.jpg $outfile
