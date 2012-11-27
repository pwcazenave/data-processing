#!/bin/csh -f

# script to determine the frequency content of 3 beams from line 0005 of the 2005 UTEC survey of the eastern english channel

##----------------------------------------------------------------------------##

# let's get it on...

# display variables
set area=-R0/30/0/3000
set proj=-JX15/15

# i/o
set input=./raw_data/0005_-_473_e_w_16.txt
set outfile=./images/fourier.ps

##----------------------------------------------------------------------------##

# let's sort the input data first into beam and time
#cat $input | tr "/" "-" | awk '{print $1, $5"T"$4}' > ./raw_data/beam4.dat
#cat $input | tr "/" "-" | awk '{print $2, $5"T"$4}' > ./raw_data/beam40.dat
#cat $input | tr "/" "-" | awk '{print $3, $5"T"$4}' > ./raw_data/beam94.dat

##----------------------------------------------------------------------------##

# set the new inputs
set beam4=./raw_data/beam4.dat
set beam40=./raw_data/beam40.dat
set beam94=./raw_data/beam94.dat

##----------------------------------------------------------------------------##

# do the analysis
spectrum1d $beam4 -D0.02 -S512 -Nroll_check

##----------------------------------------------------------------------------##

# plot the results
psbasemap $area $proj -B1/10WeSn -Xc -Yc -K >! $outfile
psxy $area $proj -B0 -O -K roll_check.xpower >> $outfile

##----------------------------------------------------------------------------##

# display the results
#gs -sPAPERSIZE=a4
ps2pdf -sPAPERSIZE=a4 $outfile
