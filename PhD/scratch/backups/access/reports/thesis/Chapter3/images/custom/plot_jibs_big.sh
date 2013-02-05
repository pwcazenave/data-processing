#!/bin/bash

# Script to plot the ASTER GDEM data. May have results at some point too...

gmtdefaults -D > .gmtdefaults4
gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16 BASEMAP_TYPE=plain COLOR_BACKGROUND=purple COLOR_FOREGROUND=red

ingrd=./grids/jibs_50m.grd
#infiles=(./raw_data/wadialdawasserairport_2009-2011_no_header.csv ./raw_data/najran_2009-2011_no_header.csv ./raw_data/sharurah_2009-2011_no_header.csv)
#analyses=(./raw_data/wadi_al-dawasir_analysis.csv ./raw_data/najran_analysis.csv ./raw_data/sharurah_analysis.csv)

area=$(grdinfo -I100 $ingrd)
#area=-R603500/619000/5616500/5627400
proj=-Jx4e-4

overallarea=-R70/100/0/45
overallproj=-Jm0.075

hproj=-JX3.4c/2c

harea=-R0/5/0/10 # for the results histograms
harea2=-R0/360/0/100 # for the roses
warea=-R150/300/0/15 # wavelength
darea=-R0/180/0/15 # orientation
adarea=-R0/360/0/15 # asymmetry direction
aarea=-R0/10/0/10 # asymmetry
rarea=-R0/15/0/360 # roses
parea=-R0/310000/-20000/60000 # PVDs

# Wind stations
windNames=("Wadi al-Dawasir" "Najran" "Sharurah")
windStationsX=(522359 435679 725830)
windStationsY=(2265836 1948088 1933809)

xPosRose=(-1 6 6)
colours=(red blue black)
coloursLight=(pink lightblue white)

outfile=./images/$(basename ${ingrd%.*}).ps
results=./raw_data/jibs_2500m_subset_results_errors_asymm.csv

set -eu

prep(){
	grdgradient -Nt1.1 -A90 $ingrd -G${ingrd%.*}_grad.grd
}

plot_topo(){
	makecpt $(grdinfo -T10 $ingrd) -Z -Crainbow > ./cpts/$(basename ${ingrd%.*}).cpt
#	makecpt -T-160/-60/0.5 -Z -Crainbow > ./cpts/$(basename ${ingrd%.*}).cpt
	#grd2cpt $ingrd -Cgray -Z > ./cpts/$(basename ${ingrd%.*}).cpt

	psbasemap $area $proj -X4c -Y5.5c -K -Ba10000f2000:"Eastings":/a5000f1000:"Northings":WeSn \
		> $1
	echo 1 1 1 | xyz2grd $area -I10000 -G./grids/nans.grd
	grdimage $area $proj -C./cpts/$(basename ${ingrd%.*}).cpt \
    	./grids/nans.grd -O -K >> $1
	grdimage $area $proj -C./cpts/$(basename ${ingrd%.*}).cpt -I${ingrd%.*}_grad.grd \
		$ingrd -O -K >> $1
	psscale -D0.5/6.5/5/0.3 -Ba50f10:"Depth (m)": \
    	--ANNOT_FONT_SIZE=12 \
		-C./cpts/$(basename ${ingrd%.*}).cpt -I -O -K >> $1
}

add_location(){
	gmtset ANNOT_FONT_SIZE=9 LABEL_FONT_SIZE=9 BASEMAP_TYPE=plain ANNOT_OFFSET=0.05c PLOT_DEGREE_FORMAT=+F
	psbasemap $overallarea $overallproj -Ba20/a10WesN -O -K -X10.5 -Y0.5 >> $1
	pscoast $overallarea $overallproj -Dl -A1000 -O -K -W -Ggray -Swhite >> $1
	psxy $overallarea $overallproj -W2,black -O -K -Glightgrey -L << BOX >> $1
75 35
75 43
90 43
90 35
BOX

#	pscoast $overallarea $overallproj -Dl -A1000 -O -K -W -N1 >> $1
	pstext $overallarea $overallproj -O -K << LABELS >> $1
34 14 10 80 0 1 Africa
50 33 10 0 0 1 Eurasia
40 26 10 0 0 1 Arabian
41 23.5 10 0 0 1 Peninsula
56 13 10 0 0 1 Arabian Sea
LABELS
	gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18 BASEMAP_TYPE=plain
}

