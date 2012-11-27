#!/bin/csh -f

# script to plot an indifidual beam to check for the artefacts being applied

# get the basics in:
set area=-R0/100/32.5/47.5
set proj=-JX24/-14

# i/o
set infile=../swaths.xy
set outfile=./images/beam_plot.ps

##----------------------------------------------------------------------------##

# format the data
#grep -v beam $infile | awk '{if ($2<52.0 && $2>48.0) print $1, $4, $4*10, $4*10}' > single_beam.xy
grep -v beam $infile | awk '{if ($2==65.0) print $1, $4, $4*10, $4*10}' > single_beam.xy

# make a colour palette file
makecpt -Cwysiwyg -T300/500/0.01 -Z -I > .beam.cpt

# plot the data
psxy $area $proj -K -B0 -Xc -Yc single_beam.xy > $outfile
psxy $area $proj -O -K -Ba10f5g10:"Ping":/a5f2.5g2.5:"Depth (m)"::."Beam 65 Depth with Distance Along Track":WeSn single_beam.xy -Sc0.2 -W1/0/0/0 -C.beam.cpt >> $outfile

##----------------------------------------------------------------------------##

# display the image
# gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile



