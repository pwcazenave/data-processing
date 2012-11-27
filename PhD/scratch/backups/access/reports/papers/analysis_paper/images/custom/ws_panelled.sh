#!/bin/bash

# Script to plot the wavelength, orientation, height and asymmetry for the
# west Solent data as four panels.

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset PAPER_MEDIA=a4

gres=200
ingrd=./grids/ws_1m_blockmean.grd
infile=./raw_data/ws_200m_subset_results_errors_asymm.csv
inbathy=./raw_data/ws_mask_bathy_50m.xyz

area=$(grdinfo -I1 $ingrd)
proj=-Jx0.00053

harea=-R0/1/0/20
warea=-R0/25/0/20
darea=-R0/180/0/20
aarea=-R0/360/0/10
hproj=-JX2.8/1.8

outfile=./images/ws_${gres}m_panels.ps

formats(){
   echo -n "converting to pdf, "
   ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "png, "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $outfile
   echo "done."
}

mkgrids(){
    awk -F, '{if ($3>2 && $15==1) print $1,$2,$3}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_wavelength.grd)
    awk -F, '{if ($3>2 && $15==1 && $4<90) print $1,$2,$4+90; else if ($3>2 && $15==1 && $4>=90) print $1,$2,$4-90}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_orientation.grd)
    awk -F, '{if ($3>2 && $15==1) print $1,$2,$5}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_height.grd)
    awk -F, '{if ($3>2 && $15==1) print $1,$2,$14}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_asymmetry.grd)

    awk -F, '{if ($3>2) print $1,$2,0}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_coverage.grd)
}

mkcpts(){
	makecpt -T0/25/0.1 -Z > ./cpts/$(basename ${infile%.*})_wavelength.cpt
	makecpt -T0/1/0.05 -Z > ./cpts/$(basename ${infile%.*})_height.cpt
	makecpt -T0/180/0.5 -Ccyclic -Z > ./cpts/$(basename ${infile%.*})_orientation.cpt
	makecpt -T0/360/1 -Ccyclic -Z > ./cpts/$(basename ${infile%.*})_asymmetry.cpt
}

