#!/bin/csh -f

# script to plot all the bathy datasets for the solent sac survey

# set the areas to be constant so the grids are correct when subtracting one from the other

# set the areas
set bea_area=-R441588/445508/95932.6/98611.5
set chi_area=-R472189/483756/98493.4/105427
set ham_area=-R450346/456909/98856/103764
set iow_area=-R433351/456136/89692.7/97770.1
set lan_area=-R467575/471114/99657.7/105501

# make the cpt files
#makecpt -Cwysiwyg -T-11/2/1 -Z -V > bea.cpt
#makecpt -Cwysiwyg -T-17/2/1 -Z -V > chi.cpt
#makecpt -Cwysiwyg -T-13/2/1 -Z -V > ham.cpt
#makecpt -Cwysiwyg -T-56/2/1 -Z -V > iow.cpt
#makecpt -Cwysiwyg -T-17/2/1 -Z -V > lan.cpt

# beaulieu
# process the data
#emu
gmtset D_FORMAT %10.2lf
blockmean ./raw_data/emu/corrected_to_od/bea*.xyz -I5 $bea_area -V | surface -Gemu_beaulieu.surface.grd -V -I5 $bea_area -T0.2
grdmask ./raw_data/emu/corrected_to_od/bea*.xyz -Gemu_beaulieu.mask.grd -I5 $bea_area -N/NaN/1/1 -S50
grdmath emu_beaulieu.mask.grd emu_beaulieu.surface.grd MUL = emu_beaulieu.bathy.grd
gmtset D_FORMAT %lg
#cco
#gmtset D_FORMAT %10.2lf
#blockmean ./raw_data/cco/bea*.txt -I5 $bea_area -V | surface -Gcco_beaulieu.surface.grd -V -I5 $bea_area -T0.2
#grdmask ./raw_data/cco/bea*.txt -Gcco_beaulieu.mask.grd -I5 $bea_area -N/NaN/1/1 -S50
#grdmath cco_beaulieu.mask.grd cco_beaulieu.surface.grd MUL = cco_beaulieu.bathy.grd
#gmtset D_FORMAT %lg

# chichester
# process the data
#emu
gmtset D_FORMAT %10.2lf
blockmean ./raw_data/emu/corrected_to_od/chi*.xyz -I5 $chi_area -V | surface -Gemu_chichester.surface.grd -V -I5 $chi_area -T0.2
grdmask ./raw_data/emu/corrected_to_od/chi*.xyz -Gemu_chichester.mask.grd -I5 $chi_area -N/NaN/1/1 -S50
grdmath emu_chichester.mask.grd emu_chichester.surface.grd MUL = emu_chichester.bathy.grd
gmtset D_FORMAT %lg
#cco
#gmtset D_FORMAT %10.2lf
#blockmean ./raw_data/cco/chi*.txt -I5 $chi_area -V | surface -Gcco_chichester.surface.grd -V -I5 $chi_area -T0.2
#grdmask ./raw_data/cco/chi*.txt -Gcco_chichester.mask.grd -I5 $chi_area -N/NaN/1/1 -S50
#grdmath cco_chichester.mask.grd cco_chichester.surface.grd MUL = cco_chichester.bathy.grd
#gmtset D_FORMAT %lg

# hamble
# process the data
#emu
#gmtset D_FORMAT %10.2lf
#blockmean ./raw_data/emu/corrected_to_od/ham*.xyz -I5 $ham_area -V | surface -Gemu_hamble.surface.grd -V -I5 $ham_area -T0.2
#grdmask ./raw_data/emu/corrected_to_od/ham*.xyz -Gemu_hamble.mask.grd -I5 $ham_area -N/NaN/1/1 -S50
#grdmath emu_hamble.mask.grd emu_hamble.surface.grd MUL = emu_hamble.bathy.grd
#gmtset D_FORMAT %lg
#cco
#gmtset D_FORMAT %10.2lf
#grdmask ./raw_data/cco/ham*.txt -Gcco_hamble.mask.grd -I5 $ham_area -N/NaN/1/1 -S50
#grdmath cco_hamble.mask.grd cco_hamble.surface.grd MUL = cco_hamble.bathy.grd
#gmtset D_FORMAT %lg

