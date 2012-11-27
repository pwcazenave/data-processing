#! /bin/csh

# script to plot the vectors of the wave directions

set plot_area=-R-10/10/-10/10
set plot_proj=-JX10
set hist_area=-R0/140/0/8
set outfile=wave_basement_dir.ps

gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

# need to format the date column in the correct manner (yyy-mm-ddThh:mm:ss):
cat PBy_waves2005_mod.txt | awk '{print $3, $4, $5, $2, $6, $7, $8, $9, $10, $11, $12, $13, $14}' | awk '{printf "%4s-%2s-%2sT%5s %4s %1s %4s %4s %1s %3s %2s %3s %2s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' > correct_dates.dat

# convert the wave period data into the depth to which the waves penetrate the water column
awk '{if ($4==0) print ($9-180), (((1.56*($7^2))/2)/25)}' correct_dates.dat > wave_base_direction.dat

# add the necessary information for plotting a vector
awk '{printf "0 0 %3s %6s\n", $1, $2, $3, $4}' wave_base_direction.dat > wave_base_input.dat

# plot the images
#psbasemap $plot_area $plot_proj -B0:."Vector of Wave Base and Wave Propagation Direction":WeSn -K -P -Xc -Y15.3 > $outfile
psbasemap $plot_area $plot_proj -B0WeSn -K -P -Xc -Y15.3 > $outfile

psxy $plot_area $plot_proj -O -K -G0/40/200 -SV0.01/0.2/0.05 -V wave_base_input.dat >> $outfile
psxy $plot_area $plot_proj -O -K -G0/0/0 -SV0.01/0/0 -V << AXIS  >> $outfile
0 0 0 10
0 0 22.5 10
0 0 45 10
0 0 67.5 10
0 0 90 10
0 0 112.5 10
0 0 135 10
0 0 157.5 10
0 0 180 10
0 0 202.5 10
0 0 225 10
0 0 247.5 10
0 0 270 10
0 0 292.5 10
0 0 315 10
0 0 337.5 10
AXIS

psxy $plot_area $plot_proj -O -K -G0/0/0 -SV0.01/0/0 -V -W2/0/0/0 << MAIN >> $outfile
0 0 0 10
0 0 90 10
0 0 180 10
0 0 270 10
MAIN

psxy $plot_area $plot_proj -O -K -Sc2.25 -V -W2/0/0/0 << CIRCLE >> $outfile
0 0
CIRCLE

psxy $plot_area $plot_proj -O -K -Sc4.5 -V -W2/0/0/0 << CIRCLE >> $outfile
0 0
CIRCLE

psxy $plot_area $plot_proj -O -K -Sc6.75 -V -W2/0/0/0 << CIRCLE >> $outfile
0 0
CIRCLE

psxy $plot_area $plot_proj -O -K -Sc9 -V -W2/0/0/0 << CIRCLE >> $outfile
0 0
CIRCLE

psxy $plot_area $plot_proj -O -K -Sc11.25 -V -W2/0/0/0 << CIRCLE >> $outfile
0 0
CIRCLE

psxy $plot_area $plot_proj -O -K -Sc13.5 -V -W2/0/0/0 << CIRCLE >> $outfile
0 0
CIRCLE

psxy $plot_area $plot_proj -O -K -Sc15.75 -V -W2/0/0/0 << CIRCLE >> $outfile
0 0
CIRCLE

psbasemap -JX25/35 -R0/25/0/35 -B0 -X-5.5 -Y-15 -O -K>> $outfile
pstext -J -R -O -K -V << TEXT >> $outfile
10.35 25.4 12 0 1 1 N
15.8 25.4 12 0 1 1 NE
15.8 19.85 12 0 1 1 E
15.8 14.4 12 0 1 1 SE
10.35 14.4 12 0 1 1 S
4.75 14.4 12 0 1 1 SW
4.75 19.85 12 0 1 1 W
4.75 25.4 12 0 1 1 NW
TEXT

awk '{if ($4==0) print ($9-180), ((1.56*($7^2))/2)}' correct_dates.dat | pshistogram $hist_area $plot_proj -W0.1 -Ba20f10:"Wave Base (m)":/a2f1:"Percentage"::."Histrogram of Wave Base":WeSn -T1 -Z1 -O -K -G100/100/100 -P -X5.5 -Y2 >> $outfile

# clean up
\rm -f wave_base_direction.dat

# display the image
gs -sPAPERSIZE=a4 $outfile

