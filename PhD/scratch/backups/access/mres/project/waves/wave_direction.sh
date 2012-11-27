#! /bin/csh

# script to plot the vectors of the wave directions

set plot_area=-R-10/10/-10/10
set plot_proj=-JX9
set area=-R2005-01-01T00:00/2005-12-31T00:00/0/360
set proj=-JX15cT/10
set hist_area=-R0/360/0/700
set outfile=wave_propagation.ps

gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_SECONDARY 10

# need to format the date column in the correct manner (yyy-mm-ddThh:mm:ss):
cat PBy_waves2005_mod.txt | awk '{print $3, $4, $5, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14}' | awk '{printf "%4s-%2s-%2sT%5s %4s %1s %4s %4s %1s %3s %2s %3s %2s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' > correct_dates.dat

# pull out the date and direction data
awk '{if ($4==0) print $1, $9}' correct_dates.dat > date_dir.dat

# pull out the period and direction data
awk '{if ($4==0) print $9, $7}' correct_dates.dat > period_dir.dat

# correct for pxsy's bizarre way of plotting vectors...
awk '{if ($1<90) print (((360-$1)+90)-360), ($2/2)}' period_dir.dat > period_dir_lt_90.dat
awk '{if ($1>90) print (((360+90)-$1)), ($2/2)}' period_dir.dat > period_dir_gt_90.dat
cat period_dir_lt_90.dat period_dir_gt_90.dat > period_dir_input.dat

# plot the data

# some quick changes to input and output formats
gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm
                                                                                                
# plot the images
psbasemap $area $proj -Ba2Og1O/30f10g10:"Wave Propagation (Degrees)"::."Wave Data for 2005":WeSn -K -P -Xc -Y15.3 > $outfile
psxy $area $proj -O -K -W1/255/0/0 date_dir.dat >> $outfile #red

# plot the vectors of direction with magnitude as wave period
#awk '{printf "0 0 %3s %6s\n", $1, $2, $3, $4}' period_dir_input.dat > vectors.dat
#psxy $plot_area $plot_proj -O -K -G0/0/0 -Sv0.01/0.2/0.05 -V -X2.5 -Y-13 vectors.dat  >> $outfile

# plot a histogram of the orientation of the waves
pshistogram $hist_area $plot_proj -W1 -Ba30f15:"Wave Propagation (Degrees)":/a200f100:"Number Density"::."Histrogram of Wave Propagation Direction":WeSn -G0/100/100 -L1/10/100/100 -T0 -Z0 -O -K -X3 -Y-13 period_dir.dat >> $outfile

# clean up
\rm -f period_dir_input.dat period_dir_gt_90.dat period_dir_lt_90.dat correct_dates.dat

# display the image
gs -sPAPERSIZE=a4 $outfile

