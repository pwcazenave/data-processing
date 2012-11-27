#!/bin/bash

# Plot the locations for the data used in the paper.

europeArea=-R-3/6.5/49.5/54
iowArea=-R-1.8/-0.8/50.5/51
hsbArea=-R0.1/1.14/50.5/51
dutchArea=-R4.4/5.5/52.8/53.32
europeProj=-Jm1
iowProj=-Jm9.1
hsbProj=-Jm9.1
dutchProj=-Jm8.3

hsbLoc=(0.58741 50.729397)
wSolentLoc=(-1.441101 50.744667)
eSolentLoc=(-1.038583 50.739455)
dutchLoc=(4.937753 53.046283)

gebco=../../../../../data/gebco/gebco08/grids/GEBCO_08.nc
britned=../../../../../data/britned/britned_bathy_wgs84_cut.grd
seazone=../../../../../data/seazone/ThamesEstuary/grids/seazone.grd

outfile=./images/locations.ps

set -eu

gmtdefaults -D > .gmtdefaults4
gmtset ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 BASEMAP_TYPE=plain \
    ANNOT_OFFSET=0.05c PLOT_DEGREE_FORMAT=FD

makecpt -T-100/0/10 -Cgray -Z > ./cpts/gebco_europe.cpt
makecpt -T-100/0/10 -Cgray -Z > ./cpts/gebco_iow.cpt
makecpt -T-100/0/10 -Cgray -Z > ./cpts/gebco_hsb.cpt
makecpt -T-100/0/10 -Cgray -Z > ./cpts/gebco_dutch.cpt


# Europe
psbasemap $europeArea $europeProj -Ba2/a1WesN -K -X2.5 -Y13 > $outfile
grdimage $europeArea $europeProj -C./cpts/gebco_europe.cpt $gebco -O -K >> $outfile
grdimage $europeArea $europeProj -C./cpts/gebco_europe.cpt $britned -O -K >> $outfile
pscoast $europeArea $europeProj -Df -O -K -W -Ggray -N1 >> $outfile
psxy $europeArea $europeProj -W3,black -O -K -L << BOX1 >> $outfile
-1.8 50.5
-1.8 51
-0.8 51
-0.8 50.5
BOX1
psxy $europeArea $europeProj -W3,black -O -K -L << BOX2 >> $outfile
0.1 50.5
0.1 51
1.15 51
1.15 50.5
BOX2
psxy $europeArea $europeProj -W3,black -O -K -L << BOX3 >> $outfile
4.4 52.8
4.4 53.32
5.5 53.32
5.5 52.8
BOX3
pstext $europeArea $europeProj -D0.05/-0.3 -O -K -Gblack << LABELS >> $outfile
-1.8 51 10 0 0 1 1
0.1 51 10 0 0 1 2
4.4 53.32 10 0 0 1 3
LABELS
pstext $europeArea $europeProj -O -K -Gblack << LABELS >> $outfile
-2 52.5 10 0 0 1 England
2 50 10 0 0 1 France
4 50.75 10 0 0 1 Belgium
4.25 51.93 10 0 0 1 Netherlands
LABELS

