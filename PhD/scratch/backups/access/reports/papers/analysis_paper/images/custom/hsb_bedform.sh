#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

area=-R578106/588473/91505/98705
#parea=-R578106/589473/91505/98705
parea=$area
harea=-R0/1/0/30
warea=-R0/30/0/20
darea=-R0/360/0/10
proj=-Jx0.00215
hproj=-JX3.2/2
gres=-I300

infile=./raw_data/hsb_300m_subset_results_errors_asymm.csv
inbathy=./raw_data/all_lines_blockmedian_50m.xyz
outfile=./images/$(basename ${infile%.*}_bedform.ps)

formats(){
	echo -n "converting to pdf "
	ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $outfile ${outfile%.*}.pdf
	echo -n "and png... "
	gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
		-sOutputFile=${outfile%.ps}.png $outfile
	echo "done."
}

awk -F, '{if ($3>2) print $1,$2,$15}' $infile | \
	xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_likelihood.grd)
xyz2grd $inbathy $parea $gres -F -G./grids/$(basename ${infile%.*}_bathy_coverage.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_likelihood.grd)) -Cgray \
makecpt -T0/1/0.01 -Cgray \
	> ./cpts/$(basename ${infile%.*}_likelihood.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
	-X3.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_likelihood.cpt) \
	./grids/$(basename ${infile%.*}_likelihood.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_likelihood.grd) | \
	awk '{if ($3=="NaN") print $1,$2}' | \
	psxy $parea $proj -Sx0.9 -O -K >> $outfile
awk -F, '{print $1,$2}' $inbathy | \
	psmask $parea $proj $gres -F -N -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
#psscale -D22/12.7/5/0.3 -B0.2:"Presence": -C./cpts/$(basename ${infile%.*}_likelihood.cpt) -O >> $outfile

# Add a pie chart of the bed distribution
numsubsets=$(grd2xyz -S ./grids/$(basename ${infile%.*}_bathy_coverage.grd) | wc -l)
numbedformy=$(awk -F, '{if ($3>2 && $15==1) print $0}' $infile | wc -l)
numflat=$(awk -F, '{if ($3>2 && $15!=1) print $0}' $infile | wc -l)
numnotanalysed=$(echo "scale=2; $numsubsets-($numflat+$numbedformy)" | bc -l)

echo "bedforms: $(echo "($numbedformy/$numsubsets)*100" | bc -l)%, flat: $(echo "($numflat/$numsubsets)*100" | bc -l)%, ignored: $(echo "($numnotanalysed/$numsubsets)*100" | bc -l)%"
echo "bedforms: $(echo "($numbedformy/($numbedformy+$numflat))*100" | bc -l)%, flat: $(echo "($numflat/($numbedformy+$numflat))*100" | bc -l)%"

start_waves=0
end_waves=$(echo "scale=2; ($numbedformy/$numsubsets)*360" | bc -l)
start_flat=$end_waves
end_flat=$(echo "scale=2; $end_waves+(($numflat/$numsubsets)*360)" | bc -l)
start_ignored=$end_flat
end_ignored=360

gmtset MEASURE_UNIT=inch
psxy $parea $proj -O -SW -W2,black -C./cpts/$(basename ${infile%.*}_likelihood.cpt) \
    << PIE >> $outfile
581700 92050 1 1.25 $start_waves $end_waves
581700 92050 0 1.25 $start_flat $end_flat
581700 92050 0.5 1.25 $start_ignored $end_ignored
PIE
#581700 92050 1 1.25 0 90
#581700 92050 0 1.25 90 360
gmtset MEASURE_UNIT=cm

formats $outfile
