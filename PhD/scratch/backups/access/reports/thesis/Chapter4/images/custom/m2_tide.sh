#!/bin/bash

# Just quickly plot the amplitude and phase of the M2 tide from MIKE's database.

infile=./raw_data/mike_m2_amp_and_phase.csv
area=-R-17/17/43/67
proj=-Jm0.55c

base=$(basename ${infile%.*})

outfile=./images/$base.ps

#xyz2grd $area -I0.25/0.5 $infile -G./grids/$base.grd

makecpt $(grdinfo ./grids/$base.grd -T1) -Crainbow -Z > ./cpts/$base.cpt
psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile
grdimage $area $proj ./grids/$base.grd -O -K -C./cpts/$base.cpt >> $outfile
grdcontour $area $proj ./grids/$base.grd -C0.5 -W5 -S10 -O -K >> $outfile
pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

psxy $area $proj -L -A -W5,black,- -O << DOMAIN >> $outfile
-15 45
-15 65
15 65
15 45
DOMAIN


formats $outfile

