#!/bin/bash

# script to plot the various extant marine wavelength/height relationships, as
# well as mine

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4

minw=0.01
maxw=10000
minh=0.001
maxh=1000
minwMine=1
maxwMine=$maxw

area=-R$minw/$maxw/$minh/$maxh
dwarea=-R1/300/1/$maxw
dharea=-R1/300/0.01/100
proj=-JX15l/7l
tproj=-JX15/25

# Extant
flemming=./raw_data/relationships/literature/flemming_data.csv
flemming_africa=./raw_data/relationships/literature/flemming_data_africa.csv
amosandking=./raw_data/relationships/literature/amos_and_king_1984_figure9.csv
dalrympleetal=./raw_data/relationships/literature/dalrymple_et_al_1978_figure3.csv
rubinandmcculloch=./raw_data/relationships/literature/rubin_and_mcculloch_1980_figure9.csv
franckenetal=./raw_data/relationships/literature/francken_et_al_2004_figure6.csv
vanlandeghem=./raw_data/relationships/literature/van_landeghem_et_al_2009.csv
# Marine
hsb=./raw_data/relationships/hsb_300m_subset_results_errors_asymm.csv
ws=./raw_data/relationships/ws_200m_subset_results_errors_asymm.csv
a4811=./raw_data/relationships/area481_500-1500m_subset_results_errors_asymm.csv
a4812=./raw_data/relationships/area481_200m_subset_results_errors_asymm.csv
jibs350=./raw_data/relationships/jibs_350m_subset_results_errors_asymm.csv
jibs2500=./raw_data/relationships/jibs_2500m_subset_results_errors_asymm.csv
thames=./raw_data/relationships/seazone_3000m_subset_results_errors_asymm.csv
southernnorthsea=./raw_data/relationships/seazone_1500-2500m_subset_results_errors_asymm.csv
culver2009=./raw_data/relationships/culver_sands_200m_subset_results_errors_asymm_2009.csv
culver2010=./raw_data/relationships/culver_sands_200m_subset_results_errors_asymm_2010.csv
britned=./raw_data/relationships/britned_50000-20000m_subset_results_errors_asymm.csv
# Aeolian
#srtm30=./raw_data/relationships/srtm_30000m_subset_results_errors_asymm.csv
#simpsondesert=./raw_data/relationships/srtm_15000m_subset_results_errors_asymm.csv
#taklamakandesert=./raw_data/relationships/srtm_40000m_subset_results_errors_asymm.csv
#badainjaran=./raw_data/relationships/srtm_45000m_subset_results_errors_asymm.csv

outfile=./images/predicted_marine_relationship.ps
mixout=./images/flemming.ps

# Some custom greys
gray1=50/50/50
gray2=100/100/100
gray3=150/150/150
gray4=200/200/200

mkrels(){
	printf "%f\n%f\n" $minw $maxw | \
    	awk '{print $1,0.074*$1^0.77,0.0635*$1^0.733,0.3345*$1^0.3822,0.0677*$1^0.8098,0.0321*$1^0.9179,0.0692*$1^0.8020,0.13*$1^0.61,0.0324*$1^0.539,0.0394*$1^0.7155,0.16*$1^0.84,0.06088*$1^0.6891,0.001001*$1^1.349}' \
	    > ./raw_data/relationships/predicted_relationships.txt
    # My relationships (marine, aeolian and global)
	printf "%f %f %f\n%f %f %f\n" $minw $minwMine $minwMine $maxw $maxwMine $maxwMine | \
    	awk '{print $1,0.06102*$1^0.6887,$2,0.001001*$2^1.349,$3,0.0015*$3^1.298}' \
	    > ./raw_data/relationships/my_relationships.txt
}

