#!/bin/bash

# script to plot the various extant wavelength/height relationships, as
# well as mine

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4

minw=1
maxw=10000
minh=1
maxh=10000

area=-R$minw/$maxw/$minh/$maxh
proj=-JX25l/15l
tproj=-JX25/15

resColX='sqrt($10^2)'
resColY='$3'
labelX="Depth/Altitude (m)"
labelY="Height (m)"

flemming=./raw_data/flemming_data.csv
flemming_africa=./raw_data/flemming_data_africa.csv
hsb=./raw_data/hsb_300m_subset_results_errors_asymm.csv
ws=./raw_data/ws_200m_subset_results_errors_asymm.csv
a4811=./raw_data/area481_500-1500m_subset_results_errors_asymm.csv
a4812=./raw_data/area481_200m_subset_results_errors_asymm.csv
srtm30=./raw_data/srtm_30000m_subset_results_errors_asymm.csv
jibs300=./raw_data/jibs_300m_subset_results_errors_asymm.csv
jibs2500=./raw_data/jibs_2500m_subset_results_errors_asymm.csv
thames=./raw_data/seazone_3000m_subset_results_errors_asymm.csv
southernnorthsea=./raw_data/seazone_1500-4000m_subset_results_errors_asymm.csv
culver2009=./raw_data/culver_sands_200m_subset_results_errors_asymm_2009.csv
simpsondesert=./raw_data/srtm_15000m_subset_results_errors_asymm.csv
taklamakandesert=./raw_data/srtm_35000m_subset_results_errors_asymm.csv
badainjaran=./raw_data/srtm_45000m_subset_results_errors_asymm.csv

mixout=./images/lambda_depth.ps

plotmix(){
	# Filters are based on Nyquist frequency, some directional filters
	# (e.g. Area 481) and some location filters (e.g. Area 481).
	# All of the data use the bedform discrimination for the plots.
	psbasemap $area $proj -X3.5 -Yc -K \
		-Ba1f3:"$labelX":/a1f3:"$labelY":WeSn > $mixout
	awk -F, '{if ($3>2 && $15==1) print '$resColX','$resColY',($8+$9)/2}' $jibs300 | \
		psxy $area $proj -Ey -Sh0.25 -O -K -W5,lightred >> $mixout
	awk -F, '{if ($3>2 && $15==1) print '$resColX','$resColY',($8+$9)/2}' $jibs2500 | \
		psxy $area $proj -Ey -Sh0.25 -O -K -W5,lightred >> $mixout
	awk -F, '{if ($3>2 && $15==1) print '$resColX','$resColY',($8+$9)/2}' $hsb | \
		psxy $area $proj -Ey -St0.25 -O -K -W5,darkblue >> $mixout
	awk -F, '{if ($3>2 && $4>55 && $4<65) print '$resColX','$resColY',($8+$9)/2}' $ws | \
		psxy $area $proj -Ey -Ss0.25 -O -K -W5,darkred >> $mixout
	awk -F, '{if ($3>4 && $4>0 && $4<30) print '$resColX','$resColY',($8+$9)/2}' $a4811 | \
		psxy $area $proj -Ey -Sd0.25 -O -K -W5,darkgreen >> $mixout
	awk -F, '{if ($3>4 && $2>=5907500 && $2<=5909300 && $1>=344500 && $1<=345800) print '$resColX','$resColY',($8+$9)/2}' $a4812 | \
		psxy $area $proj -Ey -Sd0.25 -O -K -W5,darkgreen >> $mixout
	awk -F, '{if ($3>180 && $15==1) print '$resColX','$resColY',5}' $taklamakandesert | \
		psxy $area $proj -Ey -Sg0.25 -O -K -W5,purple >> $mixout
	awk -F, '{if ($3>180 && $15==1) print '$resColX','$resColY',5}' $srtm30 | \
		psxy $area $proj -Ey -S+0.25 -O -K -W5,black >> $mixout
	awk -F, '{if ($3>40 && $15==1) print '$resColX','$resColY',($8+$9)/2}' $southernnorthsea | \
		psxy $area $proj -Ey -S-0.25 -O -K -W5,lightblue >> $mixout
	awk -F, '{if ($3>4 && $15==1) print '$resColX','$resColY',($8+$9)/2}' $culver2009 | \
		psxy $area $proj -Ey -S+0.25 -O -K -W5,darkyellow >> $mixout
	awk -F, '{if ($3>180 && $15==1) print '$resColX','$resColY',5}' $simpsondesert | \
		psxy $area $proj -Ey -Sx0.25 -O -K -W5,darkorange >> $mixout
	awk -F, '{if ($3>180 && $15==1) print '$resColX','$resColY',5}' $badainjaran | \
		psxy $area $proj -Ey -S+0.25 -O -K -W5,lightgreen >> $mixout
}

plotlabel(){
	# Usage: labelY labelColour labelSymbol labelString

	# Add some labels
	xpos1=8000 # text
	xpos2=7850 # symbol
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

plotmix
plotlabel 5000 darkblue t "Hastings" $mixout
plotlabel 4500 darkred s "West Solent" $mixout
plotlabel 4000 darkgreen d "Area 481" $mixout
plotlabel 3500 black + "Ar Rub' al Khali" $mixout
plotlabel 3000 lightblue - "Thames Estuary" $mixout
plotlabel 2500 lightred h "JIBS" $mixout
plotlabel 2000 darkyellow + "Culver Sands" $mixout
plotlabel 1500 darkorange x "Simpson Desert" $mixout
plotlabel 1000 purple g "Taklamakan Desert" $mixout
plotlabel 500 lightgreen + "Badain Jaran" $mixout
psxy $area $proj -T -O >> $mixout
formats $mixout
