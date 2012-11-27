#!/bin/bash

# Script to plot the discrepancies between the observations and prections 
# for the heights.

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset D_FORMAT=%g PAPER_MEDIA=a4

area=-R0.01/100/0/15
proj=-JX15l/7
tproj=-JX15/25

# Marine
#hsb=./raw_data/relationships/hsb_300m_subset_results_errors_asymm.csv
#ws=./raw_data/relationships/ws_200m_subset_results_errors_asymm.csv
#a4811=./raw_data/relationships/area481_500-1500m_subset_results_errors_asymm.csv
#a4812=./raw_data/relationships/area481_200m_subset_results_errors_asymm.csv
#jibs350=./raw_data/relationships/jibs_350m_subset_results_errors_asymm.csv
#jibs2500=./raw_data/relationships/jibs_2500m_subset_results_errors_asymm.csv
#thames=./raw_data/relationships/seazone_3000m_subset_results_errors_asymm.csv
#southernnorthsea=./raw_data/relationships/seazone_1500-4000m_subset_results_errors_asymm.csv
#culver2009=./raw_data/relationships/culver_sands_200m_subset_results_errors_asymm_2009.csv
#culver2010=./raw_data/relationships/culver_sands_200m_subset_results_errors_asymm_2010.csv
#britned=./raw_data/relationships/britned_50000-20000m_subset_results_errors_asymm.csv
# Aeolian
srtm30=./raw_data/relationships/srtm_30000m_subset_results_errors_asymm.csv
simpsondesert=./raw_data/relationships/srtm_15000m_subset_results_errors_asymm.csv
taklamakandesert=./raw_data/relationships/srtm_40000m_subset_results_errors_asymm.csv
badainjaran=./raw_data/relationships/srtm_45000m_subset_results_errors_asymm.csv

outfile=./images/aeolian_bedform_discrepancies.ps

# Some custom greys
gray1=50/50/50
gray2=100/100/100
gray3=150/150/150
gray4=200/200/200

plotmix(){
	psbasemap $area $proj -X3 -Y22c -K -P \
		-Ba1f3:"Height@-obs@-/Height@-pred@-":/a2f0.5:"Height (m)":WeSn > $outfile
	# Aeolian
    mean=$(awk -F, '{sum+=$5}END{print sum/NR}' $taklamakandesert)
    awk -F, '{if ($3>2 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' \
	    $taklamakandesert | \
		psxy $area $proj -Sd0.2 -O -K -W5,purple >> $outfile
    mean=$(awk -F, '{sum+=$5}END{print sum/NR}' $simpsondesert)
    awk -F, '{if ($3>2 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' \
        $simpsondesert | \
		psxy $area $proj -Sd0.2 -O -K -W5,green -Ggreen >> $outfile
    mean=$(awk -F, '{sum+=$5}END{print sum/NR}' $badainjaran)
    awk -F, '{if ($3>40 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' \
        $badainjaran | \
		psxy $area $proj -Sd0.2 -O -K -W5,red >> $outfile
    mean=$(awk -F, '{sum+=$5}END{print sum/NR}' $srtm30)
    awk -F, '{if ($3>2 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' \
        $srtm30 | \
		psxy $area $proj -Sd0.2 -O -K -W5,blue -Gblue>> $outfile
	# Add the 50%, 75%, 150% and 200% lines.
	psxy $area $proj -W10,$gray3,.- -O -K -m << LINES >> $outfile
0.5 0
0.5 15
>
2 0
2 15
LINES
    pstext $area $proj -O -K -G$gray3 <<TEXT >> $outfile
    0.47 14 12 0 0 RM 50%
    2.1 14 12 0 0 LM 200%
TEXT
}

plotlabel(){
	# Usage: labelY labelColour labelSymbol labelString

	# Add some labels
	xpos1=0.0175 # text
	xpos2=0.015 # symbol
	ypos1=$1  # label height
	labelColour=$2
	labelSymbol=$3
	labelString=$4
	out=$5

	pstext $area $proj -O -K -D0/-0.15 -G"${labelColour}" << LABELS >> $out
$xpos1 $ypos1 10 0 0 1 ${labelString}
LABELS
	psxy $area $proj -O -K -S"${labelSymbol}"0.15 -W5,"${labelColour}" $6 << LINE >> $out
$xpos2 $ypos1
LINE
}

plotmix
#plotlabel 14 darkblue t "Hastings" $outfile
#plotlabel 13 darkred s "West Solent" $outfile
#plotlabel 12 darkgreen d "Area 481" $outfile
plotlabel 14 blue d "Ar Rub' al Khali" $outfile -Gblue
#plotlabel 11 lightblue - "Thames Estuary" $outfile
#plotlabel 10 lightred h "JIBS" $outfile
#plotlabel 9 darkyellow + "Culver Sands" $outfile
#plotlabel 550 200/0/100 + "Culver Sands 2010" $outfile
plotlabel 13 green d "Simpson Desert" $outfile -Ggreen
plotlabel 12 purple h "Taklamakan Desert" $outfile
plotlabel 11 red d "Badain Jaran" $outfile
#plotlabel 8 100/0/200 + "BritNed" $outfile

psxy $area $proj -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
