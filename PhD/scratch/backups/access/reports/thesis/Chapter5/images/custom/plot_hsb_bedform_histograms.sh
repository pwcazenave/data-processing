#!/bin/bash

# Script to plot the results of the bedform analysis at Culver as
# three histograms to be superimposed on the ArcGIS vector image.
# Also do a rose diagram.

infile=./raw_data/hsb_300m_subset_results_errors_asymm.csv
outfile=./images/hsb_bedform_histograms.ps

harea=-R0/1/0/10
warea=-R0/30/0/20
darea=-R0/180/0/10
sarea=-R1/2/0/20
hproj=-JX4/3

# The histograms
gmtset ANNOT_FONT_SIZE=12
gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
# Filter out all values below the nyquist frequency (60m)
awk -F, '{if ($3>2 && $15==1) print $5}' $infile | \
    pshistogram $harea $hproj -W0.01 -Ggray -L1 -K -Z1 \
    -Ba0.5f0.1:,"-m":/a5f1:,"-%":WeSn -X1.3c -Y1c > $outfile
awk -F, '{
        if ($3>2 && $15==1 && $4<=90)
            printf "%lg\n%lg\n%lg\n", $4+90,$4+90+$8,$4+90;
        else if ($3>4 && $15==1 && $4>90)
            printf "%lg\n%lg\n%lg\n", $4-90,$4-90+$8,$4-90-$9
        }' $infile | \
    pshistogram $darea $hproj -W5 -Ggray -L1 -O -K -T0 -Z1 \
    -Ba90f10:,"-@+o@+":/a5f1:,"-%":WeSn -X5.5c >> $outfile
awk -F, '{if ($3>2 && $15==1) print $3}' $infile | \
    pshistogram $warea $hproj -W1 -Ggray -L1 -O -K -Z1 \
    -Ba10f2:,"-m":/a10f2:,"-%":WeSn -X5.5c >> $outfile

# The rose
tempfile=$(mktemp)
awk -F, '{!/NaN/
            if ($3>2 && $4>0 && $15==1 && $14>=0 && $14+$6>0 && $14-$7>0 )
                printf "%lg\n%lg\n%lg\n", $14,$14+$6,$14-$7;
        }' $infile | \
    pshistogram $aarea $hproj -W1 -T0 -Z1 -IO 2> /dev/null | \
    awk '{print $2,$1}' > $tempfile
psrose -R0/2/0/360 -A1 -X-2c -Y4.4c -S2.8c -D -T -W5,black -Gblack \
    -O $tempfile -Bg0.5:,-"%":/g30 -LW/E/S/N >> $outfile
rm -f $tempfile

formats $outfile
