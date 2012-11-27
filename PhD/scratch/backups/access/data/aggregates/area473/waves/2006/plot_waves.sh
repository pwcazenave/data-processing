#! /bin/bash

# script to plot the vectors of the wave directions

area=-R2006-09-10T00:00/2006-09-13T00:00/0/0.75
proj=-JX24cT/14
input_wavenet=./raw_data/hastings_wave_data_\(11434898_1\).txt
input_cco=./raw_data/pevensey_bay_buoy_2006.txt
input_glv=./raw_data/GreenwichLV2005.txt
outfile=./images/waves.ps

gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_SECONDARY 10

# some quick changes to input and output formats
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm

plot(){
   gmtset INPUT_DATE_FORMAT dd/mm/yyyy
   # plot the data
   psbasemap $area $proj -Bpa6Hg6H/a0.125f0.0625g0.125:"Significant Wave Height (m)":WeSn -Bsa1D/0 -K -Xc -Yc > $outfile
   #psxy $area $proj -H6 -O -K -W5/255/0/0 $input_wavenet.dat >> $outfile #red
   psxy $area $proj -O -K -W5/0/200/50 $input_cco >> $outfile # greenish
   #psxy $area $proj -O -K -W5/0/50/200 $input_glv.dat >> $outfile # blueish

   # add in the survey dates as lines:
   psxy $area $proj -O -K -W5/0/50/200 << DAY_1 >> $outfile # blueish
   11/09/2006T10:38 0.65625
   12/09/2006T00:15 0.65625
DAY_1
   psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_1 >> $outfile # blueish
   11/09/2006T10:38 0.65625
   12/09/2006T00:15 0.65625
DAY_1

   # add text showing which lines are when:
   pstext $area $proj -X0.2 -Y0.2 -O -K << LABELS >> $outfile
   11/09/2006T10:38 0.65625 8 45 1 1 Start
   12/09/2006T00:15 0.65625 8 45 1 1 End
LABELS

   # add a key
#   a4=-R0/30/0/22
#   page=-JX30/22

   # insert the text
#   pstext $a4 $page -O -K -X-1 -Y-5 << KEY_TEXT >> $outfile
#   3 2 10 0 1 1 Channel Coastal Observatory
#   10 2 10 0 1 1 Cefas Wavenet
#   15 2 10 0 1 1 Greenwich Light Vessel
#   22 2 10 0 1 1 Survey Times
#KEY_TEXT

   # add the lines
#   psxy $a4 $page -O -K -W5/200/50 << CCO >> $outfile
#   1.5 2.1
#   2.5 2.1
#CCO
#   psxy $a4 $page -O -K -W5/255/0/0 << CEFAS >> $outfile
#   8.5 2.1
#   9.5 2.1
#CEFAS
#   psxy $a4 $page -O -K -W5/0/50/200 << GLV >> $outfile
#   13.5 2.1
#   14.5 2.1
#GLV
#   psxy $a4 $page -O -K -W5/0/50/200 << SURVEY >> $outfile
#   20.5 2.1
#   21.5 2.1
#SURVEY
#   psxy $a4 $page -O -W5/0/50/200 -St0.2 << SURVEY_DOTS >> $outfile
#   20.5 2.1
#   21.5 2.1
#SURVEY_DOTS
}

formats() {
   echo -n "convert the image to pdf... "
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" \
      "${outfile%.ps}.pdf" &> /dev/null
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile" &> /dev/null
   echo "done."
}

plot
formats
