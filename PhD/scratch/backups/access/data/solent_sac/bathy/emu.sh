#!/bin/csh -f

# script to plot the emu data and create a series of pdfs. nothing fancy here please.

# set the areas
set bea_area=-R438723/446578/95312/100350
set chi_area=-R473568/481998/97960/104394
set ham_area=-R448364/449483/104533/109092
set hay_area=-R469117/476342/95928/98801
set iow_area=-R434190/454120/87449/97010
set lan_area=-R467713/470743/97948/103877

# set the decimal points:
gmtset D_FORMAT %10.2lf

# process the raw data

# beaulieu
#blockmean ./raw_data/emu/original/bea*.xyz -I5 $bea_area -V | surface -Gemu_beaulieu.surface.grd -V -I5 $bea_area -T0.2
#grdmask ./raw_data/emu/original/bea*.xyz -Gemu_beaulieu.mask.grd -I5 $bea_area -N/NaN/1/1 -S50
#grdmath emu_beaulieu.mask.grd emu_beaulieu.surface.grd MUL = emu_beaulieu.bathy.grd

# chichester
#blockmean ./raw_data/emu/original/chi*.xyz -I5 $chi_area -V | surface -Gemu_chichester.surface.grd -V -I5 $chi_area -T0.2
#grdmask ./raw_data/emu/original/chi*.xyz -Gemu_chichester.mask.grd -I5 $chi_area -N/NaN/1/1 -S50
#grdmath emu_chichester.mask.grd emu_chichester.surface.grd MUL = emu_chichester.bathy.grd

# hamble
#blockmean ./raw_data/emu/original/ham*.xyz -I5 $ham_area -V | surface -Gemu_hamble.surface.grd -V -I5 $ham_area -T0.2
#grdmask ./raw_data/emu/original/ham*.xyz -Gemu_hamble.mask.grd -I5 $ham_area -N/NaN/1/1 -S50
#grdmath emu_hamble.mask.grd emu_hamble.surface.grd MUL = emu_hamble.bathy.grd

# hayling island
#blockmean ./raw_data/emu/original/hay*.xyz -I5 $hay_area -V | surface -Gemu_hayling.surface.grd -V -I5 $hay_area -T0.2
#grdmask ./raw_data/emu/original/hay*.xyz -Gemu_hayling.mask.grd -I5 $hay_area -N/NaN/1/1 -S100
#grdmath emu_hayling.mask.grd emu_hayling.surface.grd MUL = emu_hayling.bathy.grd

# iow
#blockmean ./raw_data/emu/original/iow*.xyz -I5 $iow_area -V | surface -Gemu_iow.surface.grd -V -I5 $iow_area -T0.2
#grdmask ./raw_data/emu/original/iow*.xyz -Gemu_iow.mask.grd -I5 $iow_area -N/NaN/1/1 -S50
#grdmath emu_iow.mask.grd emu_iow.surface.grd MUL = emu_iow.bathy.grd

# langstone
#blockmean ./raw_data/emu/original/lan*.xyz -I5 $lan_area -V | surface -Gemu_langstone.surface.grd -V -I5 $lan_area -T0.2
#grdmask ./raw_data/emu/original/lan*.xyz -Gemu_langstone.mask.grd -I5 $lan_area -N/NaN/1/1 -S50
#grdmath emu_langstone.mask.grd emu_langstone.surface.grd MUL = emu_langstone.bathy.grd

# unset the decimal points
gmtset D_FORMAT %lg

# set the projections
set bea_proj=-Jx0.003
set chi_proj=-Jx0.0025
set ham_proj=-Jx0.005
set hay_proj=-Jx0.003
set iow_proj=-Jx0.0012
set lan_proj=-Jx0.004

# make the colour palettes
makecpt -Cwysiwyg -Z -T-10/2/0.1 > .e_bea.cpt
#makecpt -Cwysiwyg -Z -T-20/2/0.1 > .e_chi.cpt
#makecpt -Cwysiwyg -Z -T-7/1/0.1 > .e_ham.cpt
#makecpt -Cwysiwyg -Z -T-10/2/0.1 > .e_hay.cpt
makecpt -Cwysiwyg -Z -T-30/2/0.1 > .e_iow.cpt
#makecpt -Cwysiwyg -Z -T-15/2/0.1 > .e_lan.cpt

# plot the images

# beaulieu
grdimage $bea_area -C.e_bea.cpt $bea_proj emu_beaulieu.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."Beaulieu Bathymetry":WeSn -Xc -Yc -K > ./images/emu_bea.ps
# chichester
grdimage $chi_area -C.e_chi.cpt $chi_proj emu_chichester.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."Chichester Harbour Bathymetry":WeSn -Xc -Yc -K > ./images/emu_chi.ps
# hamble
grdimage $ham_area -C.e_ham.cpt $ham_proj emu_hamble.bathy.grd -Ba500g500:"Eastings":/a500g500:"Northings"::."Hamble River Bathymetry":WeSn -Xc -Yc -K -P > ./images/emu_ham.ps
# hayling
grdimage $hay_area -C.e_hay.cpt $hay_proj emu_hayling.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."Hayling Island Bathymetry":WeSn -Xc -Yc -K > ./images/emu_hay.ps
# iow
grdimage $iow_area -C.e_iow.cpt $iow_proj emu_iow.bathy.grd -Ba2000g2000:"Eastings":/a2000g2000:"Northings"::."Isle of Wight Bathymetry":WeSn -Xc -Yc -K > ./images/emu_iow.ps
# langstone
grdimage $lan_area -C.e_lan.cpt $lan_proj emu_langstone.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."Langstone Harbour Bathymetry":WeSn -Xc -Yc -K -P > ./images/emu_lan.ps

# add scales
psscale -D24.2/6.5/5/0.5 -B2 -C.e_bea.cpt -O -K >> ./images/emu_bea.ps
psscale -D22.9/7.3/5/0.5 -B5 -C.e_chi.cpt -O -K >> ./images/emu_chi.ps
psscale -D7/12/5/0.5 -B1 -C.e_ham.cpt -O -K >> ./images/emu_ham.ps
psscale -D23/4.7/5/0.5 -B2 -C.e_hay.cpt -O -K >> ./images/emu_hay.ps
psscale -D24.3/5.2/5/0.5 -B5 -C.e_iow.cpt -O -K >> ./images/emu_iow.ps
psscale -D13/12/5/0.5 -B2 -C.e_lan.cpt -O -K >> ./images/emu_lan.ps

# convert the postscripts to pdfs
#ps2pdf ./images/emu_*

