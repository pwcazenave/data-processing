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

# Plot sites
# Group 1: 16, 19, 27, 30
# Group 2: 6
# Group 3: 1
# Group 4: 1
# Group 5: ... # These don't appear very right at the moment
# Group 6: ... # ...

x=8
y=3.12

area1=-R1976-03-17T00:00:00/1976-03-18T00:00:00/0/0.4
area1dir=-R1976-03-17T00:00:00/1976-03-18T00:00:00/-180/180
area2=-R1989-07-01T00:00:00/1989-07-02T00:00:00/0/0.4
area2dir=-R1989-07-01T00:00:00/1989-07-02T00:00:00/-180/180
area3=-R1995-08-17T00:00:00/1995-08-18T00:00:00/0/0.4
area3dir=-R1995-08-17T00:00:00/1995-08-18T00:00:00/-180/180
area4=-R1975-08-24T00:00:00/1975-08-25T00:00:00/0/0.6
area4dir=-R1975-08-24T00:00:00/1975-08-25T00:00:00/-180/180

proj=-JX${x}c/${y}c

outfile=./images/$(basename ${0%.*}).ps

basedir=./raw_data/calibration/currents/dfs0/M
obsdir=../../../../../modelling/data/calib_valid/currents/bodc/raw_data/
colours=(red green blue black grey orange purple cyan magenta)
mannings=(20 25 32 35 40 45 50 55 60)
groups=(4 3 2 1 1 1 1)

# Which groups (group+(ngroups*4)+6 for speed, group+(ngroups*5)+6 for direction), in reverse
# order since we plot the last group first.
group4speed=(19)
group3speed=(25)
group2speed=(36)
group1speed=(118 121 129 132)
group4dir=(23)
group3dir=(31)
group2dir=(44)
group1dir=(150 153 161 164)

