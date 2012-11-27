#!/bin/bash

# Script to take the output of the threshold analysis from MATLAB
# and plot it against one of the data sets used in the analysis. I
# think I'm going to have to use the West Solent data, even though it
# would probably be better to use the Hastings data...

inData=$HOME/matlab/bedforms/data/threshold_data/threshold_analysis.csv
inXY=$HOME/matlab/bedforms/data/threshold_data/picked_lines.csv
inPicks=$HOME/matlab/bedforms/data/threshold_data/picked_values.csv
inThreshold=$HOME/matlab/bedforms/data/threshold_data/predicted_threshold.csv
inBathy=./grids/mca_bathy.grd
inCpt=./cpts/mca_bathy_colour.cpt

outfile=./images/threshold_analyses.ps

#areaPhi=$(awk -F, '{printf "%.2f %.2f\n%.2f %.2f\n%.2f %.2f\n", $1,$2,$1,$2-$3,$1,$2+$3}' $inData | minmax -I10/5)
areaPhi=$(awk -F, '{print $1,$3}' $inPicks | minmax -I10/5)
#areaLambda=$(awk -F, '{printf "%.2f %.2f\n%.2f %.2f\n%.2f %.2f\n", $1,$4,$1,$4-$5,$1,$4+$5}' $inData | minmax -I10/5)
areaLambda=$(awk -F, '{print $1,$2}' $inPicks | minmax -I10/5)
areaN=$(cut -f1,6 -d, $inData | minmax -I1/0.5)
#areaN=-R1/100/0.0001/3.5 # for log y-axis
areaN=-R1/100/0.01/100 # for log y-axis with normalisation to number of samples
areaNgrad=$(cut -f1,8 -d, $inData | minmax -I10/7.5)
areaNgrad=-R0/100/0.01/210 # for log y-axis
areaBathy=$(grdinfo $inBathy -I1)

projGraph=-JX11c/8c
projLogGraph=-JX11c/8cl
projLogGraphNeg=-JX11c/-8cl
projMap=-Jx0.019

xPosInc=14c
yPosInc=9c

gmtset ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=16

makecpt -T13/16/0.2 -I -Z > $inCpt

# Orientation
psbasemap $areaPhi $projGraph -X3c -Y11c \
-Ba20f5:,-"%"::"Threshold":/a45f15:"Orientation"::,-"@+o@+":WesN \
    -K > $outfile
cut -f1,3 -d, $inPicks | \
    psxy $areaPhi $projGraph -Sc0.075 -W0.5,100/100/100 -G100/100/100 -O -K >> $outfile
cut -f1-3 -d, $inData | \
    psxy $areaPhi $projGraph -O -K -W5 >> $outfile
#    psxy $areaPhi $projGraph -Ey0.25c/5 -O -K -W5 >> $outfile
cut -f1-3 -d, $inData | \
    psxy $areaPhi $projGraph -O -K -W5 >> $outfile
cut -f1-3 -d, $inData | \
    psxy $areaPhi $projGraph -O -K -W5 -Gblack -Sc0.1 >> $outfile
# Add predicted threshold line
psxy $areaPhi $projGraph -O -K -W5t30_10:0 $inThreshold >> $outfile

# Wavelength
psbasemap $areaLambda $projGraph -X${xPosInc} \
-Ba20f5:,-"%"::"Threshold":/a10f2:"Wavelength"::,-"m":WesN \
    -O -K >> $outfile
cut -f1,2 -d, $inPicks | \
    psxy $areaLambda $projGraph -Sc0.075 -W0.5,100/100/100 -G100/100/100 -O -K >> $outfile
cut -f1,4,5 -d, $inData | \
    psxy $areaLambda $projGraph -O -K -W5 >> $outfile
    #psxy $areaLambda $projGraph -Ey0.25c/5 -O -K -W5 >> $outfile
cut -f1,4,5 -d, $inData | \
    psxy $areaLambda $projGraph -O -K -W5 >> $outfile
cut -f1,4,5 -d, $inData | \
    psxy $areaLambda $projGraph -O -K -W5 -Gblack -Sc0.1 >> $outfile
# Add predicted threshold line
cut -f3,4 -d, $inThreshold | \
    psxy $areaLambda $projGraph -O -K -W5t30_10:0 >> $outfile

# n
psbasemap $areaN $projLogGraph -X-${xPosInc} -Y-${yPosInc} \
-Ba20f5:,-"%"::"Threshold":/a1:,-"%"::"Samples":WSn \
    -O -K >> $outfile
maxN=$(cut -f6 -d, $inData | minmax -C | awk '{print $2}')
awk -F, '{print $1,($6/'$maxN')*100}' $inData | \
    psxy $areaN $projLogGraph -O -K -W5,100/100/100 >> $outfile
awk -F, '{print $1,($6/'$maxN')*100}' $inData | \
    psxy $areaN $projLogGraph -O -K -W5,100/100/100 -Sx0.25 >> $outfile
# n^{-1}
psbasemap $areaNgrad $projLogGraphNeg \
    -Ba20f5:,-"%"::"Threshold":/a1:=-"-"::"Sampling rate (%@+-1@+)":E \
    -O -K >> $outfile
awk -F, '{print $1,$8*-1}' $inData | \
    psxy $areaNgrad $projLogGraphNeg -O -K -W5 >> $outfile
awk -F, '{print $1,$8*-1}' $inData | \
    psxy $areaNgrad $projLogGraphNeg -O -K -W5 -Sc0.2 >> $outfile

# Bathy plot with orientation lines
grdimage $areaBathy $projMap $inBathy -C$inCpt -X17c \
    -I${inBathy%.*}_grad.grd \
    -Ba200f50:"Eastings":/a100f25:"Northings":WeSn \
    -O -K >> $outfile
# Overlay the lines (with grayscale colour palette)
colourIncBase=$(echo "scale=2; 255/$(wc -l < $inData)" | bc -l)
incXY=1
for i in $(seq 1 $(awk -F, '{if (NR==1) print NF/2}' $inXY)); do
    if [ $i -eq 1 ]; then
        colourInc=$colourIncBase
    else
        # Force zero decimal points (GMT bug?)
        colourInc=$(printf "%.0f" $(echo "$colourIncBase+$colourInc" | bc -l))
    fi
    colour=$colourInc/$colourInc/$colourInc
    cut -f$incXY-$(($incXY+1)) -d, $inXY | \
        psxy $areaBathy $projMap -O -K -W5,$colour >> $outfile
    incXY=$(($incXY+1))
done
# Add scales
psscale -D7.2/6/-3/0.4 -Ba1f0.25:"Depth (m)": -I -C$inCpt -O -K >> $outfile
makecpt -T0/100/1 -Cgray -Z > ./cpts/thresholds.cpt
psscale -D7/2/3/0.4 -Ba25f5:,-"%"::"Threshold": -C./cpts/thresholds.cpt -O -K >> $outfile

# Close the image
psxy -R -J -T -O >> $outfile

formats $outfile
mv ${outfile%.*}.png ./images/png/
mv ${outfile} ./images/ps/