plotmix(){
	# Plot Flemming's data with mine overlaid. Filters are based on
	# Nyquist frequency, some directional filters (e.g. Area 481) and some
	# location filters (e.g. Area 481). All of the data use the bedform
	# discrimination for the plots.

	psbasemap $area $proj -X3.5c -Y22c -K -P \
		-Ba1f3:"Wavelength (m)":/a1f3:"Height (m)":WeSn > $outfile
	psxy $area $proj $flemming_africa -Sc0.1 -W5,5/5/5 -G5/5/5 -O -K >> $outfile
	psxy $area $proj $flemming -Sc0.1 -W5,5/5/5 -G5/5/5 -O -K >> $outfile
	psxy $area $proj $amosandking -Sc0.1 -: -W5,$gray1 -G$gray1 -O -K >> $outfile
	psxy $area $proj $dalrympleetal -Sc0.1 -W5,$gray2 -G$gray2 -O -K >> $outfile
	psxy $area $proj $franckenetal -Sc0.1 -W5,$gray3 -G$gray3 -O -K >> $outfile
	psxy $area $proj $rubinandmcculloch -Sc0.1 -W5,$gray4 -G$gray4 -O -K >> $outfile
	psxy $area $proj $vanlandeghem -Sx0.1 -W5,darkorange -O -K >> $outfile
	cut -d" " -f1,5 ./raw_data/relationships/predicted_relationships.txt | \
		psxy $area $proj -W15,gray -O -K >> $outfile
	cut -d" " -f1,11 ./raw_data/relationships/predicted_relationships.txt | \
		psxy $area $proj -W15,gray,- -O -K >> $outfile
	# Add my trends
	# Marine
	cut -d" " -f1,2 ./raw_data/relationships/my_relationships.txt | \
	    psxy $area $proj -W15,darkblue -O -K -N >> $outfile
	# Aeolian
#	cut -d" " -f3,4 ./raw_data/relationships/my_relationships.txt | \
#	    psxy $area $proj -W15,red -O -K -N >> $outfile
	# Global marine
#	cut -d" " -f5,6 ./raw_data/relationships/my_relationships.txt | \
#	    psxy $area $proj -W15,green -O -K -N >> $outfile

	awk -F, '{if ($3>2 && $15==1) print $3,$5,($8+$9)/2}' $jibs350 | \
		psxy $area $proj -Ex -St0.2 -O -K -W5,lightred >> $outfile
	awk -F, '{if ($3>2 && $15==1) print $3,$5,($8+$9)/2}' $jibs2500 | \
		psxy $area $proj -Ex -St0.2 -O -K -W5,lightred >> $outfile
	awk -F, '{if ($3>2 && $15==1) print $3,$5,($8+$9)/2}' $hsb | \
		psxy $area $proj -Ex -St0.2 -O -K -W5,darkblue >> $outfile
	awk -F, '{if ($3>2 && $4>55 && $4<65) print $3,$5,($8+$9)/2,0.06}' $ws | \
		psxy $area $proj -Exy -St0.2 -O -K -W5,darkred >> $outfile
	awk -F, '{if ($3>4 && $4>0 && $4<30) print $3,$5,($8+$9)/2}' $a4811 | \
		psxy $area $proj -Ex -St0.2 -O -K -W5,darkgreen >> $outfile
	awk -F, '{if ($3>4 && $2>=5907500 && $2<=5909300 && $1>=344500 && $1<=345800) print $3,$5,($8+$9)/2}' $a4812 | \
		psxy $area $proj -Ex -St0.2 -O -K -W5,darkgreen >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $taklamakandesert | \
#		psxy $area $proj -Exy -Sg0.2 -O -K -W5,purple >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $srtm30 | \
#		psxy $area $proj -Exy -S+0.2 -O -K -W5,black >> $outfile
#	awk -F, '{if ($3>40 && $15==1) print $3,$5,($8+$9)/2}' $thames | \
#		psxy $area $proj -Ex -S-0.2 -O -K -W5,100/180/255 >> $outfile
	awk -F, '{if ($3>40 && $15==1) print $3,$5,($8+$9)/2}' $southernnorthsea | \
		psxy $area $proj -Ex -St0.2 -O -K -W5,100/180/255 >> $outfile
	awk -F, '{if ($3>4 && $15==1) print $3,$5,($8+$9)/2}' $culver2009 | \
		psxy $area $proj -Ex -Sc0.2 -O -K -W5,darkyellow >> $outfile
#	awk -F, '{if ($3>4 && $15==1) print $3,$5,($8+$9)/2}' $culver2010 | \
#		psxy $area $proj -Ex -S+0.2 -O -K -W5,200/0/100 >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $simpsondesert | \
#		psxy $area $proj -Exy -Sx0.2 -O -K -W5,darkorange >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $badainjaran | \
#		psxy $area $proj -Exy -S+0.2 -O -K -W5,lightgreen >> $outfile
	awk -F, '{if ($3>400 && $15==1) print $3,$5,($8+$9)/2,5}' $britned | \
		psxy $area $proj -Exy -St0.2 -O -K -W5,100/0/200 -G100/0/200 >> $outfile

	# Add the Flemming label
	xpos1=300 # text
	xpos2=150 # symbol
	pstext $area $tproj -O -K -Ggray -D0/-0.15 << LABELS >> $outfile
$xpos1 950 15 0 1 1 Flemming (1988)
LABELS
	psxy $area $tproj -O -K -W10,gray << LINE >> $outfile
50 950
250 950
LINE
	psxy $area $tproj -O -K -Sc0.2 -W5,gray << LINE >> $outfile
$xpos2 950
LINE
}

