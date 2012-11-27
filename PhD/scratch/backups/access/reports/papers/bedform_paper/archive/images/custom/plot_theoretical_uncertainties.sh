#!/bin/bash

# Script to plot the theoretical uncertainties for the synthetic surface in
# the bedform analysis technique paper.

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=18
gmtset ANNOT_FONT_SIZE=18

infile=./raw_data/theoretical_uncertainties.csv
outfile=./images/$(basename ${infile%.*}).ps

westeast=$(awk -F, '{print $1}' $infile | minmax -C | tr "\t" "/")
wnorth=$(awk -F, '{print $3}' $infile | minmax -C | awk '{printf "%i\n", $2}')
wsouth=$(awk -F, '{print $4}' $infile | minmax -C | awk '{printf "%i\n", $1}')
onorth=$(awk -F, '{print $6}' $infile | minmax -C | awk '{printf "%i\n", $2}')
osouth=$(awk -F, '{print $7}' $infile | minmax -C | awk '{printf "%i\n", $1}')
pwnorth=$(awk -F, '{print $8,$9}' $infile | minmax -C | tr "\t" "\n" | minmax -C | awk '{printf "%i\n", $2}')
pwsouth=$(awk -F, '{print $9}' $infile | minmax -C | awk '{printf "%i\n", $1}')
ponorth=$(awk -F, '{print $10,$11}' $infile | minmax -C | tr "\t" "\n" | minmax -C | awk '{printf "%i\n", $2}')
posouth=$(awk -F, '{print $11}' $infile | minmax -C | awk '{printf "%i\n", $1}')


warea=-R$westeast/$wsouth/$wnorth
pwarea=-R$westeast/$pwsouth/$pwnorth
oarea=-R$westeast/$osouth/$onorth
poarea=-R$westeast/$posouth/$ponorth

proj=-JX11c/8c

# Raw values:

# Orientation uncertainty
psbasemap $oarea $proj -Ba20f5:,-%:/a10f2:"Crest orientation"::,-@+o@+:WeSn \
    -K -X3 -Y12 > $outfile
# Orientation
awk -F, '{print $1,$5}' $infile | \
    psxy $oarea $proj -W8.5,black -O -K >> $outfile
# Orientation positive error
awk -F, '{print $1,$6}' $infile | \
    psxy $oarea $proj -W8.5,grey -O -K >> $outfile
# Orientation negative error
awk -F, '{print $1,$7}' $infile | \
    psxy $oarea $proj -W8.5,grey -O -K >> $outfile

# Add a 10% line. Something weird going on here. $o{south,north} don't
# work for some reason...
psxy $oarea $proj -W8.5,black,- -O -K << TENPERCENT >> $outfile
10 $wsouth
10 $wnorth
TENPERCENT

# Add some labels
pstext $oarea $proj -O -K -N << LABELS >> $outfile
92 153 18 0 0 1 @~f@~
92 173 18 0 0 1 @~f@~@-p@-
92 116 18 0 0 1 @~f@~@-n@-
12 172 18 0 0 1 10% @~l@~
0.5 182 22 0 0 1 A
LABELS


# Wavelength uncertainty
psbasemap $warea $proj -Ba20f5:,-%:/a100f20:"Wavelength"::,-m:wESn \
    -O -K -X12.55 >> $outfile
# Wavelength
awk -F, '{print $1,$2}' $infile | \
    psxy $warea $proj -W8.5,black -O -K >> $outfile
# Wavelength positive error
awk -F, '{print $1,$3}' $infile | \
    psxy $warea $proj -W8.5,grey -O -K >> $outfile
# Wavelength negative error
awk -F, '{print $1,$4}' $infile | \
    psxy $warea $proj -W8.5,grey -O -K >> $outfile

# Add a 10% line
psxy $warea $proj -W8.5,black,- -O -K << TENPERCENT >> $outfile
10 $wsouth
10 $wnorth
TENPERCENT

# Add some labels
pstext $warea $proj -O -K -N << LABELS >> $outfile
90 202 18 0 0 1 @~l@~
90 510 18 0 0 1 @~l@~@-p@-
90 70 18 0 0 1 @~l@~@-n@-
12 480 18 0 0 1 10% @~l@~
0 560 22 0 0 1 B
LABELS

# Percentages

# Orientation uncertainty
psbasemap $poarea $proj -Ba20f5:"Wavelength as percentage of domain size"::,-%:/a10f2:"Crest orientation uncertainty"::,-%:WeSn \
    -O -K -X-12.5 -Y-10 >> $outfile
# Orientation positive error
awk -F, '{print $1,$10}' $infile | \
    psxy $poarea $proj -W8.5,black -O -K >> $outfile
# Orientation negative error
awk -F, '{print $1,$11}' $infile | \
    psxy $poarea $proj -W8.5,black -O -K >> $outfile

# Add a 10% line. Something weird going on here. $o{south,north} don't
# work for some reason...
psxy $poarea $proj -W8.5,black,- -O -K << TENPERCENT >> $outfile
10 $wsouth
10 $wnorth
TENPERCENT

# Add some labels
pstext $poarea $proj -O -K -N << LABELS >> $outfile
92 43 18 0 0 1 @~f@~@-p@-
82 61 18 0 0 1 @~f@~@-n@-
12 58 18 0 0 1 10% @~l@~
0 68 22 0 0 1 C
LABELS


# Wavelength uncertainty
psbasemap $pwarea $proj -Ba20f5:"Wavelength as percentage of domain size"::,-%:/a30f5:"Wavelength uncertainty"::,-%:wESn \
    -O -K -X12.5 >> $outfile
# Wavelength positive error
awk -F, '{print $1,$8}' $infile | \
    psxy $pwarea $proj -W8.5,black -O -K >> $outfile
# Wavelength negative error
awk -F, '{print $1,$9}' $infile | \
    psxy $pwarea $proj -W8.5,black -O -K >> $outfile

# Add a 10% line
psxy $pwarea $proj -W8.5,black,- -O -K << TENPERCENT >> $outfile
10 $wsouth
10 $wnorth
TENPERCENT

# Add some labels
pstext $pwarea $proj -O -N << LABELS >> $outfile
87 155 18 0 0 1 @~l@~@-p@-
92 26 18 0 0 1 @~l@~@-n@-
12 150 18 0 0 1 10% @~l@~
0 177 22 0 0 1 D
LABELS


formats $outfile
