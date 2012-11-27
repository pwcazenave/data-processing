#!/bin/bash

# Script to plot the wavelength, orientation, height and asymmetry for the
# west Solent data as four panels.

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset PAPER_MEDIA=a4

gres=1500/2500
ingrd=./grids/sns_utm31n_200m.grd
infile=./raw_data/seazone_1500-2500m_subset_results_errors_asymm.csv
inbathy=./raw_data/sns_utm31n_1000m.xyz

area=$(grdinfo -I1 $ingrd)
west=$(echo $area | cut -f1 -d/ | tr -d -- "-R")
east=$(echo $area | cut -f2 -d/)
south=$(echo $area | cut -f3 -d/)
north=$(echo $area | cut -f4 -d/)
#west=365000
#east=500000
south=5670000
#north=5929800
area=-R$west/$east/$south/$north
proj=-Jx4e-5

harea=-R0/10/0/10 # for the results histograms
warea=-R150/300/0/40 # wavelength
darea=-R0/180/0/15 # orientation
ararea=-R0/4/0/10 # asymmetry ratio
aarea=-R0/360/0/5 # asymmetry direction
hproj=-JX2.8/1.8

outfile=./images/thames_${gres/\//-}m_panels.ps

mkgrids(){
    awk -F, '{if ($3>2 && $15==1) print $1,$2,$3}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_wavelength.grd)
    awk -F, '{if ($3>2 && $15==1 && $4<90) print $1,$2,$4+90; else if ($3>2 && $15==1 && $4>=90) print $1,$2,$4-90}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_orientation.grd)
    awk -F, '{if ($3>2 && $15==1) print $1,$2,$5}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_height.grd)
    awk -F, '{if ($3>2 && $15==1) print $1,$2,$14}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_asymmetry.grd)
    awk -F, '{if ($3>2 && $15==1 && $19=="NaN") print $1,$2,-10; else if ($3>2 && $15==1) print $1,$2,$19}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_asymmetry_magnitude.grd)
    awk -F, '{if ($3>2) print $1,$2,0}' $infile | \
        xyz2grd $area -I$gres -G./grids/$(basename ${infile%.*}_coverage.grd)
}

mkcpts(){
	makecpt -T100/300/0.1 -Z > ./cpts/$(basename ${infile%.*})_wavelength.cpt
	makecpt -T0/10/0.5 -Z > ./cpts/$(basename ${infile%.*})_height.cpt
	makecpt -T0/180/0.5 -Ccyclic -Z > ./cpts/$(basename ${infile%.*})_orientation.cpt
	makecpt -T0/360/1 -Ccyclic -Z > ./cpts/$(basename ${infile%.*})_asymmetry.cpt
	makecpt -T0/2.5/0.1 -Z > ./cpts/$(basename ${infile%.*})_asymmetry_magnitude.cpt
}

plots(){
	# Height
	psbasemap $area $proj -Ba50000f10000:"Eastings":/a50000f10000:"Northings":WeSn -X3.5c -Y2c -K -P > $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_height.cpt) \
	   	./grids/$(basename ${infile%.*}_height.grd) -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -Gwhite -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/6/3.5/0.2 -Ba2f0.5:"Height (m)": -C./cpts/$(basename ${infile%.*}_height.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14

	# Asymmetry
	psbasemap $area $proj -Ba50000f10000:"Eastings":/a50000f10000:"Northings":weSn -X7.85c -O -K >> $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_asymmetry.cpt) \
	   	./grids/$(basename ${infile%.*}_asymmetry.grd) -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -Gwhite -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/6/3.5/0.2 -Ba90f30:"Asymmetry (@+o@+)": -C./cpts/$(basename ${infile%.*}_asymmetry.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14

	# Wavelength
	psbasemap $area $proj -Ba50000f10000:"Eastings":/a50000f10000:"Northings":Wesn -X-7.85 -Y11 -O -K >> $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_wavelength.cpt) \
	   	./grids/$(basename ${infile%.*}_wavelength.grd) -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -Gwhite -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/6/3.5/0.2 -Ba50f10:"Wavelength (m)": -C./cpts/$(basename ${infile%.*}_wavelength.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14

	# Asymmetry magnitude
	psbasemap $area $proj -Ba50000f10000:"Eastings":/a50000f10000:"Northings":wesn -X7.85c -O -K >> $outfile
	grdimage $area $proj -C./cpts/$(basename ${infile%.*}_asymmetry_magnitude.cpt) \
	   	./grids/$(basename ${infile%.*}_asymmetry_magnitude.grd) -O -K >> $outfile
	awk -F, '{print $1,$2,$5}' $inbathy | \
	   	psmask $area $proj -I$gres -N -S350 -Gwhite -O -K >> $outfile
	psmask -C -O -K >> $outfile
	# Add in the IOW and Hampshire coastlines
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
	psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
	gmtset LABEL_FONT_SIZE=12 ANNOT_FONT_SIZE=12
	psscale -D0.3/6/3.5/0.2 -Ba1f0.2:"Asymmetry ratio": -C./cpts/$(basename ${infile%.*}_asymmetry_magnitude.cpt) -O -K >> $outfile
	gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
}

add_histograms(){
    # Add in the histograms
    gmtset ANNOT_FONT_SIZE=12
    gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
    # Filter out all values below the nyquist frequency (40m)
#       psbasemap $harea $hproj -Gwhite -O -K -X2c -Y17c >> $1
    awk -F, '{if ($1>'$west' && $2>'$south' && $3>40 && $15==1) print $5}' $infile | \
            pshistogram $harea $hproj -W0.2 -Ggray -L1,gray -O -K -Z1 \
            -Ba5f1:,"-m":/a5f1:,"-%":WeSn -X-9.5c -Y11.5c >> $1
#       psbasemap $harea $hproj -Gwhite -O -K -Y-4.5c >> $1
    awk -F, '{if ($1>'$west' && $2>'$south' && $3>40 && $15==1) print $14}' $infile | \
            pshistogram $aarea $hproj -W5 -Ggray -L1,gray -O -K -T0 -Z1 \
    -Ba180f20:,"-@+o@+":/a2.5f0.5:,"-%":WeSn -X4.7c >> $1
#       psbasemap $harea $hproj -Gwhite -O -K -X9.5c -Y-6c >> $1
    awk -F, '{if ($1>'$west' && $2>'$south' && $3>40 && $15==1) print $3}' $infile | \
    pshistogram $warea $hproj -W20 -Ggray -L1,gray -O -K -Z1 \
    -Ba75f25:,"-m":/a20f5:,"-%":WeSn -X4.7c >> $1
#       psbasemap $harea $hproj -Gwhite -O -K -Y-5c >> $1
    awk -F, '{if ($1>'$west' && $2>'$south' && $3>40 && $15==1) print $19}' $infile | grep -v NaN | \
    pshistogram $ararea $hproj -W0.1 -Ggray -L1,gray -O -K -Z1 \
    -Ba1f0.2/a5f1:,"-%":WeSn -X4.7c >> $1
}


mkgrids
mkcpts
plots
add_histograms $outfile
psxy -R -J -T -O >> $outfile
formats $outfile
#mv $outfile ./images/ps/
#mv ${outfile%.*}.png ./images/png/
