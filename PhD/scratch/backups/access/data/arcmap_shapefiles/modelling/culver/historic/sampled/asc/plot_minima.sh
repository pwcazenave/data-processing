#!/bin/bash

# Instead of fucking around in Excel, just plot the damn thing in GMT.

infile=./minmax.txt
outfile=./culver_bank_minima.ps

area=$(awk '{if (NR>1) print $1,$2}' $infile | minmax -I10/1)
proj=-JX16c/-9c

gmtset ANNOT_FONT_SIZE=32 LABEL_FONT_SIZE=35

psbasemap $area $proj -Ba50f10:"Year":/a2f0.5:"Depth (m)":WeSn -X4c -Y3c -K > $outfile
psxy $area $proj $infile -H1 -O -K -Sc0.35 -Gblack >> $outfile
psxy $area $proj $infile -H1 -O -W15,black >> $outfile

formats $outfile

