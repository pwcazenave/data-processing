#!/bin/bash

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16 PAPER_MEDIA=a4

gres=1
ingrd=./grids/ws_${gres}m_blockmean.grd
outfile=./images/ws_${gres}m_bathy.ps

area=$(grdinfo -I1 $ingrd)
proj=-Jx0.001

outfile=./images/ws_location.ps

plot(){
	gmtset D_FORMAT=%g
#	makecpt $(grdinfo -T1 ./grids/$(basename ${ingrd%.*}.grd)) -Cgray > ./cpts/$(basename ${ingrd%.*}.cpt)
	makecpt -T0/60/0.1 -I > ./cpts/$(basename ${ingrd%.*}_colour.cpt)

	gmtset D_FORMAT=%.0f
	psbasemap $area $proj -Xc -Yc -K -B0 > $outfile
	grdimage $area $proj -Xc -Yc -K ${ingrd} \
		-C./cpts/$(basename ${ingrd%.*}_colour.cpt) -I${ingrd%.*}_grad.grd \
		-Ba4000f1000:"Eastings":/a2000f1000:"Northings":WeSn > $outfile

	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	# The Solent Banks location
	awk -F, '{print $2,$3}' $(pwd)/raw_data/solent_bank.csv | \
		psxy $area $proj -W5,black -L -O -K >> $outfile

	# Add some location markers and labels
	psxy $area $proj -O -K -Sc0.3 -Gwhite -W5,black << YAR >> $outfile
606109 5618009
602347 5623890
YAR
	pstext $area $proj -O -K -D0.4/-0.4 -WwhiteO0,white << LABEL >> $outfile
606009 5618039 14 0 0 1 Yarmouth
LABEL
	pstext $area $proj -O -K -D-2.5/0.15 -WwhiteO0,white << LABEL >> $outfile
602347 5623890 14 0 0 1 Lymington
LABEL
	pstext $area $proj -O -K -D-2.5/0.15 -WwhiteO0,white << LABEL >> $outfile
602180 5618308 14 0 0 1 Hurst Spit
LABEL
	pstext $area $proj -O -K -D-2.5/0 -WwhiteO0,white << LABEL >> $outfile
613636 5626760 14 0 0 1 Beaulieu River
LABEL
	pstext $area $proj -O -K -D0.55/-0.25 -WwhiteO0,white << LABEL >> $outfile
610460 5622250 14 0 0 1 Solent Banks
LABEL
	pstext $area $proj -O -K -D-1.9/0.15 -WwhiteO0,white << LABEL >> $outfile
609200 5615680 16 0 0 1 Isle of Wight
LABEL
	pstext $area $proj -O -K -WwhiteO0,white << LABEL >> $outfile
605000 5626430 16 0 0 1 England
LABEL

	# Add in the two subset areas too
	psxy $area $proj -W5 -O -K << BOX >> $outfile
613500 5624500
615900 5624500
615900 5623000
613500 5623000
613500 5624500
BOX
	psxy $area $proj -W5 -O -K << BOX >> $outfile
608000 5622000
610000 5622000
610000 5619400
608000 5619400
608000 5622000
BOX

	# Some text labels might help...
	pstext $area $proj -D0.15/0.15 -O -K -WwhiteO0,white << TEXT >> $outfile
613500 5623000 14 0 0 1 A
608000 5619400 14 0 0 1 B
TEXT

	gmtset ANNOT_FONT_SIZE=12 LABEL_FONT_SIZE=12 LABEL_OFFSET=0.15c
	psscale -D17/5/5/0.5h -B10:"Depth (m)": -C./cpts/$(basename ${ingrd%.*}_colour.cpt) -I -O -K >> $outfile

	# Add in a location map
	gmtset BASEMAP_TYPE=plain
	psbasemap -R-5/1/50/51.5 -Jm1.25 -B0 -O -K -X13.225 >> $outfile
	pscoast -R -J -Dh -Ggray -B0 -W -O -K >> $outfile
	pstext -R -J -O -K -D-2.5/-0.66 -WwhiteO0,white << HSB >> $outfile
-1.473573  50.730233 14 0 0 1 W. Solent
HSB
	psxy -R -J -O -Svs0.05/0.3/0.1 -Gblack -W2,white << POINT >> $outfile
-2.2 50.45 -1.473573 50.730233
POINT

	formats $outfile
}

plot
