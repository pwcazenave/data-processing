#!/bin/bash

# Script to plot the modelled and observed currents for a small number
# of the calibration sites.

# Available sites
# Group 1: 1-32
# Group 2: 1-8
# Group 3: 1-6
# Group 4: 1-4
# Group 5: 1-7
# Group 6: 1-3

# Plot sites (max 7 sites)
# Group 1: 30
# Group 2: 6
# Group 3: 1
# Group 4: 1
# Group 5: 6
# Group 6: 1, 3

# Figure dimensions
x=8
y=2.7

area1=-R1976-03-17T00:00:00/1976-03-18T00:00:00/0/0.4
area1dir=-R1976-03-17T00:00:00/1976-03-18T00:00:00/-180/180
area2=-R1989-07-01T00:00:00/1989-07-02T00:00:00/0/0.4
area2dir=-R1989-07-01T00:00:00/1989-07-02T00:00:00/-180/180
area3=-R1995-08-17T00:00:00/1995-08-18T00:00:00/0/0.4
area3dir=-R1995-08-17T00:00:00/1995-08-18T00:00:00/-180/180
area4=-R1975-08-24T00:00:00/1975-08-25T00:00:00/0/0.6
area4dir=-R1975-08-24T00:00:00/1975-08-25T00:00:00/-180/180
area5=-R1976-03-16T00:00:00/1976-03-17T00:00:00/0/2.5
area5dir=-R1976-03-16T00:00:00/1976-03-17T00:00:00/-180/180
area6=-R1976-04-15T00:00:00/1976-04-16T00:00:00/0/3
area6dir=-R1976-04-15T00:00:00/1976-04-16T00:00:00/-180/180
area6a=-R1976-04-10T00:00:00/1976-04-11T00:00:00/0/2
area6adir=-R1976-04-10T00:00:00/1976-04-11T00:00:00/-180/180

proj=-JX${x}c/${y}c

outfile=./images/$(basename ${0%.*}).ps

basedir=./raw_data/calibration/currents/dfs0/M
obsdir=/media/z/modelling/data/calib_valid/currents/raw_data/

# Line colours
colours=(red green blue black grey orange purple cyan magenta)
# For the key
mannings=(20 25 32 35 40 45 50 55 60)
# For the vertical labels
groups=(6 6 5 4 3 2 1) # using the group?obs values instead now.

# Which groups (group+(ngroups*4)+6 for speed, group+(ngroups*5)+6 for direction).
# This is the column in the csv file where the appropriate data is to be found.
# Easiest way to get this value is to open the dfs0 file for a particular
# Manning's number and find the current speed and direction columns for
# the group of interest (i.e. site 1 or whatever). Then, add 6 to that number
# to account for the yyyy mm dd hh mm ss in the csv file.
group6speed=(16 18)
group5speed=(33)
group4speed=(19)
group3speed=(25)
group2speed=(36)
group1speed=(132)
group6dir=(19 21)
group5dir=(40)
group4dir=(23)
group3dir=(31)
group2dir=(44)
group1dir=(164)

# Observations data (for the selected sites above only). Best to use MATLAB
# when it's loaded the data to see which site belongs with what 'real' name.
group6obs=(25700 25828)
group5obs=(25797)
group4obs=(15441)
group3obs=(564323)
group2obs=(430337)
group1obs=(26395)
allGroupObs=(${group6obs[@]} ${group5obs[@]} ${group4obs[@]} ${group3obs[@]} ${group2obs[@]} ${group1obs[@]})
set -eu

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain \
    PLOT_DEGREE_FORMAT=F \
    ANNOT_FONT_SIZE=14 \
    LABEL_FONT_SIZE=14 \
    PLOT_DATE_FORMAT=yyyy/mm/dd \
    ANNOT_OFFSET_PRIMARY=0.075c

