#!/bin/bash

# Script to plot the ASTER GDEM data. May have results at some point too...

gmtdefaults -D > .gmtdefaults4
gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18 BASEMAP_TYPE=plain COLOR_BACKGROUND=purple COLOR_FOREGROUND=red

ingrd=./grids/aster_gdem_utm_90m.grd
#ingrd=./grids/aster_gdem_utm_250m.grd
interp_big=./raw_data/aster_big_extents.csv
interp_little=./raw_data/aster_little_extents.csv

area=$(grdinfo -I100 $ingrd)
proj=-Jx3.2e-5

overallarea=-R30/70/10/40
overallproj=-Jm0.17

hproj=-JX3.2/2

harea=-R0/120/0/10
warea=-R1000/3500/0/15
darea=-R0/180/0/30
aarea=-R0/2.5/0/20

outfile=./images/$(basename ${ingrd%.*}).ps
results=./raw_data/aster_gdem_30000m_subset_results_errors_asymm.csv

set -eu

prep(){
	grdgradient -Nt1.1 -A160 $ingrd -G${ingrd%.*}_grad.grd
}

plot_topo(){
	#makecpt $(grdinfo -T10 $ingrd) -Z -Cgray > ./cpts/$(basename ${ingrd%.*}).cpt
	makecpt -T200/1200/10 -Z -Crainbow > ./cpts/$(basename ${ingrd%.*}).cpt
	#grd2cpt $ingrd -Cgray -Z > ./cpts/$(basename ${ingrd%.*}).cpt

	psbasemap $area $proj -X4c -K -Ba100000f20000:"Eastings":/a100000f20000:"Northings":WeSn \
		> $1
	grdimage $area $proj -C./cpts/$(basename ${ingrd%.*}).cpt -I${ingrd%.*}_grad.grd \
		$ingrd -O -K >> $1
	gmtset ANNOT_FONT_SIZE=14
	psscale -D10.75/2.6/6/0.4h -Ba400f100:"Height (m)": \
		-C./cpts/$(basename ${ingrd%.*}).cpt -I -O -K >> $1
	gmtset ANNOT_FONT_SIZE=18
}

plot_subset(){
#    swest=562768
#    seast=796052
#    ssouth=2099159
#    snorth=2227000

    swest=$((562768+250000))
    seast=$((696052+200000))
    ssouth=2099159
    snorth=2180000

    sarea=-R$swest/$seast/$ssouth/$snorth
    sproj=-Jx5e-5

    makecpt -T375/450/1 -Z -Crainbow > ./cpts/$(basename ${ingrd%.*})_subset.cpt

    # Overlay box
    psxy $area $proj -O -K -W7,black,- -L -X-16.3 -Y-0.5 << BOX >> $1
    $swest $ssouth
    $swest $snorth
    $seast $snorth
    $seast $ssouth
BOX
    # Add the other two subsets
    psxy $area $proj -O -K -W7,black -L << BOX1 >> $1
    620000 2110000
    645000 2110000
    645000 2140000
    620000 2140000
BOX1
    psxy $area $proj -O -K -W7,black -L << BOX2 >> $1
    600000 2054000
    625000 2054000
    625000 2084000
    600000 2084000
BOX2
    pstext $area $proj -D0.1/0.1 -O -K << TEXT >> $1
    620000 2110000 14 0 0 1 A
    599500 2054000 14 0 0 1 B
TEXT

    # Add the subset image
	#psbasemap $sarea $sproj -B0 -X15c -Y1.2c -O -K >> $1
	psbasemap $sarea $sproj -B0 -X0.3c -Y13.5c -O -K >> $1
    grdimage $sarea $sproj -O -K -C./cpts/$(basename ${ingrd%.*})_subset.cpt -I${ingrd%.*}_grad.grd \
        $ingrd >> $1

#    psscale -D4/-0.2/7/0.2h -Ba25f5:,-m: -C./cpts/$(basename ${ingrd%.*})_subset.cpt \
#        -I -O -K --ANNOT_FONT_SIZE=10 --LABEL_FONT_SIZE=10 --ANNOT_OFFSET=0.05c --LABEL_OFFSET=0.05c >> $1
    psscale -D4.5/2/3.5/0.3 -Ba25f5:,-m: -C./cpts/$(basename ${ingrd%.*})_subset.cpt \
        -I -O -K --ANNOT_FONT_SIZE=10 --LABEL_FONT_SIZE=10 --ANNOT_OFFSET=0.05c --LABEL_OFFSET=0.05c >> $1
}

