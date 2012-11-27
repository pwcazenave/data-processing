#!/bin/csh -f

# script to analyse the spectral content of the two datasets so I can bandpass
# filter them to produce a smoother, regional-scale bathy map

##----------------------------------------------------------------------------##

# get the basics in
set area_05_wave=-R4/1400/0.03/10
set area_05_freq=-R0.00065/0.25/0.03/10
set area_06_wave=-R4/1400/1/50
set area_06_freq=-R0.00065/0.25/1/50
set proj=-JX10l

# i/o
set infile_05=../../2005/swath/raw_data/area473_2005_3.pts
set infile_06=../../2006/swath/raw_data/bathy_mean.xyz.bmd
set outfile=../images/histogram.ps

# pretty things
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##

# process the data
#awk '{print $3}' $infile_05 | spectrum1d -S512 -D2.5 -W -Ntest_05_wave
#awk '{print $3}' $infile_05 | spectrum1d -S512 -D2.5 -Ntest_05_freq
#awk '{print $3}' $infile_06 | spectrum1d -S512 -D2.5 -W -Ntest_06_wave
#awk '{print $3}' $infile_06 | spectrum1d -S512 -D2.5 -Ntest_06_freq

# plot the output of the spectral analysis
psxy $area_05_freq $proj -Ba1f3:,Hz:/a1f3:"Power"::."2005 Bathymetry Spectral Analysis":WeN -W1/220/220/220 -K -X3.5 -Yc test_05_freq.xpower > $outfile
psxy $area_05_wave $proj -Ba1f3:"Wavelength"::,m:/0WeS -W1/200/50/0 -O -K test_05_wave.xpower >> $outfile
psxy $area_06_freq $proj -Ba1f3:,Hz:/a1f3:"Power"::."2006 Bathymetry Spectral Analysis":wEN -W1/220/220/220 -O -K -X12.5 test_06_freq.xpower >> $outfile
psxy $area_06_wave $proj -Ba1f3:"Wavelength"::,m:/0wES -W1/0/200/50 -O -K test_06_wave.xpower >> $outfile

##----------------------------------------------------------------------------##

# view the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