# Observations data (for the selected sites above only)
group4obs=(15441)
group3obs=(564323)
group2obs=(430337)
group1obs=(26703 26623 26278 26395)

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
    for ((i=0; i<=${#mannings[@]}; i++)); do
        if [ $i -ne ${#mannings[@]} ]; then
            # Manning's values
            psxy -R -J -B0 -O -K -W10,${colours[i]} << LINE >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) 29.7
            $(echo "scale=2; $startX+$inc+3.2" | bc -l) 29.7
LINE
            pstext -R -J -O -K -D0/-0.5 << MANNINGS >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) 29.7 14 0 0 1 M=${mannings[i]}
MANNINGS
        else # Observed data
            psxy -R -J -B0 -O -K -W10,black,4_8_5_8:0 << LINE >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) 29.7
            $(echo "scale=2; $startX+$inc+3.2" | bc -l) 29.7
LINE
            pstext -R -J -O -K -D0.1/-0.5 << MANNINGS >> $outfile
            $(echo "scale=2; $startX+$inc+2" | bc -l) 29.7 14 0 0 1 Obs.
MANNINGS
        fi
        inc=$(echo "scale=2; $inc+2" | bc -l)

    done

    # Add a series of labels through the centre of the figure for each group
    for ((j=0; j<${#groups[@]}; j++)); do
        pstext -R -J -O -K << GROUPS >> $outfile
        11 $(echo "scale=2; ($j*($y+1))+1.8" | bc -l) 12 90 0 1 Group ${groups[j]}
GROUPS
    done
}

plotFigs(){
    # So, we've got at least 7 sites for speed and direction, giving 14 plots.
    # Let's make a 2x7 portrait grid of figures.

    yOff=$(echo "scale=2; $y+1" | bc -l)
    xOff=$(echo "scale=2; $x+1.4" | bc -l)

    # Remember, we're working in reverse order, so we want calibgroup1 to be last.


    # Row 1

    # Speed
    psbasemap $area4 $proj -Ba1Df3H/a0.3f0.1:"ms@+-1@+":WeSn -O -K -X2.2c -Y1.1c -P >> $outfile
    # Calibgroup 4
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup4_points.csv ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group4speed[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup4_points.csv | \
                psxy $area4 $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i ${group4obs[0]}).csv | \
        psxy $area4 $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Directions
    psbasemap $area4dir $proj -Ba1Df3H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    # Calibgroup 4
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup4_points.csv ]; then
            awk -F, '{
                if ($'${group4dir[0]}'>180)
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group4dir[0]}'-360;
                else
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group4dir[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup4_points.csv | \
                psxy $area4dir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{
        if ($7>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7}' \
        ${obsdir}/$(printf b%07i ${group4obs[0]}).csv | \
        psxy $area4dir $proj -O -K -W2,black,4_8_5_8:0 >> $outfile



    # Row 2

    # Speed
    psbasemap $area3 $proj -Ba1Df3H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    # Calibgroup 3
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup3_points.csv ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group3speed[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup3_points.csv | \
                psxy $area3 $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i ${group3obs[0]}).csv | \
        psxy $area3 $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Directions
    psbasemap $area3dir $proj -Ba1Df3H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    # Calibgroup 3
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup3_points.csv ]; then
            awk -F, '{
                if ($'${group3dir[0]}'>180)
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group3dir[0]}'-360;
                else
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group3dir[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup3_points.csv | \
                psxy $area3dir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{
        if ($7>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7}' \
        ${obsdir}/$(printf b%07i ${group3obs[0]}).csv | \
        psxy $area3dir $proj -O -K -W2,black,4_8_5_8:0 >> $outfile



    # Row 3

    # Speeds
    psbasemap $area2 $proj -Ba1Df3H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    # Calibgroup 2
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup2_points.csv ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group2speed[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup2_points.csv | \
                psxy $area2 $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i ${group2obs[0]}).csv | \
        psxy $area2 $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Directions
    psbasemap $area2dir $proj -Ba1Df3H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    # Calibgroup 2
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup2_points.csv ]; then
            awk -F, '{
                if ($'${group2dir[0]}'>180)
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group2dir[0]}'-360;
                else
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group2dir[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup2_points.csv | \
                psxy $area2dir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{
        if ($7>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7}' \
        ${obsdir}/$(printf b%07i ${group2obs[0]}).csv | \
        psxy $area2dir $proj -O -K -W2,black,4_8_5_8:0 >> $outfile



    # Row 4

    # Speeds
    psbasemap $area1 $proj -Ba1Df3H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    # Calibgroup 1 (first set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1speed[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1 $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i ${group1obs[0]}).csv | \
        psxy $area1 $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Directions
    psbasemap $area1dir $proj -Ba1Df3H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    # Calibgroup 1 (first set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{
                if ($'${group1dir[0]}'>180)
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[0]}'-360;
                else
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[0]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1dir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{
        if ($7>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7}' \
        ${obsdir}/$(printf b%07i ${group1obs[0]}).csv | \
        psxy $area1dir $proj -O -K -W2,black,4_8_5_8:0 >> $outfile


    # Row 5

    # Speeds
    psbasemap $area1 $proj -Ba1Df3H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    # Calibgroup 1 (second set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1speed[1]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1 $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i ${group1obs[1]}).csv | \
        psxy $area1 $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Directions
    psbasemap $area1dir $proj -Ba1Df3H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    # Calibgroup 1 (second set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{
                if ($'${group1dir[1]}'>180)
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[1]}'-360;
                else
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[1]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1dir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{
        if ($7>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7}' \
        ${obsdir}/$(printf b%07i ${group1obs[1]}).csv | \
        psxy $area1dir $proj -O -K -W2,black,4_8_5_8:0 >> $outfile



    # Row 6

    # Speeds
    psbasemap $area1 $proj -Ba1Df3H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    # Calibgroup 1 (third set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1speed[2]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1 $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i ${group1obs[2]}).csv | \
        psxy $area1 $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Directions
    psbasemap $area1dir $proj -Ba1Df3H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    # Calibgroup 1 (third set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{
                if ($'${group1dir[2]}'>180)
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[2]}'-360;
                else
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[2]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1dir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{
        if ($7>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7}' \
        ${obsdir}/$(printf b%07i ${group1obs[2]}).csv | \
        psxy $area1dir $proj -O -K -W2,black,4_8_5_8:0 >> $outfile



    # Row 7

    # Speeds
    psbasemap $area1 $proj -Ba1Df3H/a0.2f0.05:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    # Calibgroup 1 (fourth set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1speed[3]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1 $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i ${group1obs[3]}).csv | \
        psxy $area1 $proj -O -K -W2,black,4_8_5_8:0 >> $outfile

    # Directions
    psbasemap $area1dir $proj -Ba1Df3H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    # Calibgroup 1 (fourth set)
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/calibgroup1_points.csv ]; then
            awk -F, '{
                if ($'${group1dir[3]}'>180)
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[3]}'-360;
                else
                    printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$'${group1dir[3]}'}' \
                ${basedir}${mannings[i]}/calibgroup1_points.csv | \
                psxy $area1dir $proj -O -K -W1,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{
        if ($7>180)
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7-360;
        else
            printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$7}' \
        ${obsdir}/$(printf b%07i ${group1obs[3]}).csv | \
        psxy $area1dir $proj -O -W2,black,4_8_5_8:0 >> $outfile

}

plotKey
plotFigs
formats $outfile