add_scale(){
    # Take arguments and get scale values
    startX=$2
    endX=$(echo "scale=0; $startX+10000" | bc -l)
    midX=$(echo "scale=0; $startX+(($endX-$startX)/2)" | bc -l)
    startY=$3

	# Add a rudimentary scale
	psxy $area $proj -O -K -W30,white << WHITE >> $1
    $startX $startY
    $endX $startY
WHITE
	psxy $area $proj -O -K -W30,black << BLACK >> $1
    $startX $startY
    $midX $startY
BLACK
    pstext $area $proj -D-0.25c/0.4c -O -K -Gwhite << LABEL >> $1
$startX $startY 12 0 0 1 0
$(($midX+50)) $startY 12 0 0 1 5
$endX $startY 12 0 0 1 10 km
LABEL
}

add_results(){
	# Height (as a scaled circle)
#	awk -F, '{if ($15==1) print $1,$2,$5*0.01}' $results | \
#		psxy $area $proj -O -K -Sc -W4,white >> $1
	# Wavelength/orientation
	awk -F, '{if ($15==1 && $3>4) print $1,$2,$4+90,$3*0.005}' $results | \
		psxy $area $proj -O -K -SVb0/0/0 -W6,black -Gblack >> $1
    # Asymmetry direction
    awk -F, '{if ($15==1 && $3>4) print $1,$2,$14,$19*0.08}' $results | grep -v NaN | \
		psxy $area $proj -O -K -SVt0/0.1/0.05 -Gblack -W6,black --D_FORMAT=%.10f >> $1
#    awk -F, '{if ($15==1 && $11<$12) print $1,$2,$14,0.25}' $results | \
#		psxy $area $proj -O -K -SVt0/0/0 -W4,white >> $1

	# Custom symbol rotated to the crest orientation
	# WARNING: Filtering heights to a maximum of 4m to eliminate
	# crappy results in bedrocky areas.
	awk -F, '{
                hyp=0.1
                if ($15==1) {
                    pi=3.141592654

                    modAng=($14+90)%180

                    deg2radStart=(pi/180)*modAng
                    deg2radEnd=(pi/180)*(modAng-180)

                    xPos=hyp*sin(deg2radStart)
                    yPos=hyp*cos(deg2radStart)
                    xPosEnd=hyp*sin(deg2radEnd)
                    yPosEnd=hyp*cos(deg2radEnd)

                    if ($11<$12) {
                        startRot=atan2(yPos,xPos)*(180/pi)
                        endRot=atan2(yPosEnd,xPosEnd)*(180/pi)
                    } else {
                        startRot=atan2(yPos,xPos)*(180/pi)+180
                        endRot=atan2(yPosEnd,xPosEnd)*(180/pi)+180
                    }
                    print $1,$2,startRot,($5/15),xPos,yPos,-1*xPos,-1*yPos,endRot
                }
	        }' $results > ${results%.*}_symbol.csv
    while read line; do
        tmpArray=($line)
        xPos=${tmpArray[0]}
        yPos=${tmpArray[1]}
        startRot=${tmpArray[2]}
        radiusX=${tmpArray[3]}
        startX=${tmpArray[4]}
        startY=${tmpArray[5]}
        endX=${tmpArray[6]}
        endY=${tmpArray[7]}
        endRot=${tmpArray[8]}

        # Where we're up to
        echo $xPos $yPos

        # Make the custom symbol
        cat << SYMBOL > semicircle.def
# GMT custom symbol for semicircle
${startX} ${startY} M
${startX} ${startY} 5 ${startRot} ${endRot} A
#${startX} ${startY} D
SYMBOL

        # Do the plot
        echo $xPos $yPos | \
            psxy $area $proj -O -K -Sksemicircle/${radiusX} -W6,black \
                >> ${outfile%.*}_results.ps
    done < ${results%.*}_symbol.csv

	# Add a scale
    # 50m*0.005=0.25 (0.005=scaling factor from above)
	echo "640000 6137000 90 0.25" | \
    	psxy $area $proj -O -K -SVb0/0/0 -W6,black -Gblack >> $1
	echo "640000 6138000 0.25" | \
    	psxy $area $proj -O -K -Sc -W6,black >> $1
	pstext $area $proj -O -K -D0.5/-0.1 -WwhiteO0,white << LABEL >> $1
	640000 6137000 10 0 0 1 50 m wavelength
	640000 6138000 10 0 0 1 1 m height
LABEL
}

