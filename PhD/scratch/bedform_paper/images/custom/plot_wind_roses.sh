#!/bin/bash

# Script to plot the wind roses and PVDs for the three airport data
# sets.

infiles=(./raw_data/wadialdawasserairport_2009-2011_no_header.csv ./raw_data/najran_2009-2011_no_header.csv ./raw_data/sharurah_2009-2011_no_header.csv)
analyses=(./raw_data/wadi_al-dawasir_analysis.csv ./raw_data/najran_analysis.csv ./raw_data/sharurah_analysis.csv)

outfile=./images/wind_roses.ps

#windStationsX=(45.198008 44.418333 47.118470)
#windStationsY=(20.507461 17.602147 17.470833)
windStationsX=(522359 435679 725830)
windStationsY=(2265836 1948088 1933809)

harea=-R0/360/0/100
rarea=-R0/15/0/360
parea=-R0/310000/-20000/60000
oarea=-R40/60/10/25

proj=-Jx2e-5
oproj=-Jm0.7

xPos=(3 8 8)
colours=(red green blue)
coloursLight=(pink lightgreen lightblue)

for ((i=0; i<${#infiles[@]}; i++)); do
    tempfile=$(mktemp)
    awk -F, '{if ($10>0) print $8}' ${infiles[i]} | \
        pshistogram $harea -Jx1 -W1 -T0 -Z1 -IO 2> /dev/null | \
            awk '{print $2,$1}' > $tempfile
    if [ $i -eq 0 ]; then
        psrose $rarea -A10 -X${xPos[i]}c -Y14c -S2.8c -D -T -W5,black -G${colours[i]} \
            $tempfile -Bg5:,-"%":/g30 -LW/E/S/N -K > $outfile
    else
        psrose $rarea -A10 -X${xPos[i]}c -S2.8c -D -T -W5,black -G${colours[i]} \
            $tempfile -Bg5:,-"%":/g30 -LW/E/S/N -O -K >> $outfile
    fi
    rm -f $tempfile
done

pscoast -B5/5WeSn $oarea $oproj -Df -X-12.2c -Y-13c -A1000 \
    -O -K -W -N1 -Ggray -Swhite >> $outfile
    pstext $oarea $oproj -O -K << LABELS >> $outfile
    52.75 23.2 12 -7.5 0 1 UAE
    56.5 19.5 12 60 0 1 Oman
    47 15.75 12 10 0 1 Yemen
    45 22 12 0 0 1 Saudi Arabia
    56 13 12 0 0 1 Arabian Sea
LABELS

for ((i=0; i<${#analyses[@]}; i++)); do
    numRec=$(wc -l < ${analyses[i]})
    awk -F, '{if (NR%10==0) print '${windStationsX[i]}'+($3*3),'${windStationsY[i]}'+($4*3)}' ${analyses[i]} | \
        mapproject -R20/80/10/40 -Ju38/1:1 -F -C -I | \
            psxy $oarea $oproj -Sc0.1 -W${colours[i]} -O -K >> $outfile
    awk -F, '{if (NR==1 || NR=='$numRec') print '${windStationsX[i]}'+($3*3),'${windStationsY[i]}'+($4*3)}' ${analyses[i]} | \
        mapproject -R20/80/10/40 -Ju38/1:1 -F -C -I | \
            psxy $oarea $oproj -W15,20/20/20 -A -O -K >> $outfile
    awk -F, '{if (NR==1 || NR=='$numRec') print '${windStationsX[i]}'+($3*3),'${windStationsY[i]}'+($4*3)}' ${analyses[i]} | \
        mapproject -R20/80/10/40 -Ju38/1:1 -F -C -I | \
            psxy $oarea $oproj -W5,${coloursLight[i]} -A -O -K >> $outfile
done

psxy -R -J -T -O >> $outfile

formats $outfile
# mv $outfile ./images/ps/
# mv ${outfile%.*}.png ./images/png/