plotdepthwavelength(){
    psbasemap $dwarea $proj -Y-9.75c -O -K \
        -Ba1f3:"Depth (m)":/a1f3:"Wavelength (m)":WeSn \
        >> $outfile
    awk -F, '{print sqrt($3^2),$1}' $vanlandeghem | \
    	psxy $dwarea $proj -Sx0.1 -W5,darkorange -O -K >> $outfile
	awk -F, '{if ($3>2 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $jibs350 | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,lightred >> $outfile
	awk -F, '{if ($3>2 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $jibs2500 | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,lightred >> $outfile
	awk -F, '{if ($3>2 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $hsb | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,darkblue >> $outfile
	awk -F, '{if ($3>2 && $4>55 && $4<65) print sqrt($10^2),$3,($8+$9)/2}' $ws | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,darkred >> $outfile
	awk -F, '{if ($3>4 && $4>0 && $4<30) print sqrt($10^2),$3,($8+$9)/2}' $a4811 | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,darkgreen >> $outfile
	awk -F, '{if ($3>4 && $2>=5907500 && $2<=5909300 && $1>=344500 && $1<=345800) print sqrt($10^2),$3,($8+$9)/2}' $a4812 | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,darkgreen >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $taklamakandesert | \
#		psxy $dwarea $proj -Ey -Sg0.2 -O -K -W5,purple >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $srtm30 | \
#		psxy $dwarea $proj -Ey -S+0.2 -O -K -W5,black >> $outfile
#	awk -F, '{if ($3>40 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $thames | \
#		psxy $dwarea $proj -Ey -S-0.2 -O -K -W5,100/180/255 >> $outfile
	awk -F, '{if ($3>40 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $southernnorthsea | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,100/180/255 >> $outfile
	awk -F, '{if ($3>4 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $culver2009 | \
		psxy $dwarea $proj -Ey -Sc0.2 -O -K -W5,darkyellow >> $outfile
#	awk -F, '{if ($3>4 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $culver2010 | \
#		psxy $dwarea $proj -Ey -S+0.2 -O -K -W5,200/0/100 >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $simpsondesert | \
#		psxy $dwarea $proj -Ey -Sx0.2 -O -K -W5,darkorange >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $badainjaran | \
#		psxy $dwarea $proj -Ey -S+0.2 -O -K -W5,lightgreen >> $outfile
	awk -F, '{if ($3>400 && $15==1) print sqrt($10^2),$3,($8+$9)/2}' $britned | \
		psxy $dwarea $proj -Ey -St0.2 -O -K -W5,100/0/200 -G100/0/200 >> $outfile
    # Add the water depth-wavelength upper limit from Francken et al. (2004)
    printf "%f\n%f\n" 1 300 | \
        awk '{print $1,9*$1}' | \
		psxy $dwarea $proj -O -K -W10,black >> $outfile
	# Add in mine
    printf "%f\n%f\n" 1 300 | \
        awk '{print $1,6*$1}' | \
		psxy $dwarea $proj -O -K -W10,darkblue,- >> $outfile
}