plotKey(){

    startX=-0.9
    yOff=$(echo "scale=2; $y+1" | bc -l)
    xOff=$(echo "scale=2; $x+0.7" | bc -l)
    inc=0

    # Add a key
    psbasemap -R0/25/0/30 -JX25/30 -X-0.2c -Y-0.2c -B0 -K -P > $outfile
    yPos=26.9
    for ((i=0; i<=${#mannings[@]}; i++)); do
        if [ $i -ne ${#mannings[@]} ]; then
            # Manning's values
            psxy -R -J -B0 -O -K -W10,${colours[i]} << LINE >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) $yPos
            $(echo "scale=2; $startX+$inc+3.2" | bc -l) $yPos
LINE
            pstext -R -J -O -K -D0/-0.5 << MANNINGS >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) $yPos 14 0 0 1 M=${mannings[i]}
MANNINGS
        else # Observed data
            psxy -R -J -B0 -O -K -W10,black,4_8_5_8:0 << LINE >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) $yPos
            $(echo "scale=2; $startX+$inc+3.2" | bc -l) $yPos
LINE
            pstext -R -J -O -K -D0.1/-0.5 << MANNINGS >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) $yPos 14 0 0 1 Obs.
MANNINGS
        fi
        inc=$(echo "scale=2; $inc+2" | bc -l)

    done

    # Add a series of labels through the centre of the figure for each group
    for ((j=0; j<${#groups[@]}; j++)); do
        pstext -R -J -O -K << GROUPS >> $outfile
        11 $(echo "scale=2; ($j*($y+1))+1.6" | bc -l) 12 90 0 1 $(printf b%07i ${allGroupObs[j]})
GROUPS
#        11 $(echo "scale=2; ($j*($y+1))+1.8" | bc -l) 12 90 0 1 Group ${groups[j]}
    done
}

fixDir(){
    # Converts direction ranges from 0-360 to -180-180. Output goes to standard
    # output.

    infile=$1
    groupAnalysis=$2
    awk -F, '{
        if ($'$groupAnalysis'>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'$groupAnalysis'-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'$groupAnalysis'}' $infile
}

plotData(){
    # Plots the model and observed data in a more sane manner than just copypasting
    # huge swathes of text. Also makes it more maintainable.
    #
    # Takes a series of arguments:
    # gmtareaspeed gmtareadir xpos ypos modelspeedgroup modeldirgroup modeldata obsgroups
    areaSpeed=$1    # area#
    areaDir=$2      # area#dir
    xOff=$3         #
    yOff=$4         #
    groupSpeed=$5   # ${group#speed[#]}
    groupDir=$6     # ${group#dir[#]}
    modelGroup=$7   # calibgroup#_points.csv
    obsGroup=$8     # ${group#obs[#]}

    # Add the modelled speeds
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/$modelGroup ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'$groupSpeed'}' \
                ${basedir}${mannings[i]}/$modelGroup | \
                psxy $areaSpeed $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i $obsGroup).csv | \
        psxy $areaSpeed $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Add the modelled directions
    psbasemap $areaDir $proj -Ba1Df3Hg6H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/$modelGroup ]; then
            fixDir ${basedir}${mannings[i]}/$modelGroup $groupDir | \
                psxy $areaDir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    fixDir ${obsdir}/$(printf b%07i $obsGroup).csv 7 | \
        psxy $areaDir $proj -O -K -W2,black,4_8_5_8:0 >> $outfile
}

makePanels(){
    # Create the relevant speed basemaps, and then let plotData() fill in the rest.
    yOff=$(echo "scale=2; $y+1" | bc -l)
    xOff=$(echo "scale=2; $x+1.4" | bc -l)

    # Row 7 (i.e. bottom row)
    psbasemap $area6a $proj -Ba1Df3Hg6H/a0.5f0.1:"ms@+-1@+":WeSn -O -K -X2.2c -Y1.1c -P >> $outfile
    plotData $area6a $area6adir $xOff $yOff ${group6speed[0]} ${group6dir[0]} calibgroup6_points.csv ${group6obs[0]}
    # Row 6
    psbasemap $area6 $proj -Ba1Df3Hg6H/a1f0.2:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area6 $area6dir $xOff $yOff ${group6speed[1]} ${group6dir[1]} calibgroup6_points.csv ${group6obs[1]}
    # Row 5
    psbasemap $area5 $proj -Ba1Df3Hg6H/a1f0.2:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area5 $area5dir $xOff $yOff ${group5speed[0]} ${group5dir[0]} calibgroup5_points.csv ${group5obs[0]}
    # Row 4
    psbasemap $area4 $proj -Ba1Df3Hg6H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area4 $area4dir $xOff $yOff ${group4speed[0]} ${group4dir[0]} calibgroup4_points.csv ${group4obs[0]}
    # Row 3
    psbasemap $area3 $proj -Ba1Df3Hg6H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area3 $area3dir $xOff $yOff ${group3speed[0]} ${group3dir[0]} calibgroup3_points.csv ${group3obs[0]}
    # Row 2
    psbasemap $area2 $proj -Ba1Df3Hg6H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area2 $area2dir $xOff $yOff ${group2speed[0]} ${group2dir[0]} calibgroup2_points.csv ${group2obs[0]}
    # Row 1 (i.e. top row)
    psbasemap $area1 $proj -Ba1Df3Hg6H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area1 $area1dir $xOff $yOff ${group1speed[0]} ${group1dir[0]} calibgroup1_points.csv ${group1obs[0]}
    # Terminate plotting
    psxy -R -J -T -O >> $outfile
}

plotKey
makePanels
formats $outfile


