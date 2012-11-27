#!/bin/bash

# script to plot the various extant wavelength/height relationships, as
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
proj=-JX25l/15l
tproj=-JX25/15

flemming=./raw_data/flemming_data.csv
flemming_africa=./raw_data/flemming_data_africa.csv
hsb=./raw_data/hsb_300m_subset_results_errors_asymm.csv
ws=./raw_data/ws_200m_subset_results_errors_asymm.csv
a4811=./raw_data/area481_500-1500m_subset_results_errors_asymm.csv
a4812=./raw_data/area481_200m_subset_results_errors_asymm.csv
srtm30=./raw_data/srtm_30000m_subset_results_errors_asymm.csv
jibs350=./raw_data/jibs_350m_subset_results_errors_asymm.csv
jibs2500=./raw_data/jibs_2500m_subset_results_errors_asymm.csv
thames=./raw_data/seazone_3000m_subset_results_errors_asymm.csv
southernnorthsea=./raw_data/seazone_1500-4000m_subset_results_errors_asymm.csv
culver2009=./raw_data/culver_sands_200m_subset_results_errors_asymm_2009.csv
culver2010=./raw_data/culver_sands_200m_subset_results_errors_asymm_2010.csv
simpsondesert=./raw_data/srtm_15000m_subset_results_errors_asymm.csv
taklamakandesert=./raw_data/srtm_40000m_subset_results_errors_asymm.csv
badainjaran=./raw_data/srtm_45000m_subset_results_errors_asymm.csv
britned=./raw_data/britned_50000-20000m_subset_results_errors_asymm.csv

outfile=./images/predicted_relationship.ps
mixout=./images/flemming.ps

mkrels(){
	printf "%f\n%f\n" $minw $maxw | \
    	awk '{print $1,0.074*$1^0.77,0.0635*$1^0.733,0.3345*$1^0.3822,0.0677*$1^0.8098,0.0321*$1^0.9179,0.0692*$1^0.8020,0.13*$1^0.61,0.0324*$1^0.539,0.0394*$1^0.7155,0.16*$1^0.84,0.06088*$1^0.6891,0.001001*$1^1.349}' \
	    > ./raw_data/predicted_relationships.txt
    # My relationships (marine, aeolian and global)
	printf "%f %f %f\n%f %f %f\n" $minw $minwMine $minwMine $maxw $maxwMine $maxwMine | \
    	awk '{print $1,0.06088*$1^0.6891,$2,0.001001*$2^1.349,$3,0.0015*$3^1.298}' \
	    > ./raw_data/my_relationships.txt
}

