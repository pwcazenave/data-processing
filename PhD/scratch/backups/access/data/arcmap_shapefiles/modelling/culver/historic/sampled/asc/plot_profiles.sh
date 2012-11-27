#!/bin/bash

# Script to plot the two profiles for the difference years across the Culver
# Sands. A bit tricky because the two profiles for each file are in the same
# file. Since there's only two, use the mean x coordinate as a filter value.

#infiles=(./*.xyz)
# Need a specific order
infiles=(l389_1795_c.xyz l389_1831_c.xyz l389_1848_c.xyz l389_1886_c.xyz l389_1925_c.xyz l389_1939_c.xyz l389_1965_c.xyz l389_1979_c.xyz l389_1989_c.xyz l389_0899_c.xyz l389_091999_c.xyz l389_032000_c.xyz 2006_1m_bng.xyz 2008_2m_bng.xyz 2009_2m_bng.xyz 2010_2m_bng.xyz)
outfile=./culver_profiles.ps

years=(1795 1831 1848 1886 1925 1939 1965 1979 1989 1999 1999 2000 2006 2008 2009 2010)

geogArea=$(minmax -I1 "${infiles[@]}")
southNorth=$(cat "${infiles[@]}" | minmax -C | awk '{print $3"/"$4}')
plotArea=-R"$southNorth/-2/23"

proj=-JX18.5c/-10c

# Find the mean x coordinate and use as the threshold for each profile
threshX=$(awk '{total+=$1}END{print total/NR}' "${infiles[@]}")

gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16

#lineSpec=('red' 'green' 'blue' 'black' 'grey' 'navy' 'orange' 'darkviolet' 'teal' 'greenyellow' 'yellow' '100/200/200' '255/200/100' '134/14/55' '6/223/55')
lineSpec=($(makecpt -Cseis -T1/${#infiles[@]}/1 --COLOR_MODEL=+RGB | grep -v '#' | awk '{print $2"/"$3"/"$4}' | grep -v [A-Z]))

for ((i=0; i<${#infiles[@]}; i++)); do

    if [ $i -eq 0 ]; then
        # Panel 1 (western profiles)
        psbasemap $plotArea $proj -K -X2.25 -Y14 -P \
            -Ba1000f500:"Northing":/a5f1:"Depth CD (m)":WesN \
            > $outfile
        # Panel 2 (eastern profiles)
        psbasemap $plotArea $proj -O -K -Y-12 \
            -Ba1000f500:"Northing":/a5f1:"Depth CD (m)":WeSn \
            >> $outfile
    fi

    # Do the first profile
    awk '{if ($1<'$threshX') print $2,sqrt($3^2)}' "${infiles[i]}" | \
        psxy $plotArea $proj -O -K -Y12 -B0 -W5,${lineSpec[i]} >> $outfile

    # And the second
    awk '{if ($1>'$threshX') print $2,sqrt($3^2)}' "${infiles[i]}" | \
        psxy $plotArea $proj -O -K -Y-12 -B0 -W5,${lineSpec[i]} >> $outfile

done

# Add a key
x=8
y=2.7

startX=1.3
yOff=$(echo "scale=2; $y+1" | bc -l)
xOff=$(echo "scale=2; $x+0.7" | bc -l)
inc=0

psbasemap -R0/25/0/30 -JX25/31 -X-2.25 -Y-3 -B0 -O -K -P >> $outfile
yPos=13.7
for ((i=0; i<=${#infiles[@]}; i++)); do
    psxy -R -J -B0 -O -K -W10,${lineSpec[i]} << LINE >> $outfile
    $(echo "scale=2; $startX+$inc+1.5" | bc -l) $yPos
    $(echo "scale=2; $startX+$inc+2.3" | bc -l) $yPos
LINE
    pstext -R -J -O -K -D0/-0.5 << MANNINGS >> $outfile
    $(echo "scale=2; $startX+$inc+1.5" | bc -l) $yPos 10 0 0 1 ${years[i]}
MANNINGS
    inc=$(echo "scale=2; $inc+1.1" | bc -l)

done

psxy $plotArea $proj -O -T >> $outfile

formats $outfile
