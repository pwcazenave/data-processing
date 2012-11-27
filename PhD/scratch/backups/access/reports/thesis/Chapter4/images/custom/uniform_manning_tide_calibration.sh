#!/bin/bash

# Script to plot the results of the uniform Manning's number models as
# pie charts on a map of the UK.

area=-R-17/17/43/67
proj=-Jm0.55c

nproj=-JX26.8c/15.5c

rms=./raw_data/mike_gebco_00ka_v9_M5-M60_2003-01-28_NTSLF-SHOM-NHS_tides_rmsamp_results.csv
std=./raw_data/mike_gebco_00ka_v9_M5-M60_2003-01-28_NTSLF-SHOM-NHS_tides_stdamp_results.csv
lags=./raw_data/mike_gebco_00ka_v9_M5-M60_2003-01-28_NTSLF-SHOM-NHS_tides_phase_results.csv

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=16

sites=("Aberdeen" "Bangor" "Barmouth" "Bournemouth" "Cromer" "Devonport" "Dover" "Felixstowe" "Fishguard" "Heysham" "Hinkley Point" "Holyhead" "Ilfracombe" "Kinlochbervie" "Leith" "Lerwick" "Lowestoft" "Milford Haven" "Mumbles" "Newhaven" "Newlyn" "North Shields" "Isle of Man" "Port Rush" "Sheerness" "Jersey" "St. Mary's" "Stornoway" "Tobermory" "Ullapool" "Weymouth" "Whitby" "Wick" "Workington" "Boulogne-sur-Mer" "Brest" "Calais" "Cherbourg" "Concarneau" "Dunkerque" "La Rochelle" "Les Sables D'Olonne" "Le Conquet" "Le Crouesty" "Le Havre" "Alesund" "Bergen" "Heimsjo" "Helgeroa" "Kristiansund" "Maloy" "Oscarsborg" "Oslo" "Rorvik" "Stavanger" "Tregde" "Viker")

normalBars(){
    # Bar chart of the calibration results on normal axes.

    infile="$1"
    annotation="$2"
    outfile=./images/$(basename ${1%.*}).ps
    inc=$3

    # More dynamic area required here
    minX=-1
    maxX=$(grep -v NaN $infile | wc -l)
    minY=$(printf "%.0f\n" $(awk -F, '{print $3,$4,$5,$6,$7,$8,$9,$10,$11}' $infile | minmax -C | tr "\t" "\n" | minmax -C | awk '{print $1}'))
    maxY=$(printf "%.1f\n" $(awk -F, '{print $3,$4,$5,$6,$7,$8,$9,$10,$11}' $infile | minmax -C | tr "\t" "\n" | minmax -C | awk '{print $2}'))
    narea=-R$minX/$maxX/$minY/$maxY

    makecpt -T0/1.5/0.1 -Z -Crainbow > ./cpts/$(basename ${0%.*}).cpt
    lineColours=($(makecpt -N -T0/65/5 -Cjet --COLOR_MODEL=+HSV | awk '!/#/ {OFS="-"; print $2,$3,$4}'))

    psbasemap $narea $nproj -K -X2.6c -Y5 \
        -B0$4/a${inc}f$(echo "scale=2; $inc/4" | bc -l):"$annotation":WeSn > $outfile

    startX=0
    nameIndex=0

    dos2unix -q $infile

    while read line; do
        if echo $line | grep -v NaN > /dev/null; then
            echo -n "Station $(($startX+1)) of $maxX... "
            data=($(echo $line | tr ",\n" " "))
            # 5
            echo ${startX} ${data[2]} ${data[2]} | \
                psxy $narea $nproj -D-0.1375/0 -Sb0.025 -G${lineColours[0]} -W0.5,gray -O -K >> $outfile
            # 10
            echo ${startX} ${data[3]} ${data[3]} | \
                psxy $narea $nproj -D-0.1125/0 -Sb0.025 -G${lineColours[1]} -W0.5,gray -O -K >> $outfile
            # 15
            echo ${startX} ${data[4]} ${data[4]} | \
                psxy $narea $nproj -D-0.0875/0 -Sb0.025 -G${lineColours[2]} -W0.5,gray -O -K >> $outfile
            # 20
            echo ${startX} ${data[5]} ${data[5]} | \
                psxy $narea $nproj -D-0.0625/0 -Sb0.025 -G${lineColours[3]} -O -K >> $outfile
            # 25
            echo ${startX} ${data[6]} ${data[6]} | \
                psxy $narea $nproj -D-0.0375/0 -Sb0.025 -G${lineColours[4]} -O -K >> $outfile
            # 32
            echo ${startX} ${data[7]} ${data[7]} | \
                psxy $narea $nproj -D-0.0125/0 -Sb0.025 -G${lineColours[5]} -O -K >> $outfile
            # 35
            echo ${startX} ${data[8]} ${data[8]} | \
                psxy $narea $nproj -D0.0125/0 -Sb0.025 -G${lineColours[6]} -O -K >> $outfile
            # 40
            echo ${startX} ${data[9]} ${data[9]} | \
                psxy $narea $nproj -D0.0375/0 -Sb0.025 -G${lineColours[7]} -O -K >> $outfile
            # 45
            echo ${startX} ${data[10]} ${data[10]} | \
                psxy $narea $nproj -D0.0625/0 -Sb0.025 -G${lineColours[8]} -O -K >> $outfile
            # 50
            echo ${startX} ${data[11]} ${data[11]} | \
                psxy $narea $nproj -D0.0875/0 -Sb0.025 -G${lineColours[9]} -O -K >> $outfile
            # 55
            echo ${startX} ${data[12]} ${data[12]} | \
                psxy $narea $nproj -D0.1125/0 -Sb0.025 -G${lineColours[10]} -O -K >> $outfile
            # 60
            echo ${startX} ${data[13]} ${data[13]} | \
                psxy $narea $nproj -D0.1375/0 -Sb0.025 -G${lineColours[11]} -O -K >> $outfile

            # Add a location label
            echo $startX $minY 14 90 0 3 ${sites[$nameIndex]} | \
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

    # Put the coastline in
    psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile
    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

    dos2unix $rms
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
    done < $rms

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
normalBars $lags "Phase difference (minutes)" 120 g1
normalBars $rms "RMS residual (m)" 0.2
