#!/bin/bash

# Script to plot the results of the bedform analysis at Culver as
# three histograms to be superimposed on the ArcGIS vector image.
# Also do a rose diagram.

infileT=./raw_data/culver_v7_cal1_HMvar_res_total_arcgis.csv
infileS=./raw_data/culver_v7_cal1_HMvar_res_sus_arcgis.csv
infileB=./raw_data/culver_v7_cal1_HMvar_res_bed_arcgis.csv
outfile=./images/culver_sands_modelled_transport_histograms.ps

tarea=-R-180/180/0/5
sarea=-R-180/180/0/5
barea=-R-180/180/0/10
rarea=-R-180/180/0/20
hproj=-JX4.5/3

west=-3.412835
east=-3.188483
south=51.246059
north=51.326487

# The histograms
gmtset ANNOT_FONT_SIZE=12
gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
awk -F, '{if (NR>1 && $1>'$west' && $1<'$east' && $2>'$south' && $2<'$north' && $3!=0) print $3}' $infileT | \
    pshistogram $tarea $hproj -W1 -Ggray -L1 -K -Z1 \
    -Ba90f10:,"-@+o@+":/a2.5f0.5:,"-%":WeSn -X1.5c -Y1c > $outfile
awk -F, '{if (NR>1 && $1>'$west' && $1<'$east' && $2>'$south' && $2<'$north' && $3!=0) print $3}' $infileS | \
    pshistogram $sarea $hproj -W1 -Ggray -L1 -O -K -T0 -Z1 \
    -Ba90f10:,"-@+o@+":/a2.5f0.5:,"-%":WeSn -X6.5c >> $outfile
awk -F, '{if (NR>1 && $1>'$west' && $1<'$east' && $2>'$south' && $2<'$north' && $3!=0) print $3}' $infileB | \
    pshistogram $barea $hproj -W1 -Ggray -L1 -O -K -Z1 \
    -Ba90f10:,"-@+o@+":/a5f1:,"-%":WeSn -X6.5c >> $outfile

# The rose
tempfile=$(mktemp)
awk -F, '{if (NR>1 && $3!=0) print $3}' $infileT | \
    pshistogram $rarea $hproj -W1 -T0 -Z1 -IO 2> /dev/null | \
    awk '{print $2,$1}' > $tempfile
psrose -R0/1/0/360 -A1 -X-2c -Y4.4c -S2.8c -D -T -W5,black -Gblack \
    -O $tempfile -Bg0.25:,-"%":/g30 -LW/E/S/N >> $outfile
rm -f $tempfile

formats $outfile