add_location(){
	gmtset ANNOT_FONT_SIZE=9 LABEL_FONT_SIZE=9 BASEMAP_TYPE=plain ANNOT_OFFSET=0.05c PLOT_DEGREE_FORMAT=+F
	psbasemap $overallarea $overallproj -Ba10WesN -O -K -X16.3 -Y0.5 >> $1
	pscoast $overallarea $overallproj -Dl -A1000 -O -K -W -Ggray -Swhite >> $1
	psxy $overallarea $overallproj -W2,black -O -K -Glightgrey -L << BOX >> $1
45 16
45 21
52 21
52 16
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
    endX=$(echo "scale=0; $startX+100000" | bc -l)
    midX=$(echo "scale=0; $startX+(($endX-$startX)/2)" | bc -l)
    startY=$3

	# Add a rudimentary scale
	psxy $area $proj -O -K -W35,white << WHITE >> $1
    $startX $startY
    $endX $startY
WHITE
	psxy $area $proj -O -K -W35,black << BLACK >> $1
    $startX $startY
    $midX $startY
BLACK
    pstext $area $proj -D-0.25c/0.4c -O -K << LABEL >> $1
$startX $startY 14 0 0 1 0
$midX $startY 14 0 0 1 50
$endX $startY 14 0 0 1 100 km
LABEL
}

add_results(){
	# Height (as a scaled circle)
#	awk -F, '{if ($15==1) print $1,$2,$5*0.01}' $results | \
#		psxy $area $proj -O -K -Sc -W4,white >> $1
	# Wavelength/orientation
	awk -F, '{if ($15==1) print $1,$2,$4+90,$3*0.0005}' $results | \
		psxy $area $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $1
    # Asymmetry direction
    awk -F, '{if ($15==1 && $11>$12) print $1,$2,$14,$3/5000}' $results | \
		psxy $area $proj -O -K -SVt0/0.2/0.1 -Gwhite -W4,white >> $1
#    awk -F, '{if ($15==1 && $11<$12) print $1,$2,$14,0.25}' $results | \
#		psxy $area $proj -O -K -SVt0/0/0 -W4,white >> $1

	# Custom symbol rotated to the crest orientation
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
                    print $1,$2,startRot,($5/500),xPos,yPos,-1*xPos,-1*yPos,endRot
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
#        sleep 1.2
    done < ${results%.*}_symbol.csv

	# Add a scale
	echo "1045000 2270000 90 0.75" | \
	psxy $area $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $1
	echo "1045000 2248000 0.5" | \
	psxy $area $proj -O -K -Sc -W4,white >> $1
	pstext $area $proj -O -K -D0.15/-0.15 -WwhiteO0,white << LABEL >> $1
	1077500 2270000 16 0 0 1 2 km wavelength
	1077500 2248000 16 0 0 1 50 m height
LABEL

    # Add the interp extents
    # Little
    cut -f2,3 -d, $interp_little | \
        psxy $area $proj -O -K -L -W10,black,- >> $1
    # Big
    cut -f2,3 -d, $interp_big | \
        psxy $area $proj -O -K -L -W10,black,4_8_5_8:0 >> $1

    # Add Zone A and Zone B to the two areas
    pstext $area $proj -O -K << ZONES >> $1
#    640000 2090000 14 0 0 1 Zone A
#    850000 2050000 14 0 0 1 Zone B
    537993 2059437 17 0 0 1 Zone A
    811523 1954597 17 0 0 1 Zone B
ZONES

	# Add in the histograms
	gmtset ANNOT_FONT_SIZE=12
	gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
	# Filter out all values below the nyquist frequency (60m)
	awk -F, '{if ($3>60 && $15==1) print $5}' $results | \
		pshistogram $harea $hproj -W2 -Ggray -L1 -O -K -Z1 \
	   	-Ba40f5:,"-m":/a5f1:,"-%":WesN -X15 -Y0.35 >> $1
	awk -F, '{if ($3>60 && $15==1 && $4<=90) print $4+90; else if ($3>60 && $15==1 && $4>90) print $4-90}' $results | \
		tr " " "\n" | \
		pshistogram $darea $hproj -W5 -Ggray -L1 -O -K -T0 -Z1 \
      	-Ba90f10:,"-@+o@+":/a10f2:,"-%":wEsN -X4.1 >> $1
    awk -F, '{if ($3>60 && $15==1) print $3}' $results | \
    	pshistogram $warea $hproj -W60 -Ggray -L1 -O -K -Z1 \
    	-Ba1500f500:,"-m":/a5f1:,"-%":wEsN -Y3.1 >> $1
    awk -F, '{if ($3>60 && $15==1) print $19}' $results | \
    	pshistogram $aarea $hproj -W0.1 -Ggray -L1 -O -Z1 \
    	-Ba1f0.2/a5f1:,"-%":WesN -X-4.1 >> $1
}

#prep

#plot_topo $outfile
#add_scale $outfile 1070000 2280000
#add_location $outfile
#plot_subset $outfile
#psxy -R -J -T -O >> $outfile
#formats $outfile
#mv $outfile ./images/ps
#mv ${outfile%.*}.png ./images/png/

plot_topo ${outfile%.*}_results.ps
add_scale ${outfile%.*}_results.ps 1070000 2300000
add_results ${outfile%.*}_results.ps
psxy -R -J -T -O >> $outfile
formats ${outfile%.*}_results.ps
mv ${outfile%.*}_results.png ./images/png/
mv ${outfile%.*}_results.ps ./images/ps