plotdepthheight(){
    psbasemap $dharea $proj -Y-9.75c -O -K \
        -Ba1f3:"Depth (m)":/a1f3:"Height (m)":WeSn \
        >> $outfile
    awk -F, '{print sqrt($3^2),$2}' $vanlandeghem | \
    	psxy $dharea $proj -Sx0.1 -W5,darkorange -O -K >> $outfile
	awk -F, '{if ($3>40 && $15==1) print sqrt($10^2),$5}' $southernnorthsea | \
		psxy $dharea $proj -St0.2 -O -K -W5,100/180/255 >> $outfile
	awk -F, '{if ($3>2 && $15==1) print sqrt($10^2),$5}' $jibs350 | \
		psxy $dharea $proj -St0.2 -O -K -W5,lightred >> $outfile
	awk -F, '{if ($3>2 && $15==1) print sqrt($10^2),$5}' $jibs2500 | \
		psxy $dharea $proj -St0.2 -O -K -W5,lightred >> $outfile
	awk -F, '{if ($3>2 && $15==1) print sqrt($10^2),$5}' $hsb | \
		psxy $dharea $proj -St0.2 -O -K -W5,darkblue >> $outfile
	awk -F, '{if ($3>2 && $4>55 && $4<65) print sqrt($10^2),$5,0.06}' $ws | \
		psxy $dharea $proj -Ey -St0.2 -O -K -W5,darkred >> $outfile
	awk -F, '{if ($3>4 && $4>0 && $4<30) print sqrt($10^2),$5}' $a4811 | \
		psxy $dharea $proj -St0.2 -O -K -W5,darkgreen >> $outfile
	awk -F, '{if ($3>4 && $2>=5907500 && $2<=5909300 && $1>=344500 && $1<=345800) print sqrt($10^2),$5}' $a4812 | \
		psxy $dharea $proj -St0.2 -O -K -W5,darkgreen >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$5,5}' $taklamakandesert | \
#		psxy $dharea $proj -Ey -Sg0.2 -O -K -W5,purple >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$5,5}' $srtm30 | \
#		psxy $dharea $proj -Ey -S+0.2 -O -K -W5,black >> $outfile
#	awk -F, '{if ($3>40 && $15==1) print sqrt($10^2),$5}' $thames | \
#		psxy $dharea $proj -S-0.2 -O -K -W5,100/180/255 >> $outfile
	awk -F, '{if ($3>4 && $15==1) print sqrt($10^2),$5}' $culver2009 | \
		psxy $dharea $proj -Sc0.2 -O -K -W5,darkyellow >> $outfile
#	awk -F, '{if ($3>4 && $15==1) print sqrt($10^2),$5}' $culver2010 | \
#		psxy $dharea $proj -S+0.2 -O -K -W5,200/0/100 >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$5,5}' $simpsondesert | \
#		psxy $dharea $proj -Ey -Sx0.2 -O -K -W5,darkorange >> $outfile
#	awk -F, '{if ($3>180 && $15==1) print sqrt($10^2),$5,5}' $badainjaran | \
#		psxy $dharea $proj -Ey -S+0.2 -O -K -W5,lightgreen >> $outfile
	awk -F, '{if ($3>400 && $15==1) print sqrt($10^2),$5}' $britned | \
		psxy $dharea $proj -St0.2 -O -K -W5,100/0/200 -G100/0/200 >> $outfile
    # Add the water depth-height upper limit from Francken et al. (2004)
    printf "%f\n%f\n" 1 300 | \
        awk '{print $1,0.25*$1}' | \
		psxy $dharea $proj -O -K -W10,black >> $outfile
	# Add in mine
    printf "%f\n%f\n" 1 300 | \
        awk '{print $1,0.1*$1}' | \
		psxy $dharea $proj -O -K -W10,darkblue,- >> $outfile
}

