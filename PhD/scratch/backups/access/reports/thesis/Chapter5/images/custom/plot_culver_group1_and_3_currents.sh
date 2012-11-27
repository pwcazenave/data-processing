#!/bin/bash

# Plot the three current meters from group 3 and the corresponding
# model output.

# We're plotting sites 1, 3 and 5 from both the BODC data and the dfs0 file.

set -eu

basedir=./raw_data/calibration/currents/dfs0/M
obsdir=$HOME/modelling/data/calib_valid/round_10_culver/currents/

# Which columns in the csv file of the dfs0 file. Easiest to get by opening
# the dfs0 file and counting the column in which the info you want is and
# adding six for the time (YY M DD HH MM SS).
group3speed=(28 30 32)
group3dir=(35 37 39)
group1speed=(22)
group1dir=(27)

# BODC site numbers (as per the csv file names). Make sure the order matches
# that in group3{speed,dir}!
group3obs=(21575 21551 21526)
group1obs=(71664)

mannings=(var)

# Line colour for the modelled data
colours=(blue)

outfile=./images/culver_sands_group1_and_3_currents.ps

# Plot extents
area1=-R1978-04-25T00:00:00/1978-04-29T00:00:00/0/2
area1dir=-R1978-04-25T00:00:00/1978-04-29T00:00:00/-180/180
area3=-R1976-06-28T00:00:00/1976-07-02T00:00:00/0/2
area3dir=-R1976-06-28T00:00:00/1976-07-02T00:00:00/-180/180

# Figure dimensions (cm)
x=8
y=2.7

proj=-JX${x}c/${y}c

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain \
    PLOT_DEGREE_FORMAT=F \
    ANNOT_FONT_SIZE=14 \
    LABEL_FONT_SIZE=14 \
    PLOT_DATE_FORMAT=yyyy/mm/dd \
    ANNOT_OFFSET_PRIMARY=0.075c

# We've got three of each (speed and direction)

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
                psxy $areaSpeed $proj -O -K -W4,${colours[i]} >> $outfile
        fi
    done
    # Add the observations
    awk -F, '{printf "%4i-%02i-%02iT%02i:%02i:%02i %.10f\n", $1,$2,$3,$4,$5,$6,$8/100}' \
        ${obsdir}/$(printf b%07i $obsGroup).csv | \
        psxy $areaSpeed $proj -O -K -W4,green >> $outfile
    set -x
    # Add the modelled directions
    psbasemap $areaDir $proj -Ba2Df6Hg12H/a180f90:,-"@+o@+":wESn -O -K -X${xOff}c -P >> $outfile
    for ((i=0; i<${#mannings[@]}; i++)); do
        if [ -e ${basedir}${mannings[i]}/$modelGroup ]; then
            fixDir ${basedir}${mannings[i]}/$modelGroup $groupDir | \
                psxy $areaDir $proj -O -K -W4,${colours[i]} >> $outfile
        fi
    done
    set +x
    # Add the observations
    fixDir ${obsdir}/$(printf b%07i $obsGroup).csv 7 | \
        psxy $areaDir $proj -O -K -W4,green >> $outfile

}

makePanels(){
    # Create the relevant speed basemaps, and then let plotData() fill in the rest.
    yOff=$(echo "scale=2; $y+1" | bc -l)
    xOff=$(echo "scale=2; $x+1.4" | bc -l)

    # Initiate plotting
    psbasemap -R0/25/0/30 -JX25/30 -X-0.2c -Y-0.2c -B0 -K -P > $outfile

    # Row 4 (i.e. bottom row) (group 3, site 1)
    psbasemap $area3 $proj -Ba2Df6Hg12H/a1f0.2:"ms@+-1@+":WeSn -O -K -X2.2c -Y1.1c -P >> $outfile
    plotData $area3 $area3dir $xOff $yOff ${group3speed[2]} ${group3dir[2]} calibgroup3_HMvar_SM32_d50_var_microns_decoupling_points.csv ${group3obs[0]}
    # Row 3 (group 3, site 2)
    psbasemap $area3 $proj -Ba2Df6Hg12H/a1f0.2:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area3 $area3dir $xOff $yOff ${group3speed[1]} ${group3dir[1]} calibgroup3_HMvar_SM32_d50_var_microns_decoupling_points.csv ${group3obs[1]}
    # Row 2 (group 3, site 3)
    psbasemap $area3 $proj -Ba2Df6Hg12H/a1f0.2:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area3 $area3dir $xOff $yOff ${group3speed[0]} ${group3dir[0]} calibgroup3_HMvar_SM32_d50_var_microns_decoupling_points.csv ${group3obs[2]}
    # Row 1 (group1, site 1)
    psbasemap $area1 $proj -Ba2Df6Hg12H/a1f0.2:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area1 $area1dir $xOff $yOff ${group1speed[0]} ${group1dir[0]} calibgroup1_HMvar_SM32_d50_var_microns_decoupling_points.csv ${group1obs[0]}

    # Terminate plotting
    psxy -R -J -T -O >> $outfile

}


makePanels
formats $outfile
