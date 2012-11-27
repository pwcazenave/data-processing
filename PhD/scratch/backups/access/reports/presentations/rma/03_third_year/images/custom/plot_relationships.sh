#!/bin/bash

. ~/.bash_profile > /dev/null

# script to plot the various extant wavelength/height relationships, as
# well as mine

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4

minw=0.01
maxw=10000
minh=0.001
maxh=1000

area=-R$minw/$maxw/$minh/$maxh
proj=-JX25l/15l
tproj=-JX25/15

flemming=./raw_data/flemming_data.csv
flemming_africa=./raw_data/flemming_data_africa.csv
hsb=./raw_data/hsb_300m_subset_results_errors_asymm.csv
ws=./raw_data/ws_200m_subset_results_errors_asymm.csv
a4811=./raw_data/area481_500-1500m_subset_results_errors_asymm.csv
a4812=./raw_data/area481_200m_subset_results_errors_asymm.csv
srtm30=./raw_data/srtm_30000m_subset_results_errors_asymm.csv

outfile=./images/predicted_relationship.ps
mixout=./images/flemming.ps

mkrels(){
   echo "$minw" > ./raw_data/wavelengths.txt
   echo "$maxw" >> ./raw_data/wavelengths.txt
   awk '{print $1,0.074*$1^0.77,0.0635*$1^0.733,0.3345*$1^0.3822,0.0677*$1^0.8098,0.0321*$1^0.9179,0.0692*$1^0.8020,0.13*$1^0.61,0.0324*$1^0.539,0.0394*$1^0.7155}' \
      ./raw_data/wavelengths.txt > ./raw_data/predicted_relationships.txt
   rm -f ./raw_data/wavelengths.txt
}

plot(){
   psbasemap $area $proj -X3 -Yc -K \
      -Ba1f3:"Wavelength (m)":/a1f3:"Height (m)":WeSn \
      > $outfile
   # allen (1968b)
   cut -d" " -f1,2 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,200/0/50 -O -K >> $outfile
   # dalrymple et al (1978)
   cut -d" " -f1,3 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,50/0/200 -O -K >> $outfile
   # amos and king (1984)
   cut -d" " -f1,4 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,200/50/200 -O -K >> $outfile
   # flemming (1988)
   cut -d" " -f1,5 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W12,0/0/0 -O -K >> $outfile
   # francken et al (2004)
   cut -d" " -f1,6 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,20/100/20 -O -K >> $outfile
   # van landeghem et al (2009)
   cut -d" " -f1,7 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,238/180/34 -O -K >> $outfile
   # lane and eden (1940)
   cut -d" " -f1,8 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,150/100/50 -O -K >> $outfile
   # mine (hsb)
   cut -d" " -f1,9 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,128/128/128 -O -K >> $outfile
   # mine (solent)
   cut -d" " -f1,10 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W10,0/102/255 -O -K >> $outfile

   # legend - need a new linear projection for this
   pstext $area $tproj -O -K -G200/0/50 << LABELS >> $outfile
15 95 15 0 1 1 Allen (1968b)
LABELS
   pstext $area $tproj -O -K -G50/0/200 << LABELS >> $outfile
15 90 15 0 1 1 Dalrymple et al. (1978)
LABELS
   pstext $area $tproj -O -K -G200/50/200 << LABELS >> $outfile
15 85 15 0 1 1 Amos and King (1984)
LABELS
   pstext $area $tproj -O -K -G0/0/0 << LABELS >> $outfile
15 80 15 0 1 1 Flemming (1988)
LABELS
   pstext $area $tproj -O -K -G20/100/20 << LABELS >> $outfile
15 75 15 0 1 1 Francken et al. (2004)
LABELS
   pstext $area $tproj -O -K -G238/180/34 << LABELS >> $outfile
15 70 15 0 1 1 Van Landeghem et al. (2009)
LABELS
   pstext $area $tproj -O -K -G150/100/50 << LABELS >> $outfile
15 65 15 0 1 1 Lane and Eden (1940)
LABELS
   pstext $area $tproj -O -K -G128/128/128 << LABELS >> $outfile
15 60 15 0 1 1 This Study (Hastings)
LABELS
   pstext $area $tproj -O -G0/102/255 << LABELS >> $outfile
15 55 15 0 1 1 This Study (West Solent)
LABELS
   formats $outfile
}

plotmix(){
   # Plot Flemming's data with mine overlaid.
   psbasemap $area $proj -X3 -Yc -K \
      -Ba1f3:"Wavelength (m)":/a1f3:"Height (m)":WeSn > $mixout
   psxy $area $proj $flemming_africa -Sc0.1 -W5,gray -O -K >> $mixout
   psxy $area $proj $flemming -Sc0.1 -W5,gray -O -K >> $mixout
   cut -d" " -f1,5 ./raw_data/predicted_relationships.txt | \
      psxy $area $proj -W15,gray -O -K >> $mixout
   awk -F, '{if ($3>2 && $4>45 && $4<70) print $3,$5}' $hsb | \
      psxy $area $proj -St0.25 -O -K -W5,darkblue >> $mixout
   awk -F, '{if ($3>2 && $4>55 && $4<65) print $3,$5}' $ws | \
      psxy $area $proj -Ss0.25 -O -K -W5,darkred >> $mixout
   awk -F, '{if ($3>4 && $4>0 && $4<30) print $3,$5}' $a4811 | \
      psxy $area $proj -Sd0.25 -O -K -W5,darkgreen >> $mixout
   awk -F, '{if ($3>4 && $2>=5907500 && $2<=5909300 && $1>=344500 && $1<=345800) print $3,$5}' $a4812 | \
      psxy $area $proj -Sd0.25 -O -K -W5,darkgreen >> $mixout
   awk -F, '{if ($3>180 && $15==1) print $3,$5}' $srtm30 | \
      psxy $area $proj -S+0.25 -O -K -W5,orange >> $mixout

   # Add some labels
   xpos1=300
   xpos2=150
   ypos1=95
   ypos2=90
   pstext $area $tproj -O -K -Ggray -D0/-0.15 << LABELS >> $mixout
$xpos1 950 15 0 1 1 Flemming (1988)
LABELS
   psxy $area $tproj -O -K -W10,gray << LINE >> $mixout
50 950
250 950
LINE
   psxy $area $tproj -O -K -Sc0.25 -W5,gray << LINE >> $mixout
$xpos2 950
LINE
   pstext $area $tproj -O -K -D0/-0.15 -Gdarkblue << LABELS >> $mixout
$xpos1 900 15 0 1 1 This Study (Hastings)
LABELS
   psxy $area $tproj -O -K -St0.25 -W5,darkblue << LINE >> $mixout
$xpos2 900
LINE
   pstext $area $tproj -O -K -D0/-0.15 -Gdarkred << LABELS >> $mixout
$xpos1 850 15 0 1 1 This Study (West Solent)
LABELS
   psxy $area $tproj -O -K -Ss0.25 -W5,darkred << LINE >> $mixout
$xpos2 850
LINE
   pstext $area $tproj -O -K -D0/-0.15 -Gdarkgreen << LABELS >> $mixout
$xpos1 800 15 0 1 1 This Study (Area 481)
LABELS
   psxy $area $tproj -O -K -Sd0.25 -W5,darkgreen << LINE >> $mixout
$xpos2 800
LINE
   pstext $area $tproj -O -K -D0/-0.15 -Gorange << LABELS >> $mixout
$xpos1 750 15 0 1 1 This Study (Ar Rub' al Khali)
LABELS
   psxy $area $tproj -O -S+0.25 -W5,orange << LINE >> $mixout
$xpos2 750
LINE
   formats $mixout
}


mkrels
#plot
plotmix
