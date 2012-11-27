#!/bin/csh -f

# script to plot the tracklines from the 2006 survey of area 473

##----------------------------------------------------------------------------##

# let's get the basics in
# display
set area=-R314339.4/322620.2/5595323/5599714
set proj=-Jx0.0025

# i/o
set outfile=./images/2006_tracklines.ps

# sort out the numbering format
gmtset D_FORMAT %7.7lg

# date stuff
gmtset INPUT_DATE_FORMAT dd-mm-yyyy
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm

# text labelling etc
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12

##----------------------------------------------------------------------------##

# get a basemap in so there's something to append to
psbasemap $area $proj -Ba2000g1000:"Eastings":/a1001g1000WeSn:"Northings"::."Tracklines for UTEC 473 2006": -K -Xc -Yc > $outfile

# add in the difference grid
grdimage $area $proj ../../difference/area473_diff_05_06.grd -C../../difference/.diff_05_06.cpt -O -K >> $outfile

# this needs a loop
echo -n "Starting... "

# plot the lines
foreach line(`ls ./raw_data/l*`)
   set line_no=`echo $line | tr "/" " " | awk '{print $3}'`
   awk '{print $1, $2}' $line | \
   psxy $area $proj -O -K -Sp0.025 -W1/0/0/0 >> $outfile
   # add the line number text
   tail -n 1 $line | \
   awk '{print $1,$2,"12 0 0 1",input}' input=$line_no |\
   pstext -G0/0/0 $area $proj -O -K >> $outfile
end

# add in the grid lines
psbasemap $area $proj -Bg1000 -O -K >> $outfile

# return the number format to its default
gmtset D_FORMAT %lg

# display the image
echo -n "converting... "
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
echo "Done!"
