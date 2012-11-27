#!/bin/bash

# Script to plot the ASTER GDEM data. May have results at some point too...

gmtdefaults -D > .gmtdefaults4
gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18 BASEMAP_TYPE=plain

ingrd=./grids/aster_gdem_utm_90m.grd

area=$(grdinfo -I100 $ingrd)
proj=-Jx3.2e-5

overallarea=-R30/70/10/40
overallproj=-Jm0.17

hproj=-JX3.2/2

harea=-R0/120/0/15
warea=-R1000/3500/0/15
darea=-R0/180/0/15

outfile=./images/$(basename ${ingrd%.*}).ps
results=./raw_data/aster_gdem_30000m_subset_results_errors_asymm.csv

prep(){
	grdgradient -Nt0.7 -A160 $ingrd -G${ingrd%.*}_grad.grd
}

plot_topo(){
	#makecpt $(grdinfo -T10 $ingrd) -Z -Cgray > ./cpts/$(basename ${ingrd%.*}).cpt
	makecpt -T200/1200/10 -Z -Cgray > ./cpts/$(basename ${ingrd%.*}).cpt
	#grd2cpt $ingrd -Cgray -Z > ./cpts/$(basename ${ingrd%.*}).cpt
	psbasemap $area $proj -X4 -K -Ba100000f20000:"Eastings":/a100000f20000:"Northings":WeSn \
		> $1
	grdimage $area $proj -C./cpts/$(basename ${ingrd%.*}).cpt -I${ingrd%.*}_grad.grd \
		$ingrd -O -K >> $1
	psscale -D10/2.6/5.5/0.4h -Ba400f100:"Height (m)": \
		-C./cpts/$(basename ${ingrd%.*}).cpt -I -O -K >> $1
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
	pstext $overallarea $overallproj -O << LABELS >> $1
34 14 10 80 0 1 Africa
50 33 10 0 0 1 Eurasia
40 26 10 0 0 1 Arabian
41 23.5 10 0 0 1 Peninsula
56 13 10 0 0 1 Arabian Sea
LABELS
	gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18 BASEMAP_TYPE=plain
}

add_results(){
	# Height (as a scaled circle)
	awk -F, '{if ($15==1) print $1,$2,$5*0.01}' $results | \
		psxy $area $proj -O -K -Sc -W4,white >> $1
	# Wavelength/orientation
	awk -F, '{if ($15==1) print $1,$2,$4+90,$3*0.0005}' $results | \
		psxy $area $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $1
	# Add a scale
	echo "1045000 2280000 90 0.75" | \
	psxy $area $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $1
	echo "1045000 2258000 0.5" | \
	psxy $area $proj -O -K -Sc -W4,white >> $1
	pstext $area $proj -O -K -D0.15/-0.15 -WwhiteO0,white << LABEL >> $1
	1077500 2280000 16 0 0 1 2 km wavelength
	1077500 2258000 16 0 0 1 50 m height
LABEL
	# Add in the histograms
	gmtset ANNOT_FONT_SIZE=12
	gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
	# Filter out all values below the nyquist frequency (60m)
	awk -F, '{if ($3>60) print $5}' $results | \
		pshistogram $harea $hproj -W2 -Ggray -L1 -O -K -Z1 \
	   	-Ba40f5:,"-m":/a5f1:,"-%":WesN -X14.75 -Y0.35 >> $1
	awk -F, '{if ($3>60 && $4<=90) print $4+90,$4+$8+90,$4-$9+90; else print $4-90,$4+$8-90,$4-$9-90}' $results | \
		tr " " "\n" | \
		pshistogram $darea $hproj -W5 -Ggray -L1 -O -K -T0 -Z1 \
      	-Ba90f10:,"-@+o@+":/a5f1:,"-%":wEsN -X4.2 >> $1
    awk -F, '{if ($3>60) print $3}' $results | \
    	pshistogram $warea $hproj -W60 -Ggray -L1 -O -Z1 \
    	-Ba1500f500:,"-m":/a5f1:,"-%":wEsN -Y3.1 >> $1
}

#prep

plot_topo $outfile
add_location $outfile
formats $outfile

plot_topo ${outfile%.*}_results.ps
add_results ${outfile%.*}_results.ps
formats ${outfile%.*}_results.ps

