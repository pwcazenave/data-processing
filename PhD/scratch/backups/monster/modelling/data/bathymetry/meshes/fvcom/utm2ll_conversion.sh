#!/bin/bash

# Pull out the coordinates and convert accordingly.

set -eu

infile=./ukerc_v14_manual_bathy/ukerc_v14_manual_bathy.2dm
outdir=$(dirname ${infile})

dos2unix $infile

grep ND\  $infile > $outdir/only-nodes.txt
grep -v ND\  $infile > $outdir/not-nodes.txt

# Convert with proj
awk '{print $3,$4}' $outdir/only-nodes.txt | \
    invproj +proj=utm +ellps=WGS84 +zone=30 -f %.6f > $outdir/only-nodes-latlong.txt

# Put the other information back
paste $outdir/only-nodes.txt $outdir/only-nodes-latlong.txt | awk '{print $1,$2,$6,$7,$5}' \
    > $outdir/only-nodes-latlong-extra.txt

# The last bit you have to do manually: add the ND lines between the E3T
# and NS lines in not-nodes.txt