plotlabel(){
	# Usage: labelY labelColour labelSymbol labelString

	# Add some labels
	xpos1=300 # text
	xpos2=150 # symbol
	ypos1=$1  # label height
	labelColour=$2
	labelSymbol=$3
	labelString=$4
	out=$5

	pstext $area $tproj -O -K -D0/-0.1 -G"${labelColour}" << LABELS >> $out
$xpos1 $ypos1 10 0 0 1 ${labelString}
LABELS
	psxy $area $tproj -O -K -S"${labelSymbol}"0.15 -W5,"${labelColour}" $6 << LINE >> $out
$xpos2 $ypos1
LINE
}

mkrels
plotmix
plotlabel 270 5/5/5 c "Flemming (1988)" $outfile -G5/5/5
plotlabel 255 $gray1 c "Amos and King (1984)" $outfile "-G$gray1"
plotlabel 240 $gray2 c "Dalrymple et al. (1978)" $outfile "-G$gray2"
plotlabel 225 $gray3 c "Francken et al. (2004)" $outfile "-G$gray3"
plotlabel 210 $gray4 c "Rubin and McCulloch (1980)" $outfile "-G$gray4"
plotlabel 195 darkorange x "Van Landeghem et al. (2009)" $outfile
plotlabel 180 darkblue t "Hastings" $outfile
plotlabel 165 darkred t "West Solent" $outfile
plotlabel 150 darkgreen t "Area 481" $outfile
#plotlabel 750 black + "Ar Rub' al Khali" $outfile
plotlabel 135 100/180/255 t "Thames Estuary" $outfile
plotlabel 120 lightred t "JIBS" $outfile
plotlabel 105 darkyellow c "Culver Sands" $outfile
#plotlabel 550 200/0/100 + "Culver Sands 2010" $outfile
#plotlabel 550 darkorange x "Simpson Desert" $outfile
#plotlabel 500 purple g "Taklamakan Desert" $outfile
#plotlabel 450 lightgreen + "Badain Jaran" $outfile
plotlabel 90 100/0/200 t "BritNed" $outfile -G100/0/200

plotdepthwavelength
plotlabel 270 black - "Francken et al. (2004)" $outfile
plotlabel 255 darkorange x "Van Landeghem et al. (2009)" $outfile
plotlabel 240 darkblue t "Hastings" $outfile
plotlabel 225 darkred t "West Solent" $outfile
plotlabel 210 darkgreen t "Area 481" $outfile
#plotlabel 750 black + "Ar Rub' al Khali" $outfile
plotlabel 195 100/180/255 t "Thames Estuary" $outfile
plotlabel 180 lightred t "JIBS" $outfile
plotlabel 165 darkyellow c "Culver Sands" $outfile
#plotlabel 550 200/0/100 + "Culver Sands 2010" $outfile
#plotlabel 550 darkorange x "Simpson Desert" $outfile
#plotlabel 500 purple g "Taklamakan Desert" $outfile
#plotlabel 450 lightgreen + "Badain Jaran" $outfile
plotlabel 150 100/0/200 t "BritNed" $outfile -G100/0/200

plotdepthheight
plotlabel 270 black - "Francken et al. (2004)" $outfile
plotlabel 255 darkorange x "Van Landeghem et al. (2009)" $outfile
plotlabel 240 darkblue t "Hastings" $outfile
plotlabel 225 darkred t "West Solent" $outfile
plotlabel 210 darkgreen t "Area 481" $outfile
#plotlabel 750 black + "Ar Rub' al Khali" $outfile
plotlabel 195 100/180/255 t "Thames Estuary" $outfile
plotlabel 180 lightred t "JIBS" $outfile
plotlabel 165 darkyellow c "Culver Sands" $outfile
#plotlabel 550 200/0/100 + "Culver Sands 2010" $outfile
#plotlabel 550 darkorange x "Simpson Desert" $outfile
#plotlabel 500 purple g "Taklamakan Desert" $outfile
#plotlabel 450 lightgreen + "Badain Jaran" $outfile
plotlabel 150 100/0/200 t "BritNed" $outfile -G100/0/200

psxy $area $proj -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