add_histograms(){
	# Add in the histograms
	gmtset ANNOT_FONT_SIZE=12
	gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
	# Filter out all values below the nyquist frequency (60m)
	awk -F, '{if ($3>2 && $15==1) print $5}' $results | \
		pshistogram $harea $hproj -W0.05 -Ggray -L1,gray -O -K -Z1 \
	   	-Ba2f0.5:,"-m":/a5f1:,"-%":WeSn -X2.8c -Y-4.75c >> $1
    awk -F, '{if ($3>2 && $15==1) print $14}' $results | \
		pshistogram $adarea $hproj -W5 -Ggray -L1,gray -O -K -T0 -Z1 \
      	-Ba180f20:,"-@+o@+":/a5f1:,"-%":WeSn -X5.2c >> $1
    awk -F, '{if ($3>2 && $15==1) print $3}' $results | \
    	pshistogram $warea $hproj -W1 -Ggray -L1,gray -O -K -Z1 \
    	-Ba75f25:,"-m":/a5f1:,"-%":WeSn -X5.2c >> $1
    awk -F, '{if ($3>2 && $15==1) print $19}' $results | grep -v NaN | \
    	pshistogram $aarea $hproj -W0.1 -Ggray -L1,gray -O -K -Z1 \
    	-Ba2f0.5/a5f1:,"-%":WeSn -X5.2c >> $1
}

add_pvd(){
    windScale=1
    for ((i=0; i<${#analyses[@]}; i++)); do
        numRec=$(wc -l < ${analyses[i]})
        awk -F, '{
            if (NR%10==0)
                print '${windStationsX[i]}'+($3*'$windScale'),'${windStationsY[i]}'+($4*'$windScale')
            }' ${analyses[i]} | \
            psxy $area $proj -Sc0.1 -W${colours[i]} -O -K >> $1
        awk -F, '{
            if (NR==1 || NR=='$numRec')
                print '${windStationsX[i]}'+($3*'$windScale'),'${windStationsY[i]}'+($4*'$windScale')
            }' ${analyses[i]} | \
            psxy $area $proj -W15,20/20/20 -A -O -K >> $1
        awk -F, '{
            if (NR==1 || NR=='$numRec')
                print '${windStationsX[i]}'+($3*'$windScale'),'${windStationsY[i]}'+($4*'$windScale')
            }' ${analyses[i]} | \
            psxy $area $proj -W5,${coloursLight[i]} -A -O -K >> $1
    done
}

plot_wind_locations(){
    # Add the wind stations
    for ((i=0; i<${#windNames[@]}; i++)); do
        echo ${windStationsX[i]} ${windStationsY[i]} | \
            psxy $area $proj -Sc0.2 -Gblack -O -K >> $1
    done
    for ((i=0; i<${#windNames[@]}; i++)); do
        xOff=0.2
        yOff=-0.3
        if [ $i -eq 0 ]; then
            yOff=0.4
        fi
        if [ $i -eq 2 ]; then
            xOff=1
        fi
        pstext $area $proj -O -K -D$xOff/$yOff << LABEL >> $1
        ${windStationsX[i]} ${windStationsY[i]} 13 0 0 MC ${windNames[i]}
LABEL
    done
}

add_roses(){
    for ((i=0; i<${#infiles[@]}; i++)); do
        tempfile=$(mktemp)
        awk -F, '{if ($10>0) print $8}' ${infiles[i]} | \
            pshistogram $harea2 -Jx1 -W1 -T0 -Z1 -IO 2> /dev/null | \
                awk '{print $2,$1}' > $tempfile
        if [ $i -eq 0 ]; then
            psrose $rarea -A10 -X${xPosRose[i]}c -X-12c -Y-9.5c -S2c -D -T -W5,black -G${colours[i]} \
                $tempfile -Bg5:,-"%":/g30 -LW/E/S/N -O -K >> $1
        else
            psrose $rarea -A10 -X${xPosRose[i]}c -S2c -D -T -W5,black -G${colours[i]} \
                $tempfile -Bg5:,-"%":/g30 -LW/E/S/N -O -K >> $1
        fi
        rm -f $tempfile
    done
}

prep

#plot_topo $outfile
#add_scale $outfile 925000 7425000
##add_location $outfile
#psxy -R -J -T -O >> $outfile
#formats $outfile
#mv $outfile ./images/ps
#mv ${outfile%.*}.png ./images/png/

plot_topo ${outfile%.*}_results.ps
add_scale ${outfile%.*}_results.ps 670200 6117750
add_results ${outfile%.*}_results.ps
#add_pvd ${outfile%.*}_results.ps
#plot_wind_locations ${outfile%.*}_results.ps
add_histograms ${outfile%.*}_results.ps
#add_roses ${outfile%.*}_results.ps
psxy -R -J -T -O >> ${outfile%.*}_results.ps
formats ${outfile%.*}_results.ps
mv ${outfile%.*}_results.png ./images/png/
mv ${outfile%.*}_results.ps ./images/ps