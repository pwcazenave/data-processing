#!/bin/bash

# Plot the three ADCPs from the bank and the corresponding model output.

# We're plotting sites 1 and 1-2 from both the BODC data and the dfs0
# file.

set -eu

basedir=./raw_data/calibration/currents/dfs0/M
obsdir=$HOME/modelling/data/calib_valid/round_11_hsb/currents/raw_data/

# Which columns in the csv file of the dfs0 file. Easiest to get by opening
# the dfs0 file and counting the column in which the info you want is and
# adding six for the time (YY M DD HH MM SS).
group9speed=(16 17)
group9dir=(19 20)
group10speed=(10)
group10dir=(11)

# BODC site numbers (as per the csv file names). Make sure the order matches
# that in group{9,10}{speed,dir}!
group9obs=(2 3)
group10obs=(1)

mannings=(var)

# Line colour for the modelled data
colours=(blue)

outfile=./images/hsb_group9-10_Mvar_currents.ps

# Plot extents
area9=-R2005-06-07T00:00:00/2005-06-11T00:00:00/0/1.5
area9dir=-R2005-06-07T00:00:00/2005-06-11T00:00:00/-180/180
area10=-R2005-06-20T00:00:00/2005-06-24T00:00:00/0/1.5
area10dir=-R2005-06-20T00:00:00/2005-06-24T00:00:00/-180/180

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

# We've got five of each (speed and direction)

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
    # Create the relevant speed basemaps, and then let plotData() fill in the
    # rest.
    yOff=$(echo "scale=2; $y+1" | bc -l)
    xOff=$(echo "scale=2; $x+1.4" | bc -l)

    # Initiate plotting
    psbasemap -R0/25/0/30 -JX25/30 -X-0.2c -Y-0.2c -B0 -K -P > $outfile

    # Generally travelling from south to north such that the plots reflect the
    # map
    # Row 5 (i.e. bottom row) (group 9, site 3)
    psbasemap $area9 $proj -Ba2Df6Hg12H/a0.5f0.1:"ms@+-1@+":WeSn -O -K -X2.2c -Y1.1c -P >> $outfile
    plotData $area9 $area9dir $xOff $yOff ${group9speed[1]} ${group9dir[1]} calibgroup9_HMvar_SM32_d50_var_microns_points.csv ${group9obs[1]}
    # Row 4 (group 9, site 2)
    psbasemap $area9 $proj -Ba2Df6Hg12H/a0.5f0.1:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area9 $area9dir $xOff $yOff ${group9speed[0]} ${group9dir[0]} calibgroup9_HMvar_SM32_d50_var_microns_points.csv ${group9obs[0]}
    # Row 3 (group 10, site 1)
    psbasemap $area10 $proj -Ba2Df6Hg12H/a0.5f0.1:"ms@+-1@+":WeSn -O -K -X-${xOff}c -Y${yOff}c -P >> $outfile
    plotData $area10 $area10dir $xOff $yOff ${group10speed[0]} ${group10dir[0]} calibgroup10_HMvar_SM32_d50_var_microns_points.csv ${group10obs[0]}

    # Terminate plotting
    psxy -R -J -T -O >> $outfile

}


makePanels
formats $outfile
