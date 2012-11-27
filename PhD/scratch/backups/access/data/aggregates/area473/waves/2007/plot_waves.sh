#! /bin/bash

# script to plot the vectors of the wave directions

area=-R2007-08-03T00:00/2007-08-13T00:00/0/1.5
proj=-JX24cT/14
#input_wavenet=./raw_data/hastings_wave_data_\(11434898_1\).txt
input_cco=./raw_data/cco_pevensey.dat
#set input_glv=./raw_data/GreenwichLV2005.txt
outfile=./images/waves.ps

gmtset D_FORMAT %g
gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 10

# some quick changes to input and output formats
gmtset INPUT_DATE_FORMAT dd-mm-yyyy
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm

# need to format the date column in the correct manner (yyy-mm-ddThh:mm:ss):
#awk '{print $1"T"$2, $3}' $input_wavenet > $input_wavenet.dat
# also need to grep out all the rubbish data (9999)
#> ${input_cco%.dat}.
# sort out the channel light vessel data
#grep -v \/ $input_glv | awk '{printf "%02i,%02i,%4i,%02i,%1.1f\n", $3, $2, $1, $4":00", $7}' | tr "," " " | awk '{if ($2==09) print $1"-"$2"-"$3"T"$4":00",$5}' > $input_glv.dat

# plot the data
psbasemap $area $proj -Bpa12H/0 -Bsa2Df1Dg12H:"Date":/a0.25f0.125g0.25:"Significant Wave Height (m)":WeSn -K -Xc -Yc > $outfile
#psxy $area $proj -H6 -O -K -W1/255/0/0 $input_wavenet.dat >> $outfile #red
awk '{print $1"T"$2, $5}' $input_cco | psxy $area $proj -O -K -W5/100/200/0 >> $outfile # greenish
#psxy $area $proj -O -K -W1/0/50/200 $input_glv.dat >> $outfile # blueish

# add in the survey dates as lines:
psxy $area $proj -O -K -W5/0/50/200 << DAY_1 >> $outfile
05-08-2007T19:43 1.3125
06-08-2007T12:49 1.3125
DAY_1
psxy $area $proj -O -K -W5/0/50/200 << DAY_2 >> $outfile
07-08-2007T14:28 1.3125
10-08-2007T13:52 1.3125
DAY_2
#psxy $area $proj -O -K -W5/0/50/200 << DAY_3 >> $outfile
#07-08-2007T23:33 2.25
#DAY_3
#psxy $area $proj -O -K -W5/0/50/200 << DAY_4 >> $outfile
#08-08-2007T01:10 2.25
#08-08-2007T23:54 2.25
#DAY_4
#psxy $area $proj -O -K -W5/0/50/200 << DAY_5 >> $outfile
#09-08-2007T00:01 2.25
#09-08-2007T23:47 2.25
#DAY_5
#psxy $area $proj -O -K -W5/0/50/200 << DAY_6 >> $outfile
#10-08-2007T00:28 2.25
#
#DAY_6

psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_1 >> $outfile
05-08-2007T19:43 1.3125
06-08-2007T12:49 1.3125
DAY_1
psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_2 >> $outfile
07-08-2007T14:28 1.3125
10-08-2007T13:52 1.3125
DAY_2
#psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_3 >> $outfile
#07-08-2007T14:28 2.25
#07-08-2007T23:33 2.25
#DAY_3
#psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_4 >> $outfile
#08-08-2007T01:10 2.25
#08-08-2007T23:54 2.25
#DAY_4
#psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_5 >> $outfile
#09-08-2007T00:01 2.25
#09-08-2007T23:47 2.25
#DAY_5
#psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_6 >> $outfile
#10-08-2007T00:28 2.25
#10-08-2007T13:52 2.25
#DAY_6

# add text showing which lines are when:
pstext $area $proj -O -K -X0.1 -Y0.2 << LABELS >> $outfile
05-08-2007T19:43 1.3125 8 45 0 1 Start
06-08-2007T12:49 1.3125 8 45 0 1 End
07-08-2007T14:28 1.3125 8 45 0 1 Start
10-08-2007T13:52 1.3125 8 45 0 1 End
LABELS

## add a key
#a4=-R0/30/0/22
#page=-JX30/22
#
## insert the text
#pstext $a4 $page -O -K -X-1 -Y-5 << KEY_TEXT >> $outfile
#9 2 10 0 1 1 Channel Coastal Observatory
#16 2 10 0 1 1 Survey Times
#KEY_TEXT
##10 2 10 0 1 1 Cefas Wavenet
##15 2 10 0 1 1 Greenwich Light Vessel
#
## add the lines
#psxy $a4 $page -O -K -W3/200/50 << CCO >> $outfile
#7.5 2.1
#8.5 2.1
#CCO
##psxy $a4 $page -O -K -W1/255/0/0 << CEFAS >> $outfile
##8.5 2.1
##9.5 2.1
##CEFAS
##psxy $a4 $page -O -K -W1/0/50/200 << GLV >> $outfile
##13.5 2.1
##14.5 2.1
##GLV
#psxy $a4 $page -O -K -W3/0/50/200 << SURVEY >> $outfile
#14.5 2.1
#15.5 2.1
#SURVEY
#psxy $a4 $page -O -W3/0/50/200 -St0.2 << SURVEY_DOTS >> $outfile
#14.5 2.1
#15.5 2.1
#SURVEY_DOTS
#
# convert the images to jpeg and pdf from postscript
for image in ./images/*.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 "$image" "${image%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" > /dev/null
   echo "done."
done

#gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