# iow
# process the data
#emu
gmtset D_FORMAT %10.2lf
blockmean ./raw_data/emu/corrected_to_od/iow*.xyz -I5 $iow_area -V | surface -Gemu_iow.surface.grd -V -I5 $iow_area -T0.2
grdmask ./raw_data/emu/corrected_to_od/iow*.xyz -Gemu_iow.mask.grd -I5 $iow_area -N/NaN/1/1 -S50
grdmath emu_iow.mask.grd emu_iow.surface.grd MUL = emu_iow.bathy.grd
gmtset D_FORMAT %lg
#cco
#gmtset D_FORMAT %10.2lf
#blockmean ./raw_data/cco/iow*.txt -I5 $iow_area -V | surface -Gcco_iow.surface.grd -V -I5 $iow_area -T0.2
#grdmask ./raw_data/cco/iow*.txt -Gcco_iow.mask.grd -I5 $iow_area -N/NaN/1/1 -S50
#grdmath cco_iow.mask.grd cco_iow.surface.grd MUL = cco_iow.bathy.grd
#gmtset D_FORMAT %lg

# langstone
# process the data
#emu
gmtset D_FORMAT %10.2lf
blockmean ./raw_data/emu/corrected_to_od/lan*.xyz -I5 $lan_area -V | surface -Gemu_langstone.surface.grd -V -I5 $lan_area -T0.2
grdmask ./raw_data/emu/corrected_to_od/lan*.xyz -Gemu_langstone.mask.grd -I5 $lan_area -N/NaN/1/1 -S50
grdmath emu_langstone.mask.grd emu_langstone.surface.grd MUL = emu_langstone.bathy.grd
gmtset D_FORMAT %lg
#cco
#gmtset D_FORMAT %10.2lf
#blockmean ./raw_data/cco/lan*.txt -I5 $lan_area -V | surface -Gcco_langstone.surface.grd -V -I5 $lan_area -T0.2
#grdmask ./raw_data/cco/lan*.txt -Gcco_langstone.mask.grd -I5 $lan_area -N/NaN/1/1 -S50
#grdmath cco_langstone.mask.grd cco_langstone.surface.grd MUL = cco_langstone.bathy.grd
#gmtset D_FORMAT %lg

# perhaps a loop is in order

# cco stuff
#foreach cco_input(`ls ./raw_data/cco/*.txt`)

	# just in case, remove the old .gmt* files
#	\rm ./.gmt*

	# sort out a few of the basics
#	gmtset LABEL_FONT_SIZE 12p
#	gmtset HEADER_FONT_SIZE 16p
#	gmtset ANNOT_FONT_SIZE 10p
#	gmtset COLOR_NAN 0/0/0

	# sort out the i/o
#	set area=-R`minmax -C $cco_input | awk '{print $1"/"$2"/"$3"/"$4}'`
#	set proj=-Jx0.002
#	set outfile=$cco_input.ps

	# process the data
#	gmtset D_FORMAT %10.2lf
#	blockmean $cco_input -I5 $area -V | surface -G$cco_input.surface.grd -V -I5 $area -T0.2
#	grdmask $cco_input -G$cco_input.mask.grd -I5 $area -N/NaN/1/1 -S50
#	grdmath $cco_input.mask.grd $cco_input.surface.grd MUL = $cco_input.bathy.grd
#	gmtset D_FORMAT %lg

	# plot some figures
#	psbasemap $area $proj -Ba2000f1000:"Eastings":/a2000f1000:"Northings"::."Single Beam Bathymetry":WeSn -Xc -Yc -K > $outfile
#	grdimage $area $proj -Ccco.cpt $cco_input.bathy.grd -Bg1000 -O -K >> $outfile
#
#end

# emu stuff
#foreach emu_input(`ls ./raw_data/emu/corrected_to_od/*.xyz`)

	# just in case, remove the old .gmt* files
#	\rm ./.gmt*

	# sort out a few of the basics
#	gmtset LABEL_FONT_SIZE 12p
#	gmtset HEADER_FONT_SIZE 16p
#	gmtset ANNOT_FONT_SIZE 10p
#	gmtset COLOR_NAN 0/0/0

	# sort out the i/o
#	set area=-R`minmax -C $emu_input | awk '{print $1"/"$2"/"$3"/"$4}'`
#	set proj=-Jx0.002
#	set outfile=$emu_input.ps

	# process the data
#	gmtset D_FORMAT %10.2lf
#	blockmean $emu_input -I5 $area -V | surface -G$emu_input.surface.grd -V -I5 $area -T0.2
#	grdmask $emu_input -G$emu_input.mask.grd -I5 $area -N/NaN/1/1 -S50
#	grdmath $emu_input.mask.grd $emu_input.surface.grd MUL = $emu_input.bathy.grd
#	gmtset D_FORMAT %lg

	# plot some figures
#	psbasemap $area $proj -Ba2000f1000:"Eastings":/a2000f1000:"Northings"::."Single Beam Bathymetry":WeSn -Xc -Yc -K > $outfile
#	grdimage $area $proj -Ccco.cpt $emu_input.bathy.grd -Bg1000 -O -K >> $outfile

#end

# view the images
#kghostview ./images/*
