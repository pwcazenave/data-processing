#!/bin/bash

# Script to plot the results of the uniform Manning's number models as
# pie charts on a map of the UK.

version=v2
rmsSpeed=./raw_data/combo_${version}_M20-M60_calibgroup1_currents_rms_speed_results.csv
rmsDir=./raw_data/combo_${version}_M20-M60_calibgroup1_currents_rms_direction_results.csv
lagsSpeed=./raw_data/combo_${version}_M20-M60_calibgroup1_currents_phase_speed_results.csv
lagsDir=./raw_data/combo_${version}_M20-M60_calibgroup1_currents_phase_direction_results.csv

set -eu

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=16

normalBars(){
    # Bar chart of the calibration results on normal axes.

    nproj=-JX26.8c/15.5c

    infile="$1"
    annotation="$2"
    outfile=./images/$(basename ${1%.*}).ps
    inc=$3
    sites=($(awk -F"," '{print $NF}' $infile))

    # More dynamic area required here
    minX=-1
    maxX=${maxX:-$(grep -v NaN $infile | wc -l)}
    minY=${minY:-$(awk -F, '{print $3,$4,$5,$6,$7,$8,$9,$10,$11}' $infile | minmax -C | tr "\t" "\n" | minmax -C | awk '{printf "%.0f", $1}')}
    maxY=${maxY:-$(awk -F, '{print $3,$4,$5,$6,$7,$8,$9,$10,$11}' $infile | minmax -C | tr "\t" "\n" | minmax -C | awk '{printf "'$5'", $2}')}
    narea=-R$minX/$maxX/$minY/$maxY

    makecpt -T0/1/0.1 -Z -Crainbow > ./cpts/$(basename ${0%.*}).cpt
    lineColours=($(makecpt -N -T20/65/5 -Cjet --COLOR_MODEL=+HSV | awk '!/#/ {OFS="-"; print $2,$3,$4}'))

    psbasemap $narea $nproj -K -X2.6c -Y5 \
        -B0$4/a${inc}f$(echo "scale=2; $inc/4" | bc -l):"$annotation":WeSn > $outfile

    startX=0
    nameIndex=0

    dos2unix -q $infile

    while read line; do
        if echo $line | grep -v NaN > /dev/null; then
            echo -n "Station $(($startX+1)) of $maxX... "
            data=($(echo $line | tr ",\n" " "))
            # 20
            echo ${startX} ${data[2]} ${data[2]} | \
                psxy $narea $nproj -D-0.28/0 -Sb0.07 -G${lineColours[0]} -W0.5,gray -O -K >> $outfile
            # 25
            echo ${startX} ${data[3]} ${data[3]} | \
                psxy $narea $nproj -D-0.21/0 -Sb0.07 -G${lineColours[1]} -W0.5,gray -O -K >> $outfile
            # 32
            echo ${startX} ${data[4]} ${data[4]} | \
                psxy $narea $nproj -D-0.14/0 -Sb0.07 -G${lineColours[2]} -W0.5,gray -O -K >> $outfile
            # 35
            echo ${startX} ${data[5]} ${data[5]} | \
                psxy $narea $nproj -D-0.07/0 -Sb0.07 -G${lineColours[3]} -O -K >> $outfile
            # 40
            echo ${startX} ${data[6]} ${data[6]} | \
                psxy $narea $nproj -D0/0 -Sb0.07 -G${lineColours[4]} -O -K >> $outfile
            # 45
            echo ${startX} ${data[7]} ${data[7]} | \
                psxy $narea $nproj -D0.07/0 -Sb0.07 -G${lineColours[5]} -O -K >> $outfile
            # 50
            echo ${startX} ${data[8]} ${data[8]} | \
                psxy $narea $nproj -D0.14/0 -Sb0.07 -G${lineColours[6]} -O -K >> $outfile
            # 55
            echo ${startX} ${data[9]} ${data[9]} | \
                psxy $narea $nproj -D0.21/0 -Sb0.07 -G${lineColours[7]} -O -K >> $outfile
            # 60
            echo ${startX} ${data[10]} ${data[10]} | \
                psxy $narea $nproj -D0.28/0 -Sb0.07 -G${lineColours[8]} -O -K >> $outfile
            # 50
#            echo ${startX} ${data[11]} ${data[11]} | \
#                psxy $narea $nproj -D0.0875/0 -Sb0.025 -G42/42/42 -O -K >> $outfile
            # 55
#            echo ${startX} ${data[12]} ${data[12]} | \
#                psxy $narea $nproj -D0.1125/0 -Sb0.025 -G21/21/21 -O -K >> $outfile
            # 60
#            echo ${startX} ${data[13]} ${data[13]} | \
#                psxy $narea $nproj -D0.1375/0 -Sb0.025 -G0/0/0 -O -K >> $outfile

            # Add a location label
            echo $startX $minY 14 90 0 3 $(printf "b%07i" ${sites[$nameIndex]}) | \
                pstext -D0.07/-0.2 $narea $nproj -N -O -K >> $outfile
            startX=$(($startX+1))
            nameIndex=$(($nameIndex+1))
            echo "done."
        else
            # Add a location label only
            #echo $startX 0 14 90 0 3 ${sites[$startX]} | \
            #    pstext -D0.07/-0.2 $narea $nproj -N -O -K >> $outfile

            # Actually, skip this site
            nameIndex=$(($nameIndex+1))
            continue
        fi

    done < $infile

    # Add a zero line
    psxy $narea $nproj -W1 -O << ZERO >> $outfile
    $minX 0
    $maxX 0
ZERO

    formats $outfile
}

mapBars(){
    # Plot bar charts at calibration locations on a map.

    area=-R-17/17/43/$(wc -l < $rmsSpeed)
    proj=-Jm0.55c

    # Put the coastline in
    psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile
    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

    dos2unix $rmsSpeed
    while read line; do
        if echo $line | grep -v NaN; then
            data=($(echo $line | tr ",\n" " "))
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[2]}*2.5)" | bc -l) | \
                psxy $area $proj -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[3]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.1/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[4]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.2/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[5]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.3/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[6]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.4/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[7]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.5/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[8]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.6/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[9]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.7/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
            echo ${data[0]} $(echo "scale=4; ${data[1]}+(${data[10]}*2.5)" | bc -l) | \
                psxy $area $proj -D0.8/0 -Sb0.075b${data[1]} -Gblack -Wwhite -O -K >> $outfile
        fi
    done < $rmsSpeed

    # Add model domain
    psxy $area $proj -L -A -W5,black,- -O << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

formats $outfile

}

#mapBars

# Usage:
# normalBars <infile> <yAxisLabel> <yAxisInterval> <xAxisGridInterval> <yAxisMaximumLimitPrecision>
normalBars $lagsSpeed "Phase difference (minutes)" 20 g1 "%.1f"
unset minX maxX minY maxY
normalBars $rmsSpeed "RMS residual (ms@+-1@+)" 0.05 g0 "%.2f"
unset minX maxX minY maxY
minY=0 normalBars $rmsDir "RMS residual (@+o@+)" 10 g0 "%.0f"
unset minX maxX minY maxY
normalBars $lagsDir "Phase difference (minutes)" 60 g1 "%.1f"
