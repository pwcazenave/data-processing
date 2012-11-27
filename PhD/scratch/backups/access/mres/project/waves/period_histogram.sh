#! /bin/csh

# script to plot the vectors of the wave directions

set plot_proj=-JX9
set area=-R2005-01-01T00:00/2005-12-31T00:00/0/14
set proj=-JX15cT/10
set hist_area=-R0/15/0/12
set outfile=wave_period.ps

gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_SECONDARY 10

# need to format the date column in the correct manner (yyy-mm-ddThh:mm:ss):
cat PBy_waves2005_mod.txt | awk '{print $3, $4, $5, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14}' | awk '{printf "%4s-%2s-%2sT%5s %4s %1s %4s %4s %1s %3s %2s %3s %2s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' > correct_dates.dat

# pull out the date and period data 
awk '{if ($4==0) print $1, $7}' correct_dates.dat > date_period.dat

# pull out just the period and wave height data
awk '{if ($4==0) print $7, $8}' correct_dates.dat > period_height.dat

# plot the data

# some quick changes to input and output formats
gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm
                                                                                                
# plot the images
psbasemap $area $proj -Ba2Og1O/2f1g1:"Wave Period (s)"::."Wave Period Data for 2005":WeSn -K -P -Xc -Y15.3 > $outfile
psxy $area $proj -O -K -W1/255/0/0 date_period.dat >> $outfile #red

# plot a histogram of the wave period
pshistogram $hist_area $plot_proj -W0.1 -Ba1f0.5:"Wave Period (s)":/a2f1:"Percentage"::."Histrogram of Wave Period":WeSn -L1/10/100/100 -G0/100/100 -L1/10/100/100 -T0 -Z1 -O -K -X3 -Y-13 period_height.dat >> $outfile

# clean up
#\rm -f correct_dates.dat

# display the image
gs -sPAPERSIZE=a4 $outfile

