#!/bin/csh -f

# script to plot various different data from each survey:
#   exclusion zones (base depth)
#   utec 05 - tidallly corrected and not tidally correccted
#   geoswath 06 - tidally corrected and not tidally corrected
#   all data with a manual tide applied

##----------------------------------------------------------------------------##

# get the basics in
# display
set area=-R5597650/5598120/35/50
set proj=-JX22c/-15c

# i/o
set ez_infile=./raw_data/originals/ez_uc65_tide.txt
set utec_infile_tide=./raw_data/originals/0018_0019_tide.txt
set utec_infile_no_tide=./raw_data/originals/0018_0019_no_tide.txt
set geoa_infile_tide=./raw_data/originals/006_007_tide.txt
set geoa_infile_no_tide=./raw_data/originals/006_007_no_tide.txt
set outfile=./images/difference.ps

# labelling etc.
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset HEADER_OFFSET 0.2c
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##

# ok. this is going to be tough!
# i need to find a single point (ping) from every survey, and compare it.

# geoa
# so the time from the 2006 survey is 17.19.21. awk out those lines
# no tide
#awk '/17:19:21/ {print $2, $3}' $geoa_infile_no_tide \
#   > ./raw_data/006_007_no_tide.awkd
#awk '/18:15:27/ {print $2, $3}' $geoa_infile_no_tide \
#   >> ./raw_data/006_007_no_tide.awkd
# tide
#awk '/17:19:21/ {print $2, $3}' $geoa_infile_tide \
#   > ./raw_data/006_007_tide.awkd
#awk '/18:15:27/ {print $2, $3}' $geoa_infile_tide \
#   >> ./raw_data/006_007_tide.awkd
# manual tide
#awk '/17:19:21/ {print $2, ($3-2.795)}' $geoa_infile_no_tide \
#   > ./raw_data/006_007.tide
#awk '/18:15:27/ {print $2, ($3-1.508)}' $geoa_infile_no_tide \
#   >> ./raw_data/006_007.tide

# need to do the same for the utec
# tide (multiply by -1 to make depths positive)
#awk '/22:00:43/ {print $4, ($5*-1)}' $utec_infile_tide \
#   > ./raw_data/0018_0019_tide.awkd
#awk '/22:58:36/ {print $4, ($5*-1)}' $utec_infile_tide \
#   >> ./raw_data/0018_0019_tide.awkd
# no tide
#awk '/22:00:43/ {print $4, ($5*-1)}' $utec_infile_no_tide \
#   > ./raw_data/0018_0019_no_tide.awkd
#awk '/22:58:36/ {print $4, ($5*-1)}' $utec_infile_no_tide \
#   >> ./raw_data/0018_0019_no_tide.awkd
# manual
#awk '/22:00:43/ {print $4, (($5+6.158)*-1)}' $utec_infile_no_tide \
#   > ./raw_data/0018_0019.tide
#awk '/22:58:36/ {print $4, (($5+5.086)*-1)}' $utec_infile_no_tide \
#   >> ./raw_data/0018_0019.tide

# get the corresponding bit from the exclusion zones data
#awk '/10:34:46/ {print $2, $3}' $ez_infile > ./raw_data/ez_uc65.awkd
#awk '/10:19:07/ {print $2, $3}' $ez_infile >> ./raw_data/ez_uc65.awkd
#awk '/10:00:50/ {print $2, $3}' $ez_infile >> ./raw_data/ez_uc65.awkd
# that last one introduces some crappy data - leave it out.

##----------------------------------------------------------------------------##

# plot the data
psbasemap $area $proj -Ba50f25g25:"Northings":/a2f1g1:"Depth (m)"::."Depth with tide, without and with tide added manually for each survey":WeSn -K -Xc -Yc > $outfile

# add in each of the graphs

# geoa data
# raw
awk '{if (NR%1000==0); print $0}' ./raw_data/006_007_no_tide.awkd | \
   psxy $area $proj -O -K -B0 -W2/200/20/0 -Sc0.01 >> $outfile
# tide
awk '{if (NR%1000==0); print $0}' ./raw_data/006_007_tide.awkd | \
   psxy $area $proj -O -K -B0 -W2/20/200/0 -Sc0.01 >> $outfile
# manual
awk '{if (NR%1000==0); print $0}' ./raw_data/006_007.tide | \
   psxy $area $proj -O -K -B0 -W2/0/20/200 -Sc0.01 >> $outfile

# add in the utec data
# raw
psxy $area $proj -O -K -B0 -W2/150/50/0 -St0.03 \
   ./raw_data/0018_0019_no_tide.awkd >> $outfile
# tide
psxy $area $proj -O -K -B0 -W2/50/150/0 -St0.03 \
   ./raw_data/0018_0019_tide.awkd >> $outfile
# manual
psxy $area $proj -O -K -B0 -W2/0/50/150 -St0.03 \
   ./raw_data/0018_0019.tide >> $outfile

# add in the control (the exclusion zones data)
psxy $area $proj -O -K -B0 -W2/0/0/0 -Sc0.03 \
   ./raw_data/ez_uc65.awkd >> $outfile

##----------------------------------------------------------------------------##

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
