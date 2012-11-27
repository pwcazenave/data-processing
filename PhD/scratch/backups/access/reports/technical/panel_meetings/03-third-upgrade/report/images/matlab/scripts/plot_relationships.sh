#!/bin/bash

. ~/.bash_profile > /dev/null

# script to plot the various extant wavelength/height relationships, as
# well as mine

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4

minw=0.01
maxw=1000
minh=0.001
maxh=100

area=-R$minw/$maxw/$minh/$maxh
proj=-JX25l/15l
tproj=-JX25/15

flemming=../flemming_data.csv
flemming_africa=../flemming_data_africa.csv
hsb=../hsb_2005_300m_subset_results.csv
ws=../ws_200m_subset_results_errors.csv

outfile=./images/predicted_relationship.ps
mixout=./images/flemming_mine.ps

mkrels(){
   echo "$minw" > ../wavelengths.txt
   echo "$maxw" >> ../wavelengths.txt
   awk '{print $1,0.074*$1^0.77,0.0635*$1^0.733,0.3345*$1^0.3822,0.0677*$1^0.8098,0.0321*$1^0.9179,0.0692*$1^0.8020,0.13*$1^0.61,0.0324*$1^0.539,0.0394*$1^0.7155}' \
      ../wavelengths.txt > ../predicted_relationships.txt
   rm -f ../wavelengths.txt
}

plot(){
   psbasemap $area $proj -X3 -Yc -K \
      -Ba1f3:"Wavelength (m)":/a1f3:"Height (m)":WeSn \
      > $outfile
   # allen (1968b)
   cut -d" " -f1,2 ../predicted_relationships.txt | \
      psxy $area $proj -W10,200/0/50 -O -K >> $outfile
   # dalrymple et al (1978)
   cut -d" " -f1,3 ../predicted_relationships.txt | \
      psxy $area $proj -W10,50/0/200 -O -K >> $outfile
   # amos and king (1984)
   cut -d" " -f1,4 ../predicted_relationships.txt | \
      psxy $area $proj -W10,200/50/200 -O -K >> $outfile
   # flemming (1988)
   cut -d" " -f1,5 ../predicted_relationships.txt | \
      psxy $area $proj -W12,0/0/0 -O -K >> $outfile
   # francken et al (2004)
   cut -d" " -f1,6 ../predicted_relationships.txt | \
      psxy $area $proj -W10,20/100/20 -O -K >> $outfile
   # van landeghem et al (2009)
   cut -d" " -f1,7 ../predicted_relationships.txt | \
      psxy $area $proj -W10,238/180/34 -O -K >> $outfile
   # lane and eden (1940)
   cut -d" " -f1,8 ../predicted_relationships.txt | \
      psxy $area $proj -W10,150/100/50 -O -K >> $outfile
   # mine (hsb)
   cut -d" " -f1,9 ../predicted_relationships.txt | \
      psxy $area $proj -W10,128/128/128 -O -K >> $outfile
   # mine (solent)
   cut -d" " -f1,10 ../predicted_relationships.txt | \
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
   cut -d" " -f1,5 ../predicted_relationships.txt | \
      psxy $area $proj -W12,0/0/0 -O -K >> $mixout
   awk -F, '{if ($3>2 && $4>45 && $4<70) print $3,$5}' $hsb | \
      psxy $area $proj -St0.25 -O -K -W5,black >> $mixout
   awk -F, '{if ($3>2 && $4>55 && $4<65) print $3,$5}' $ws | \
      psxy $area $proj -Ss0.25 -O -K -W5,100/100/100 >> $mixout
   # Add some labels
   pstext $area $tproj -O -K -G0/0/0 -D0/-0.15 << LABELS >> $mixout
48 95 15 0 1 1 Flemming (1988)
LABELS
   psxy $area $tproj -O -K -W10,gray << LINE >> $mixout
15 95
40 95
LINE
   psxy $area $tproj -O -K -Sc0.25 -W5,gray << LINE >> $mixout
27.5 95
LINE
   pstext $area $tproj -O -K -D0/-0.15 -Gblack << LABELS >> $mixout
48 90 15 0 1 1 This Study (Hastings)
LABELS
   psxy $area $tproj -O -K -St0.25 -W5,black << LINE >> $mixout
27.5 90
LINE
   pstext $area $tproj -O -K -D0/-0.15 -G100/100/100 << LABELS >> $mixout
48 85 15 0 1 1 This Study (West Solent)
LABELS
   psxy $area $tproj -O -Ss0.25 -W5,100/100/100 << LINE >> $mixout
27.5 85
LINE
   formats $mixout
}


mkrels
#plot
plotmix
