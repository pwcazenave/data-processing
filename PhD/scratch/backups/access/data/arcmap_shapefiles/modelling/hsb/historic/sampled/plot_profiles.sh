#!/bin/bash

# Script to plot the two profiles for the difference years across the Culver
# Sands. A bit tricky because the two profiles for each file are in the same
# file. Since there's only two, use the mean x coordinate as a filter value.

infiles1=(./*_1.xyz)
infiles2=(./*_2.xyz)
outfile=./hsb_profiles.ps

years=(1988 1993 1994 1995 1996 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010)

westEast1=$(cat "${infiles1[@]}" | minmax -C | awk '{print $1"/"$2}')
westEast2=$(cat "${infiles2[@]}" | minmax -C | awk '{print $1"/"$2}')
plotArea1=-R"$westEast1/10/25"
plotArea2=-R"$westEast2/15/30"

proj=-JX18.5c/-10c

gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16

lineSpec=($(makecpt -Cseis -T1/${#infiles1[@]}/1 --COLOR_MODEL=+RGB | grep -v '#' | awk '{print $2"/"$3"/"$4}' | grep -v [A-Z]))

for ((i=0; i<${#infiles1[@]}; i++)); do

    if [ $i -eq 0 ]; then
        # Panel 1 (western profiles)
        psbasemap $plotArea1 $proj -K -X2.25 -Y14 -P \
            -Ba1000f500:"Easting":/a5f1:"Depth CD (m)":WesN \
            > $outfile
        # Panel 2 (eastern profiles)
        psbasemap $plotArea2 $proj -O -K -Y-12 \
            -Ba1000f500:"Easting":/a5f1:"Depth CD (m)":WeSn \
            >> $outfile
    fi

    # Do the first profile
    # Remove duplicate positions
    sort -k1 "${infiles1[i]}" | \
        awk '{ if (a[$1]++ == 0) print $1,sqrt($3^2); }' | \
        psxy $plotArea1 $proj -O -K -Y12 -B0 -W5,${lineSpec[i]} >> $outfile

    # And the second
    #awk '{print $1,sqrt($3^2)}' "${infiles2[i]}" | sort -u -k1 | \
    sort -k1 "${infiles2[i]}" | \
        awk '{ if (a[$1]++ == 0) print $1,sqrt($3^2); }' | \
        psxy $plotArea2 $proj -O -K -Y-12 -B0 -W5,${lineSpec[i]} >> $outfile

done

# Add a key
x=8
y=2.7

startX=0.75
inc=0

psbasemap -R0/25/0/30 -JX25/31 -X-2.5 -Y-3 -B0 -O -K -P >> $outfile
yPos=13.7
for ((i=0; i<=${#infiles1[@]}; i++)); do
    psxy -R -J -B0 -O -K -W10,${lineSpec[i]} << LINE >> $outfile
    $(echo "scale=2; $startX+$inc+2" | bc -l) $yPos
    $(echo "scale=2; $startX+$inc+2.8" | bc -l) $yPos
LINE
    pstext -R -J -O -K -D0/-0.5 << MANNINGS >> $outfile
    $(echo "scale=2; $startX+$inc+2" | bc -l) $yPos 9.5 0 0 1 ${years[i]}
MANNINGS
    inc=$(echo "scale=2; $inc+1" | bc -l)

done

psxy $plotArea1 $proj -O -T >> $outfile

formats $outfile
