#! /bin/csh

# script to determine the water depth with time (a tidal curve for site 2 of the moored ADCP data).

# input file:

set input=/users/msc/pwc101/scratch/project/adcp/adcp_processing/matlab/UTEK/Site2/Site2_Data.txt
set output1=./site2_Data_tidal_curve.txt
set output2=./site2_tides.txt

# use awk to get the time and date column and the water depth (which needs to be determine from two columns' data - height below sea surface and height above bed).

grep -v D $input | awk '{print $2, $3}' > date
grep -v D $input | awk '{printf "%2.2f\n", ($19+$20)}' > depth
paste date depth > $output1

# format the date column in the correct manner:

awk -F/ '{print $1, $2, $3, $4}' $output1 | awk '{printf "%4s-%2s-%2s %8s %2.2f\n", $3, $2, $1, $4, $5}' > $output2

# clean up
rm date depth $output1

# plot the output from this section above in psxy to make sure it's all working ok.

#gmtset BASEMAP_TYPE = fancy
#gmtset LABEL_FONT_SIZE = 12
#gmtset HEADER_FONT_SIZE	= 16p
#gmtset INPUT_DATE_FORMAT = yyyy-mm-dd
#gmtset PAPER_MEDIA = letter
#gmtset CHAR_ENCODING = Standard
#gmtset MEASURE_UNIT = cm

awk '{print $1, $2, $1, $2}' $output2 > test

set proj=-JX1T
set area=-R1/31/0/35
set outfile=tidal_curve.ps

psbasemap $proj $area -B15000:"Eastings":/15:"Northings"::."UTEC Survey":WeSn -Xc -Y6 -P -K > $outfile
psxy $proj $area test -G25/50/25 -W2/255/0/0 -O >> $outfile

# view the image
#gs -sPAPERSIZE=a4 $outfile