# IOW subsets
psbasemap $iowArea $iowProj -Ba0.25/0.2wEsN -O -K -X11 >> $outfile
grdimage $iowArea $iowProj -C./cpts/gebco_iow.cpt $seazone -Q -O -K >> $outfile
pscoast $iowArea $iowProj -Df -O -K -W -Ggray >> $outfile
psbasemap $iowArea $iowProj -B0 -O -K -Lf-1/50.925/50.925/20k+l"km" --LABEL_FONT_SIZE=12 --ANNOT_FONT_SIZE=10 >> $outfile
psxy $iowArea $iowProj -W2,black -O -K -Sc0.19c -W4,black << LOCATIONS >> $outfile
${wSolentLoc[@]}
${eSolentLoc[@]}
LOCATIONS
psxy $iowArea $iowProj -W2,black -O -K -Ss0.19c -W4,black << LOCATIONS >> $outfile
-1.300549 50.752852
-1.404701 50.909470
LOCATIONS
pstext $iowArea $iowProj -D0/-0.65 -O -K -Gblack << TEXT >> $outfile
-1.300549 50.762852 12 0 0 2 Cowes
TEXT
pstext $iowArea $iowProj -D0/0.2 -O -K -Gblack << TEXT >> $outfile
-1.404701 50.909470 12 0 0 2 Southampton
TEXT
pstext $iowArea $iowProj -D-2.2/0.4 -O -K -WwhiteO0,white -Gblack << TEXT >> $outfile
${wSolentLoc[@]} 12 0 0 1 West Solent
TEXT
pstext $iowArea $iowProj -D-0.6/-0.65 -O -K -WwhiteO0,white -Gblack << TEXT >> $outfile
${eSolentLoc[@]} 12 0 0 1 East Solent
TEXT

# Hastings subset
psbasemap $hsbArea $hsbProj -Ba0.25/0.2WeSn -O -K -X-11 -Y-8 >> $outfile
grdimage $hsbArea $hsbProj -C./cpts/gebco_hsb.cpt $gebco -O -K >> $outfile
pscoast $hsbArea $hsbProj -Df -O -K -W -Ggray >> $outfile
psbasemap $hsbArea $hsbProj -B0 -O -K -Lf0.275/50.94/50.94/20k+l"km" --LABEL_FONT_SIZE=12 --ANNOT_FONT_SIZE=10 >> $outfile
psxy $hsbArea $hsbProj -W2,black -O -K -Sc0.19c -W4,black << LOCATIONS >> $outfile
${hsbLoc[@]}
LOCATIONS
psxy $hsbArea $hsbProj -W2,black -O -K -Ss0.19c -W4,black << LOCATIONS >> $outfile
0.290501 50.767866
0.575868 50.852241
0.738335 50.949004
LOCATIONS
pstext $hsbArea $hsbProj -D-0.2/-0.65 -O -K -WwhiteO0,white -Gblack << TEXT >> $outfile
${hsbLoc[@]} 12 0 0 1 Hastings Shingle Bank
TEXT
pstext $hsbArea $hsbProj -D0/0.2 -O -K -Gblack << TEXT >> $outfile
0.290501 50.767866 12 0 0 2 Eastbourne
0.575868 50.852241 12 0 0 3 Hastings
0.738335 50.949004 12 0 0 3 Rye
TEXT

# Dutch subset
psbasemap $dutchArea $dutchProj -Ba0.25/0.2wESn -O -K -X11 >> $outfile
grdimage $dutchArea $dutchProj -C./cpts/gebco_dutch.cpt $gebco -O -K >> $outfile
pscoast $dutchArea $dutchProj -Df -O -K -W -Ggray >> $outfile
psbasemap $dutchArea $dutchProj -B0 -O -K -Lf4.58/53.26/53.27/20k+l"km" --LABEL_FONT_SIZE=12 --ANNOT_FONT_SIZE=10 >> $outfile
psxy $dutchArea $dutchProj -W2,black -O -K -Sc0.19c -W4,black << LOCATIONS >> $outfile
${dutchLoc[@]}
LOCATIONS
psxy $dutchArea $dutchProj -W2,black -O -K -Ss0.19c -W4,black << LOCATIONS >> $outfile
4.761779 52.953425
4.800386 53.054383
LOCATIONS
pstext $dutchArea $dutchProj -D-0.2/-0.65 -O -K -WwhiteO0,white -Gblack << TEXT >> $outfile
${dutchLoc[@]} 12 0 0 1 Wadden Sea
TEXT
pstext $dutchArea $dutchProj -D-0.2/-0.2 -O -K -Gblack << TEXT >> $outfile
4.761779 52.953425 12 0 0 3 Den Helder
4.800386 53.054383 12 0 0 3 Den Burg
TEXT

psxy -R -J -T -O >> $outfile

formats $outfile
