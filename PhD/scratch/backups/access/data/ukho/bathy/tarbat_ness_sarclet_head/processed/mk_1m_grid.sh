#!/bin/bash

# Takes the raw input, and blockmeans it in quadrants to 1m resolution.
# Four grids are then generated, and then each grid is merged.

infile=../raw/tarbatNess-SarcletHead.xyz

sw=-R447800/494150/6409550/6440050
se=-R494050/540300/6409550/6440050
nw=-R447800/494150/6439950/6470400
ne=-R494050/540300/6439950/6470400

psw=-R447800/494050/6409550/6439975
pse=-R494050/540300/6409550/6439975
pnw=-R447800/494050/6439975/6470400
pne=-R494050/540300/6439975/6470400

gres=1

mkregular(){
	# We have to be on sarge
	if [ "$HOSTNAME" != "sarge" ]; then
		printf "Cannot run this on anything other than sarge.\n"
		exit 1
	else
		# There's 100m overlap between the regions.
		base=./raw_data/$(basename ${infile%.*})
		# SW
		blockmean $sw -I${gres} -Wo $infile > ${base}_${gres}m_sw.txt -V
		# SE
		blockmean $se -I${gres} -Wo $infile > ${base}_${gres}m_se.txt -V
		# NW
		blockmean $nw -I${gres} -Wo $infile > ${base}_${gres}m_nw.txt -V
		# NE
		blockmean $ne -I${gres} -Wo $infile > ${base}_${gres}m_ne.txt -V
	fi
}

mkgrids(){
	# Create four grids, but increase the dimension of the northern and
	# eastern quadrants to make them equally sized without overlap.
	base=./grids/$(basename ${infile%.*})
	processed=./raw_data/$(basename ${infile%.*})
	xyz2grd $psw -I${gres} -G${base}_${gres}m_sw.grd -V \
		${processed}_${gres}m_{sw,se,nw,ne}.txt
	xyz2grd $pse -I${gres} -G${base}_${gres}m_se.grd -V \
		${processed}_${gres}m_{sw,se,nw,ne}.txt
	xyz2grd $pnw -I${gres} -G${base}_${gres}m_nw.grd -V \
		${processed}_${gres}m_{sw,se,nw,ne}.txt
	xyz2grd $pne -I${gres} -G${base}_${gres}m_ne.grd -V \
		${processed}_${gres}m_{sw,se,nw,ne}.txt
}

mergegrids(){
	base=./grids/$(basename ${infile%.*})

	# South first
	grdpaste ${base}_${gres}m_sw.grd ${base}_${gres}m_se.grd \
		-G${base}_${gres}m_s.grd
	# Then north
	grdpaste ${base}_${gres}m_nw.grd ${base}_${gres}m_ne.grd \
		-G${base}_${gres}m_n.grd
	# Finally the two halves
	grdpaste ${base}_${gres}m_s.grd ${base}_${gres}m_n.grd \
		-G${base}_${gres}m.grd
}


#mkregular
#mkgrids
mergegrids
