#!/bin/csh -f

# script to compare the transect lines from the cross-line with the cross-swath lines.

##----------------------------------------------------------------------------##

# let's get it on
set area=-R0/2600/-49/-41
set proj=-JX23/16

# i/o
set in_cross=./raw_data/0029_cross_line.pts
set in_swath=./raw_data/cross_swaths.pts
set outfile=./images/transects.ps

# get the numbers right
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##

# plot!
psbasemap $area $proj -Ba200f100g100:"Distance Along Line (m)":/a2f1g1:"Depth (m)"::."Comparison of tie-line (red) and cross-swath (blue) seabed profiles":WeSn -K -Xc -Yc > $outfile

# the data
grep -v \/ $in_cross | awk '{print $1, $4}' | psxy $area $proj -B0 -W1/200/50/0 -O -K >> $outfile
grep -v \/ $in_swath | awk '{if (NR%10==0) print $1, $4}' | psxy $area $proj -B0 -W1/0/50/200 -O -K >> $outfile

##----------------------------------------------------------------------------##

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
