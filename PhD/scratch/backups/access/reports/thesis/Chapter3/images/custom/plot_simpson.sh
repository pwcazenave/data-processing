#!/bin/bash

# Script to plot the ASTER GDEM data. May have results at some point too...

gmtdefaults -D > .gmtdefaults4
gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16 BASEMAP_TYPE=plain COLOR_BACKGROUND=purple COLOR_FOREGROUND=red

ingrd=./grids/srtm_64_17-18_utm_250m.grd
#infiles=(./raw_data/wadialdawasserairport_2009-2011_no_header.csv ./raw_data/najran_2009-2011_no_header.csv ./raw_data/sharurah_2009-2011_no_header.csv)
#analyses=(./raw_data/wadi_al-dawasir_analysis.csv ./raw_data/najran_analysis.csv ./raw_data/sharurah_analysis.csv)

area=$(grdinfo -I100 $ingrd)
proj=-Jx2.9e-5

overallarea=-R110/160/-45/-10
overallproj=-Jm0.075

hproj=-JX2.5c/1.9c

harea=-R0/30/0/25 # for the results histograms
harea2=-R0/360/0/100 # for the roses
warea=-R0/2/0/20 # wavelength
darea=-R0/180/0/45 # orientation
adarea=-R0/360/0/45 # asymmetry direction
aarea=-R0/2.5/0/30 # asymmetry
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
results=./raw_data/srtm_15000m_subset_results_errors_asymm.csv

set -eu

prep(){
	grdgradient -Nt1.1 -A70 $ingrd -G${ingrd%.*}_grad.grd
}

plot_topo(){
#	makecpt $(grdinfo -T10 $ingrd) -Z -Crainbow > ./cpts/$(basename ${ingrd%.*}).cpt
	makecpt -T0/350/10 -Z -Crainbow > ./cpts/$(basename ${ingrd%.*}).cpt
	#grd2cpt $ingrd -Cgray -Z > ./cpts/$(basename ${ingrd%.*}).cpt

	psbasemap $area $proj -X4c -Y12c -K -Ba200000f50000:"Eastings":/a100000f20000:"Northings":WeSn \
		-P > $1
	echo 1 1 1 | xyz2grd $area -I10000 -G./grids/nans.grd
	grdimage $area $proj -C./cpts/$(basename ${ingrd%.*}).cpt \
    	./grids/nans.grd -O -K >> $1
	grdimage $area $proj -C./cpts/$(basename ${ingrd%.*}).cpt -I${ingrd%.*}_grad.grd \
		$ingrd -O -K >> $1
	psscale -D0.5/3.2/5/0.3 -Ba100f50:"Height (m)": \
    	--ANNOT_FONT_SIZE=12 \
		-C./cpts/$(basename ${ingrd%.*}).cpt -I -O -K >> $1
}

add_location(){
	gmtset ANNOT_FONT_SIZE=9 LABEL_FONT_SIZE=9 BASEMAP_TYPE=plain ANNOT_OFFSET=0.05c PLOT_DEGREE_FORMAT=+F
	psbasemap $overallarea $overallproj -Ba20/a10WesN -O -K -X10.5 -Y0.5 >> $1
	pscoast $overallarea $overallproj -Dl -A1000 -O -K -W -Ggray -Swhite >> $1
	psxy $overallarea $overallproj -W2,black -O -K -Glightgrey -L << BOX >> $1
135 -28
135 -23
140 -23
140 -28
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
    endX=$(echo "scale=0; $startX+50000" | bc -l)
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
    pstext $area $proj -D-0.25c/0.4c -O -K << LABEL >> $1
$startX $startY 12 0 0 1 0
$midX $startY 12 0 0 1 25
$endX $startY 12 0 0 1 50 km
LABEL
}

