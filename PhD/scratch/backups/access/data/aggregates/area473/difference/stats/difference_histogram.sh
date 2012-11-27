#!/bin/csh -f

# script to turn the difference grids for 05-06 (with the newhaven tidal curve)
# and the 05-06 grid (with the gps tidal curve) into histograms

##----------------------------------------------------------------------------##

# housekeeping
set area=-R-1.5/1.5/0/1.5
set grd_area=-R314494/322135/5.59553e+06/5.59951e+06
set proj=-JX10

# i/o
set orig_infile=../area473_diff_05_06.grd
set gps_infile=../gps_area473_diff.grd
set outfile=../images/diff_histograms.ps

# labelling etc.
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset HEADER_OFFSET 0.2c
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##

# need to turn the bathy grids in the ascii text, and then awk out the last
# column to use as the histogram value
#grd2xyz $orig_infile -S | awk '{print $3}' > original_diff_0506.dat
#grd2xyz $gps_infile -S | awk '{print $3}' > gps_diff_0506.dat

##----------------------------------------------------------------------------##

# plot the histograms
pshistogram $area $proj original_diff_0506.dat \
   -Ba0.5f0.25g0.5:"Difference"::,m:/a0.5f0.25g0.5:,%::."Original":WeSn \
   -G200/20/0 -K -P -W0.01 -Xc -Y17 -Z1 > $outfile
pshistogram $area $proj gps_diff_0506.dat \
   -Ba0.5f0.25g0.5:"Difference"::,m:/a0.5f0.25g0.5:,%::."GPS":WeSn \
   -G0/20/200 -O -K -W0.01 -Y-14 -Z1 >> $outfile

##----------------------------------------------------------------------------##

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 -dOptimize=true $outfile