plots(){
	# Height
	psbasemap $area $proj -Ba8000f4000:"Eastings":/a4000f2000:"Northings":WeSn -X3.5 -K > $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_height.cpt) \
	   	./grids/$(basename ${infile%.*}_height.grd) -O -K >> $outfile
	# Add grid of boxes over entire domain
	grd2xyz ./grids/$(basename ${infile%.*}_height.grd) | \
	   	awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Ss0.16 -O -K >> $outfile
	# Add crosses where we don't have a result at all
	grd2xyz ./grids/$(basename ${infile%.*}_coverage.grd) | \
		awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Sx0.15 -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -G128/128/128 -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/5.5/3.5/0.2 -B0.25:"Height (m)": -C./cpts/$(basename ${infile%.*}_height.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
	# Histogram
	gmtset ANNOT_FONT_SIZE=8
	gmtset LABEL_OFFSET=0.1c ANNOT_OFFSET_PRIMARY=0.05c
    awk -F, '{if ($3>2 && $15==1) print $5}' $infile | \
        pshistogram $harea $hproj -W0.05 -Ggray -L1 -O -K -Z1 \
        -Ba0.5f0.1:,"-m":/a10f2:,"-%":WesN -X7.85 -Y0.3 >> $outfile
	gmtset ANNOT_FONT_SIZE=14 LABEL_OFFSET=0.3 ANNOT_OFFSET_PRIMARY=0.2c

	# Asymmetry
	psbasemap $area $proj -Ba8000f4000:"Eastings":/a4000f2000:"Northings":weSn -X3.75 -Y-0.3 -O -K >> $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_asymmetry.cpt) \
	   	./grids/$(basename ${infile%.*}_asymmetry.grd) -O -K >> $outfile
	# Add grid of boxes over entire domain
	grd2xyz ./grids/$(basename ${infile%.*}_asymmetry.grd) | \
	   	awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Ss0.16 -O -K >> $outfile
	# Add crosses where we don't have a result at all
	grd2xyz ./grids/$(basename ${infile%.*}_coverage.grd) | \
		awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Sx0.15 -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -G128/128/128 -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/5.5/3.5/0.2 -B90:"Asymmetry (@+o@+)": -C./cpts/$(basename ${infile%.*}_asymmetry.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
	# Histogram
	gmtset ANNOT_FONT_SIZE=8
	gmtset LABEL_OFFSET=0.1c ANNOT_OFFSET_PRIMARY=0.05c
    awk -F, '{if ($3>2 && $15==1) print $14}' $infile | \
        pshistogram $aarea $hproj -W5 -Ggray -L1 -O -K -Z1 \
        -Ba90f30:,"-@+o@+":/a5f1:,"-%":WesN -X7.85 -Y0.3 >> $outfile
	gmtset ANNOT_FONT_SIZE=14 LABEL_OFFSET=0.3 ANNOT_OFFSET_PRIMARY=0.2c

	# Wavelength
	psbasemap $area $proj -Ba8000f4000:"Eastings":/a4000f2000:"Northings":Wesn -X-19.45 -Y7.8 -O -K >> $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_wavelength.cpt) \
	   	./grids/$(basename ${infile%.*}_wavelength.grd) -O -K >> $outfile
	# Add grid of boxes over entire domain
	grd2xyz ./grids/$(basename ${infile%.*}_wavelength.grd) | \
	   	awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Ss0.16 -O -K >> $outfile
	# Add crosses where we don't have a result at all
	grd2xyz ./grids/$(basename ${infile%.*}_coverage.grd) | \
		awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Sx0.15 -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -G128/128/128 -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/5.5/3.5/0.2 -B5:"Wavelength (m)": -C./cpts/$(basename ${infile%.*}_wavelength.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
	# Histogram
	gmtset ANNOT_FONT_SIZE=8
	gmtset LABEL_OFFSET=0.1c ANNOT_OFFSET_PRIMARY=0.05c
    awk -F, '{if ($3>2 && $15==1) print $3}' $infile | \
        pshistogram $warea $hproj -W1 -Ggray -L1 -O -K -Z1 \
        -Ba10f2:,"-m":/a10f2:,"-%":WesN -X7.85 -Y0.3 >> $outfile
	gmtset ANNOT_FONT_SIZE=14 LABEL_OFFSET=0.3 ANNOT_OFFSET_PRIMARY=0.2c

	# Orientation
	psbasemap $area $proj -Ba8000f4000:"Eastings":/a4000f2000:"Northings":wesn -X3.75 -Y-0.3 -O -K >> $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_orientation.cpt) \
	   	./grids/$(basename ${infile%.*}_orientation.grd) -O -K >> $outfile
	# Add grid of boxes over entire domain
	grd2xyz ./grids/$(basename ${infile%.*}_orientation.grd) | \
	   	awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Ss0.16 -O -K >> $outfile
	# Add crosses where we don't have a result at all
	grd2xyz ./grids/$(basename ${infile%.*}_coverage.grd) | \
		awk '{if ($3=="NaN") print $1,$2}' | \
		psxy $area $proj -Sx0.15 -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -G128/128/128 -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/5.5/3.5/0.2 -B45:"Orientation (@+o@+)": -C./cpts/$(basename ${infile%.*}_orientation.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
	# Histogram
	gmtset ANNOT_FONT_SIZE=8
	gmtset LABEL_OFFSET=0.1c ANNOT_OFFSET_PRIMARY=0.05c
    awk -F, '{if ($3>2 && $15==1) print $4}' $infile | \
        pshistogram $darea $hproj -W5 -Ggray -L1 -O -Z1 \
        -Ba45f15:,"-@+o@+":/a10f2:,"-%":WesN -X7.85 -Y0.3 >> $outfile
	gmtset ANNOT_FONT_SIZE=14 LABEL_OFFSET=0.3 ANNOT_OFFSET_PRIMARY=0.2c
}

mkgrids
mkcpts
plots
formats $outfile
