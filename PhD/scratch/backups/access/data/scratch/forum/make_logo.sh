#!/bin/bash

# script to plot the logo for the forum

# get the basics in - basic's the word!
# display
area=-R-10/10/-10/10
proj=-JX8c/3c

# i/o
infile=./sin_input.txt
outfile=./logo.ps

# plot the sin curves as different colours
awk '{print $1, $2}' $infile | psxy $area $proj -K -B0g2/0g5wesn -P -W6/0/0/0 > $outfile
awk '{print $1, $3}' $infile | psxy $area $proj -O -K -B0g2/0g5wesn -W6/200/20/0 >> $outfile
awk '{print $1, $4}' $infile | psxy $area $proj -O -K -B0g2/0g5wesn -W6/20/200/0 >> $outfile
awk '{print $1, $5}' $infile | psxy $area $proj -O -K -B0g2/0g5wesn -W6/0/20/200 >> $outfile

# add in the text
pstext -O $area $proj << TEXT >> $outfile
-6.3 -5.3 64 0 0 0 GMT
TEXT

# convert the postscript to a gif
convert $outfile ${outfile%.ps}.gif
