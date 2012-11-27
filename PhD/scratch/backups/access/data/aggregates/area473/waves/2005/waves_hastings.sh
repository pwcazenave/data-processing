#! /bin/csh -f

# script to plot the vectors of the wave directions

set area=-R2005-09-13T00:00/2005-09-23T00:00/0/3
set proj=-JX24cT/14
set input_wavenet=./raw_data/hastings_wave_data_\(11434898_1\).txt
set input_cco=./raw_data/cco_data-20070223171621/data/waves/Rst_waves2005.txt
set input_glv=./raw_data/GreenwichLV2005.txt
set outfile=height_hastings.ps

gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_SECONDARY 10

# some quick changes to input and output formats
gmtset INPUT_DATE_FORMAT dd-mm-yyyy
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm

# need to format the date column in the correct manner (yyy-mm-ddThh:mm:ss):
awk '{print $1"T"$2, $3}' $input_wavenet > $input_wavenet.dat
# also need to grep out all the rubbish data (9999)
grep -v 9999 $input_cco | awk '/Sep/ {print $1"T"$2, $6}' | sed 's/Sep/09/g' > $input_cco.dat
# sort out the channel light vessel data
grep -v \/ $input_glv | awk '{printf "%02i,%02i,%4i,%02i,%1.1f\n", $3, $2, $1, $4":00", $7}' | tr "," " " | awk '{if ($2==09) print $1"-"$2"-"$3"T"$4":00",$5}' > $input_glv.dat

# plot the data
psbasemap $area $proj -Bpa12Hg12H/a0.5f0.25g0.25:"Significant Wave Height (m)":WeSn -Bsa1D/0 -K -Xc -Yc > $outfile
psxy $area $proj -H6 -O -K -W5/255/0/0 $input_wavenet.dat >> $outfile #red
psxy $area $proj -O -K -W5/0/200/50 $input_cco.dat >> $outfile # greenish
psxy $area $proj -O -K -W5/0/50/200 $input_glv.dat >> $outfile # blueish

# add in the survey dates as lines:
psxy $area $proj -O -K -W5/0/50/200 << DAY_1 >> $outfile # blueish
14-09-2005T22:45 2.625
15-09-2005T13:49 2.625
DAY_1
psxy $area $proj -O -K -W5/0/50/200 << DAY_2 >> $outfile # blueish
16-09-2005T19:32 2.625
17-09-2005T00:24 2.625
DAY_2
psxy $area $proj -O -K -W5/0/50/200 << DAY_3 >> $outfile # blueish
17-09-2005T00:35 2.625
17-09-2005T10:17 2.625
DAY_3
#psxy $area $proj -O -K -W5/0/50/200 << DAY_4 >> $outfile # blueish
#18-09-2005T06:44 2.625
#18-09-2005T13:55 2.625
#DAY_4
psxy $area $proj -O -K -W5/0/50/200 << DAY_5 >> $outfile # blueish
21-09-2005T08:22 2.625
21-09-2005T14:01 2.625
DAY_5
#psxy $area $proj -O -K -W5/0/50/200 << DAY_6 >> $outfile # blueish
#21-09-2005T23:25 2.625
#22-09-2005T10:06 2.625
#DAY_6

psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_1 >> $outfile # blueish
14-09-2005T22:45 2.625
15-09-2005T13:49 2.625
DAY_1
psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_2 >> $outfile # blueish
16-09-2005T19:32 2.625
17-09-2005T00:24 2.625
DAY_2
psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_3 >> $outfile # blueish
17-09-2005T00:35 2.625
17-09-2005T10:17 2.625
DAY_3
#psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_4 >> $outfile # blueish
#18-09-2005T06:44 2.625
#18-09-2005T13:55 2.625
#DAY_4
psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_5 >> $outfile # blueish
21-09-2005T08:22 2.625
21-09-2005T14:01 2.625
DAY_5
#psxy $area $proj -O -K -W5/0/50/200 -St0.2 << DAY_6 >> $outfile # blueish
#21-09-2005T23:25 2.625
#22-09-2005T10:06 2.625
#DAY_6

# add text showing which lines are when:
pstext $area $proj -O -K << LABELS >> $outfile
14-09-2005T22:45 2.655 8 45 1 1 0005
15-09-2005T13:49 2.655 8 45 1 1 0014
16-09-2005T19:32 2.655 8 45 1 1 0015
17-09-2005T00:24 2.655 8 45 1 1 0019
17-09-2005T03:35 2.655 8 45 1 1 0020
17-09-2005T10:17 2.655 8 45 1 1 0037
21-09-2005T06:25 2.655 8 45 1 1 0110
21-09-2005T14:01 2.655 8 45 1 1 0120
LABELS

# add a key
set a4=-R0/30/0/22
set page=-JX30/22

# insert the text
pstext $a4 $page -O -K -X-1 -Y-5 << KEY_TEXT >> $outfile
3 2 10 0 1 1 Channel Coastal Observatory
10 2 10 0 1 1 Cefas Wavenet
15 2 10 0 1 1 Greenwich Light Vessel
22 2 10 0 1 1 Survey Times
KEY_TEXT

# add the lines
psxy $a4 $page -O -K -W5/200/50 << CCO >> $outfile
1.5 2.1
2.5 2.1
CCO
psxy $a4 $page -O -K -W5/255/0/0 << CEFAS >> $outfile
8.5 2.1
9.5 2.1
CEFAS
psxy $a4 $page -O -K -W5/0/50/200 << GLV >> $outfile
13.5 2.1
14.5 2.1
GLV
psxy $a4 $page -O -K -W5/0/50/200 << SURVEY >> $outfile
20.5 2.1
21.5 2.1
SURVEY
psxy $a4 $page -O -W5/0/50/200 -St0.2 << SURVEY_DOTS >> $outfile
20.5 2.1
21.5 2.1
SURVEY_DOTS

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -S:a4 $outfile

