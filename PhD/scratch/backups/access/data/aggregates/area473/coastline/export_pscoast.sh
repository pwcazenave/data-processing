#!/bin/bash

# script to get the coastline values out of the pscoast command.

##----------------------------------------------------------------------------##

# get all the basics in
area=-R-7.5/4/46/58
proj=-Jm1

# i/o
coordfile=./coastline.xy
outfile=./images/coast.ps

# labelling etc.
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
#gmtset HEADER_OFFSET 0.2c

##----------------------------------------------------------------------------##

# ok, let's do it!
case "$1" in
   'export')
      pscoast $area $proj -Df -M -W > $coordfile
      ;;
   'plot')
      psbasemap $area $proj -B2/2 -K -P -Xc -Yc > $outfile
      psxy $area $proj $coordfile -O -K -M >> $outfile
      ;;
esac

##----------------------------------------------------------------------------##

# display the image
#gs -sPAPERSIZE=a4
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile
