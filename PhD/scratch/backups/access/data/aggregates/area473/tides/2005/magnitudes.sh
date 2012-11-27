#! /bin/csh

# script to determine the difference in magnitudes of the tides during the time of the 2005 survey

set depth_area=-R2005-09-13T00:00/2005-09-23T00:00/-0.4/0.7
set depth_proj=-JX23cT/13
set time_area=-R-0.4/0.7/2005-09-13T00:00/2005-09-23T00:00
set time_proj=-JX13/23cT
set infile=./fortran/all_sept/all_picked.txt
set outfile=./images/magnitudes.ps

# get the basics in
psbasemap $depth_area $depth_proj -Ba1Df12Hg12H/0.1WeSn -K -Xc -Y5 > $outfile

# calculate the differences between one of the predicted cures (newhaven) and the all the others
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, ($7-$14)}' $infile | psxy $depth_area $depth_proj -O -K -H1 -W1/220/0/0 >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, ($7-$21)}' $infile | psxy $depth_area $depth_proj -O -K -H1 -W1/0/220/0 >> $outfile
awk '{print $1"-"$2"-"$3"T"$4":"$5":"$6, ($7-$28)}' $infile | psxy $depth_area $depth_proj -O -K -H1 -W1/0/0/220 >> $outfile
#, ($7-$28), ($7-$21)

# display the image
gs -sPAPERSIZE=a4 $outfile