add_results(){
	# Height (as a scaled circle)
#	awk -F, '{if ($15==1) print $1,$2,$5*0.01}' $results | \
#		psxy $area $proj -O -K -Sc -W4,white >> $1
	# Wavelength/orientation
	awk -F, '{if ($15==1 && $3>180) print $1,$2,$4+90,$3*0.00025}' $results | \
		psxy $area $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $1
    # Asymmetry direction
    # Flipped direction by 180 degrees.
    awk -F, '{if ($15==1 && $3>180) print $1,$2,$14+180,$19*0.15}' $results | grep -v NaN | \
		psxy $area $proj -O -K -SVt0/0.1/0.05 -Gwhite -W4,white --D_FORMAT=%.10f >> $1
#    awk -F, '{if ($15==1 && $11<$12) print $1,$2,$14,0.25}' $results | \
#		psxy $area $proj -O -K -SVt0/0/0 -W4,white >> $1

	# Custom symbol rotated to the crest orientation
    # Flipped asymmetry direction by 180 degrees ($11<$12 originally)
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

                    if ($11>$12) {
                        startRot=atan2(yPos,xPos)*(180/pi)
                        endRot=atan2(yPosEnd,xPosEnd)*(180/pi)
                    } else {
                        startRot=atan2(yPos,xPos)*(180/pi)+180
                        endRot=atan2(yPosEnd,xPosEnd)*(180/pi)+180
                    }
                    print $1,$2,startRot,($5/250),xPos,yPos,-1*xPos,-1*yPos,endRot
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
            psxy $area $proj -O -K -Sksemicircle/${radiusX} -W5,white \
                >> ${outfile%.*}_results.ps
    done < ${results%.*}_symbol.csv

	# Add a scale
    # 2km*0.00025=0.5 (0.00025=scaling factor from above)
	echo "905000 6925000 0 0.5" | \
    	psxy $area $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $1
 	echo "905000 6950000 0.25" | \
    	psxy $area $proj -O -K -Sc -W4,white >> $1
	pstext $area $proj -O -K -D0.3/-0.1 -WwhiteO0,white << LABEL >> $1
	905000 6925000 10 0 0 1 2 km wavelength
	905000 6950000 10 0 0 1 10 m height
LABEL
}

add_histograms(){
	# Add in the histograms
	gmtset ANNOT_FONT_SIZE=12
	gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
	# Filter out all values below the nyquist frequency (60m)
	awk -F, '{if ($3>60 && $15==1) print $5}' $results | \
		pshistogram $harea $hproj -W2 -Ggray -L1,gray -O -K -Z1 \
	   	-Ba10f5:,"-m":/a15f5:,"-%":WeSn -X0c -Y-5c >> $1
    awk -F, '{if ($3>60 && $15==1) print ($14+180)%360}' $results | \
		tr " " "\n" | \
		pshistogram $adarea $hproj -W5 -Ggray -L1,gray -O -K -T0 -Z1 \
      	-Ba180f20:,"-@+o@+":/a20f5:,"-%":WeSn -X4c >> $1
    awk -F, '{if ($3>60 && $15==1) print $3/1000}' $results | \
    	pshistogram $warea $hproj -W0.06 -Ggray -L1,gray -O -K -Z1 \
    	-Ba1f0.5:,"-km":/a10f2:,"-%":WeSn -X4c >> $1
    awk -F, '{if ($3>60 && $15==1) print $19}' $results | grep -v NaN | \
    	pshistogram $aarea $hproj -W0.1 -Ggray -L1,gray -O -K -Z1 \
    	-Ba1f0.2/a10f2:,"-%":WeSn -X4c >> $1
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

#prep

#plot_topo $outfile
#add_scale $outfile 925000 7425000
##add_location $outfile
#psxy -R -J -T -O >> $outfile
#formats $outfile
#mv $outfile ./images/ps
#mv ${outfile%.*}.png ./images/png/

plot_topo ${outfile%.*}_results.ps
add_scale ${outfile%.*}_results.ps 925000 7425000
add_results ${outfile%.*}_results.ps
#add_pvd ${outfile%.*}_results.ps
#plot_wind_locations ${outfile%.*}_results.ps
add_histograms ${outfile%.*}_results.ps
#add_roses ${outfile%.*}_results.ps
psxy -R -J -T -O >> ${outfile%.*}_results.ps
formats ${outfile%.*}_results.ps
#mv ${outfile%.*}_results.png ./images/png/
#mv ${outfile%.*}_results.ps ./images/ps
