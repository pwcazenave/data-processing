#!/bin/bash

# Script to plot the M2 tidal harmonics from Uehara and MIKE21.

# We have 4 boundaries. Two sets of harmonics on each plot (NS and WE).
# East harmonic has two sets (MIKE21 and Uehara).

ampfile=./images/m2amp_profiles.ps
phasefile=./images/m2phase_profiles.ps

ampAreaWE=-R45/65/0/1
ampAreaNS=-R-15/15/0/2
phaseAreaWE=-R45/65/-180/180
phaseAreaNS=-R-15/15/-180/180
proj=-JX17/7

set -eu

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14

formats (){
    if [ $# -eq 0 ]; then
        echo "Not enough inputs.";
        echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]";
    fi;
    for i in "$@";
    do
        echo -n "converting $i to pdf ";
        ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.*}.pdf;
        echo -n "and png... ";
        gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile=${i%.ps}.png $i;
        echo "done.";
    done
}

## Amplitudes

# Latitude
psbasemap $ampAreaNS $proj -X3 -Y3 -K -Ba5f1:"Longitude"::,-@+o@+:/a1f0.2:"Amplitude (m)":WeSn \
   > $ampfile

# Decimalise the data to make is easier to view
psxy $ampAreaNS $proj ../mike_north_m2amp.csv -O -K -W5 >> $ampfile
awk 'NR%2==0 {print $1,$2}' ../mike_north_m2amp.csv | \
   psxy $ampAreaNS $proj -O -K -W5 -Sc0.15>> $ampfile
psxy $ampAreaNS $proj ../mike_south_m2amp.csv -O -K -W5 >> $ampfile
awk 'NR%2==0 {print $1,$2}' ../mike_south_m2amp.csv | \
   psxy $ampAreaNS $proj -O -K -W5 -Ss0.25 >> $ampfile
awk 'NR%10==0 {print $1,$2}' ../uehara_north_m2amp.csv | \
   psxy $ampAreaNS $proj -O -K -W5 -Sx0.25 >> $ampfile
psxy $ampAreaNS $proj -O -K -W5 ../uehara_north_m2amp.csv >> $ampfile
awk 'NR%10==0 {print $1,$2}' ../uehara_south_m2amp.csv | \
   psxy $ampAreaNS $proj -m -O -K -W5 -St0.25 >> $ampfile
psxy $ampAreaNS $proj -m -O -K -W5 ../uehara_south_m2amp.csv >> $ampfile

# Add label
pstext $ampAreaNS $proj -O -K << TEXT >> $ampfile
13.7 1.8 14 0 0 1 B
TEXT

# Longitude
psbasemap $ampAreaWE $proj -Y9 -O -K -Ba5f1:"Latitude"::,-@+o@+:/a0.5f0.1:"Amplitude (m)":WeSn \
   >> $ampfile

# Decimalise the data to make is easier to view
psxy $ampAreaWE $proj ../mike_west_m2amp.csv -O -K -W5 >> $ampfile
awk 'NR%2==0 {print $1,$2}' ../mike_west_m2amp.csv | \
   psxy $ampAreaWE $proj -O -K -W5 -Ss0.25 >> $ampfile
psxy $ampAreaWE $proj ../mike_east_m2amp.csv -O -K -W5 >> $ampfile
awk 'NR%2==0 {print $1,$2}' ../mike_east_m2amp.csv | \
   psxy $ampAreaWE $proj -O -K -W5 -Sc0.15>> $ampfile
awk 'NR%10==0 {print $1,$2}' ../uehara_west_m2amp.csv | \
   psxy $ampAreaWE $proj -O -K -W5 -St0.25 >> $ampfile
psxy $ampAreaWE $proj -O -K -W5 ../uehara_west_m2amp.csv >> $ampfile
awk 'NR%10==0 {print $1,$2}' ../uehara_east_m2amp.csv | \
   psxy $ampAreaWE $proj -O -K -W5 -Sx0.25 >> $ampfile
psxy $ampAreaWE $proj -O -K -W5 ../uehara_east_m2amp.csv >> $ampfile

# Add label
pstext $ampAreaWE $proj -O << TEXT >> $ampfile
64.2 0.9 14 0 0 1 A
TEXT

## Phases

# Latitude
psbasemap $phaseAreaNS $proj -X3 -Y3 -K -Ba5f1:"Longitude"::,-@+o@+:/a60f30:"Phase"::,-@+o@+:WeSn \
   > $phasefile

# Decimalise the data to make is easier to view
psxy $phaseAreaNS $proj ../mike_north_m2phase.csv -O -K -W5 >> $phasefile
awk 'NR%2==0 {print $1,$2}' ../mike_north_m2phase.csv | \
   psxy $phaseAreaNS $proj -O -K -W5 -Sc0.15>> $phasefile
psxy $phaseAreaNS $proj ../mike_south_m2phase.csv -O -K -W5 >> $phasefile
awk 'NR%2==0 {print $1,$2}' ../mike_south_m2phase.csv | \
   psxy $phaseAreaNS $proj -O -K -W5 -Ss0.25 >> $phasefile
awk 'NR%10==0 {print $1,$2}' ../uehara_north_m2phase.csv | \
   psxy $phaseAreaNS $proj -O -K -W5 -Sx0.25 >> $phasefile
psxy $phaseAreaNS $proj -O -K -W5 ../uehara_north_m2phase.csv >> $phasefile
awk 'NR%10==0 {print $1,$2}' ../uehara_south_m2phase.csv | \
   psxy $phaseAreaNS $proj -m -O -K -W5 -St0.25 >> $phasefile
psxy $phaseAreaNS $proj -m -O -K -W5 ../uehara_south_m2phase.csv >> $phasefile

# Add label
pstext $phaseAreaNS $proj -O -K << TEXT >> $phasefile
13.8 150 14 0 0 1 B
TEXT

# Longitude
psbasemap $phaseAreaWE $proj -Y9 -O -K -Ba5f1:"Latitude"::,-@+o@+:/a60f30:"Phase"::,-@+o@+:WeSn \
   >> $phasefile

# Decimalise the data to make is easier to view
psxy $phaseAreaWE $proj ../mike_west_m2phase.csv -O -K -W5 >> $phasefile
awk 'NR%2==0 {print $1,$2}' ../mike_west_m2phase.csv | \
   psxy $phaseAreaWE $proj -O -K -W5 -Ss0.25 >> $phasefile
psxy $phaseAreaWE $proj ../mike_east_m2phase.csv -O -K -W5 >> $phasefile
awk 'NR%2==0 {print $1,$2}' ../mike_east_m2phase.csv | \
   psxy $phaseAreaWE $proj -O -K -W5 -Sc0.15>> $phasefile
awk 'NR%10==0 {print $1,$2}' ../uehara_west_m2phase.csv | \
   psxy $phaseAreaWE $proj -O -K -W5 -St0.25 >> $phasefile
psxy $phaseAreaWE $proj -O -K -W5 ../uehara_west_m2phase.csv >> $phasefile
awk 'NR%10==0 {print $1,$2}' ../uehara_east_m2phase.csv | \
   psxy $phaseAreaWE $proj -O -K -W5 -Sx0.25 >> $phasefile
psxy $phaseAreaWE $proj -O -K -W5 ../uehara_east_m2phase.csv >> $phasefile

# Add label
pstext $phaseAreaWE $proj -O << TEXT >> $phasefile
64.3 150 14 0 0 1 A
TEXT

formats $ampfile $phasefile