plotmix(){
	# Plot Flemming's data with mine overlaid. Filters are based on
	# Nyquist frequency, some directional filters (e.g. Area 481) and some
	# location filters (e.g. Area 481). All of the data use the bedform
	# discrimination for the plots.
	psbasemap $area $proj -X3 -Yc -K \
		-Ba1f3:"Wavelength (m)":/a1f3:"Height (m)":WeSn > $mixout
	psxy $area $proj $flemming_africa -Sc0.1 -W5,gray -Ggray -O -K >> $mixout
	psxy $area $proj $flemming -Sc0.1 -W5,gray -Ggray -O -K >> $mixout
	cut -d" " -f1,5 ./raw_data/predicted_relationships.txt | \
		psxy $area $proj -W15,gray -O -K >> $mixout
	cut -d" " -f1,11 ./raw_data/predicted_relationships.txt | \
		psxy $area $proj -W15,gray,- -O -K >> $mixout
	# Add my trends
	# Marine
	cut -d" " -f1,2 ./raw_data/my_relationships.txt | \
	    psxy $area $proj -W15,black -O -K -N >> $mixout
	# Aeolian
	cut -d" " -f3,4 ./raw_data/my_relationships.txt | \
	    psxy $area $proj -W15,red -O -K -N >> $mixout
	# Global
	cut -d" " -f5,6 ./raw_data/my_relationships.txt | \
	    psxy $area $proj -W15,green -O -K -N >> $mixout
	awk -F, '{if ($3>2 && $15==1) print $3,$5,($8+$9)/2}' $jibs350 | \
		psxy $area $proj -Ex -Sh0.25 -O -K -W5,lightred >> $mixout
	awk -F, '{if ($3>2 && $15==1) print $3,$5,($8+$9)/2}' $jibs2500 | \
		psxy $area $proj -Ex -Sh0.25 -O -K -W5,lightred >> $mixout
	awk -F, '{if ($3>2 && $15==1) print $3,$5,($8+$9)/2}' $hsb | \
		psxy $area $proj -Ex -St0.25 -O -K -W5,darkblue >> $mixout
	awk -F, '{if ($3>2 && $4>55 && $4<65) print $3,$5,($8+$9)/2,0.06}' $ws | \
		psxy $area $proj -Exy -Ss0.25 -O -K -W5,darkred >> $mixout
	awk -F, '{if ($3>4 && $4>0 && $4<30) print $3,$5,($8+$9)/2}' $a4811 | \
		psxy $area $proj -Ex -Sd0.25 -O -K -W5,darkgreen >> $mixout
	awk -F, '{if ($3>4 && $2>=5907500 && $2<=5909300 && $1>=344500 && $1<=345800) print $3,$5,($8+$9)/2}' $a4812 | \
		psxy $area $proj -Ex -Sd0.25 -O -K -W5,darkgreen >> $mixout
	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $taklamakandesert | \
		psxy $area $proj -Exy -Sg0.25 -O -K -W5,purple >> $mixout
	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $srtm30 | \
		psxy $area $proj -Exy -S+0.25 -O -K -W5,black >> $mixout
#	awk -F, '{if ($3>40 && $15==1) print $3,$5,($8+$9)/2}' $thames | \
#		psxy $area $proj -Ex -S-0.25 -O -K -W5,lightblue >> $mixout
	awk -F, '{if ($3>40 && $15==1) print $3,$5,($8+$9)/2}' $southernnorthsea | \
		psxy $area $proj -Ex -S-0.25 -O -K -W5,lightblue >> $mixout
	awk -F, '{if ($3>4 && $15==1) print $3,$5,($8+$9)/2}' $culver2009 | \
		psxy $area $proj -Ex -S+0.25 -O -K -W5,darkyellow >> $mixout
#	awk -F, '{if ($3>4 && $15==1) print $3,$5,($8+$9)/2}' $culver2010 | \
#		psxy $area $proj -Ex -S+0.25 -O -K -W5,200/0/100 >> $mixout
	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $simpsondesert | \
		psxy $area $proj -Exy -Sx0.25 -O -K -W5,darkorange >> $mixout
	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $badainjaran | \
		psxy $area $proj -Exy -S+0.25 -O -K -W5,lightgreen >> $mixout
	awk -F, '{if ($3>180 && $15==1) print $3,$5,($8+$9)/2,5}' $britned | \
		psxy $area $proj -Exy -S+0.25 -O -K -W5,100/0/200 >> $mixout

	# Add the Flemming label
	xpos1=300 # text
	xpos2=150 # symbol
	pstext $area $tproj -O -K -Ggray -D0/-0.15 << LABELS >> $mixout
$xpos1 950 15 0 1 1 Flemming (1988)
LABELS
	psxy $area $tproj -O -K -W10,gray << LINE >> $mixout
50 950
250 950
LINE
	psxy $area $tproj -O -K -Sc0.25 -W5,gray << LINE >> $mixout
$xpos2 950
LINE
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

	pstext $area $tproj -O -K -D0/-0.15 -G"${labelColour}" << LABELS >> $out
$xpos1 $ypos1 15 0 1 1 ${labelString}
LABELS
	psxy $area $tproj -O -K -S"${labelSymbol}"0.25 -W5,"${labelColour}" << LINE >> $out
$xpos2 $ypos1
LINE

}

mkrels
plotmix
plotlabel 900 darkblue t "Hastings" $mixout
plotlabel 850 darkred s "West Solent" $mixout
plotlabel 800 darkgreen d "Area 481" $mixout
plotlabel 750 black + "Ar Rub' al Khali" $mixout
plotlabel 700 lightblue - "Thames Estuary" $mixout
plotlabel 650 lightred h "JIBS" $mixout
plotlabel 600 darkyellow + "Culver Sands" $mixout
#plotlabel 550 200/0/100 + "Culver Sands 2010" $mixout
plotlabel 550 darkorange x "Simpson Desert" $mixout
plotlabel 500 purple g "Taklamakan Desert" $mixout
plotlabel 450 lightgreen + "Badain Jaran" $mixout
plotlabel 400 100/0/200 + "BritNed" $mixout
psxy $area $proj -T -O >> $mixout
formats $mixout
