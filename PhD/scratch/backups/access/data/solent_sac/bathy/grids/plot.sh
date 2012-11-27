#!/bin/csh -f

# testing the cco and the emu stuff to get a difference grid

# set those gmtdefaults

gmtset HEADER_OFFSET=0.1c

# first, apply the cco mask to the emu stuff, and then vice versa.
grdmath ./cco/cco_beaulieu.bathy.grd ./emu/emu_beaulieu.mask.grd MUL = cco_beaulieu.grd
grdmath ./emu/emu_beaulieu.bathy.grd ./cco/cco_beaulieu.mask.grd MUL = emu_beaulieu.grd

grdmath ./cco/cco_chichester.bathy.grd ./emu/emu_chichester.mask.grd MUL = cco_chichester.grd
grdmath ./emu/emu_chichester.bathy.grd ./cco/cco_chichester.mask.grd MUL = emu_chichester.grd

grdmath ./cco/cco_iow.bathy.grd ./emu/emu_iow.mask.grd MUL = cco_iow.grd
grdmath ./emu/emu_iow.bathy.grd ./cco/cco_iow.mask.grd MUL = emu_iow.grd

grdmath ./cco/cco_langstone.bathy.grd ./emu/emu_langstone.mask.grd MUL = cco_langstone.grd
grdmath ./emu/emu_langstone.bathy.grd ./cco/cco_langstone.mask.grd MUL = emu_langstone.grd

# second, subtract the cco grid from the emu grid
grdmath emu_beaulieu.grd cco_beaulieu.grd SUB = final_beaulieu.grd
grdmath emu_chichester.grd cco_chichester.grd SUB = final_chichester.grd
grdmath emu_iow.grd cco_iow.grd SUB = final_iow.grd
grdmath emu_langstone.grd cco_langstone.grd SUB = final_langstone.grd

# remove some unecessary files
\rm emu_*.grd cco_*.grd

# make the colour palette tables
#diff
makecpt -Cwysiwyg -Z -T-1/1/0.5 > .d_bea.cpt
makecpt -Cwysiwyg -Z -T-1/1/0.5 > .d_chi.cpt
makecpt -Cwysiwyg -Z -T-1/1/0.5 > .d_iow.cpt
makecpt -Cwysiwyg -Z -T-1/1/0.5 > .d_lan.cpt
#cco
makecpt -Cwysiwyg -Z -T-10/2/0.5 > .c_bea.cpt
makecpt -Cwysiwyg -Z -T-17/2/0.5 > .c_chi.cpt
makecpt -Cwysiwyg -Z -T-56/8/0.5 > .c_iow.cpt
makecpt -Cwysiwyg -Z -T-17/2/0.5 > .c_lan.cpt
#emu
makecpt -Cwysiwyg -Z -T-31/11/0.5 > .e_bea.cpt
makecpt -Cwysiwyg -Z -T-15/4/0.5 > .e_chi.cpt
makecpt -Cwysiwyg -Z -T-67/30/0.5 > .e_iow.cpt
makecpt -Cwysiwyg -Z -T-12/5/0.5 > .e_lan.cpt

# plot the images

#areas
set bea_area=-R441588/445508/95932/98612
set chi_area=-R472189/483756/98493.4/105427
set iow_area=-R433351/456136/89692.7/97770.1
set lan_area=-R467575/471114/99657.7/105501

#projs
set bea_proj=-Jx0.0022
set chi_proj=-Jx0.0009
set iow_proj=-Jx0.0007
set lan_proj=-Jx0.0013

# original grids
# cco
grdimage $bea_area -C.c_bea.cpt $bea_proj ./cco/cco_beaulieu.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."C.C.O. Bathymetry":WeSn -Xc -Y22 -K -P > bea.ps
grdimage $chi_area -C.c_chi.cpt $chi_proj ./cco/cco_chichester.bathy.grd -Ba2000g2000:"Eastings":/a2000g2000:"Northings"::."C.C.O. Bathymetry":WeSn -Xc -Y21 -K -P > chi.ps
grdimage $iow_area -C.c_iow.cpt $iow_proj ./cco/cco_iow.bathy.grd -Ba2000g2000:"Eastings":/a2000g2000:"Northings"::."C.C.O. Bathy":WeSn -Xc -Y22 -K -P > iow.ps
grdimage $lan_area -C.c_lan.cpt $lan_proj ./cco/cco_langstone.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."C.C.O. Bathymetry":WeSn -Yc -K > lan.ps
# emu
grdimage $bea_area -C.e_bea.cpt $bea_proj ./emu/emu_beaulieu.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."E.M.U. Bathymetry":WeSn -Y-10 -O -K -P >> bea.ps
grdimage $chi_area -C.e_chi.cpt $chi_proj ./emu/emu_chichester.bathy.grd -Ba2000g2000:"Eastings":/a2000g2000:"Northings"::."E.M.U. Bathymetry":WeSn -Y-9.5 -O -K -P >> chi.ps
grdimage $iow_area -C.e_iow.cpt $iow_proj ./emu/emu_iow.bathy.grd -Ba2000g2000:"Eastings":/a2000g2000:"Northings"::."E.M.U. Bathymetry":WeSn -Y-10 -O -K -P >> iow.ps
grdimage $lan_area -C.e_lan.cpt $lan_proj ./emu/emu_langstone.bathy.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."E.M.U. Bathymetry":WeSn -X9.5 -O -K >> lan.ps

# difference grids
grdimage $bea_area -C.d_bea.cpt $bea_proj final_beaulieu.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."Difference":WeSn -Y-10 -O -K -P >> bea.ps
grdimage $chi_area -C.d_chi.cpt $chi_proj final_chichester.grd -Ba2000g2000:"Eastings":/a2000g2000:"Northings"::."Difference":WeSn -Y-9.5 -O -K -P >> chi.ps
grdimage $iow_area -C.d_iow.cpt $iow_proj final_iow.grd -Ba2000g2000:"Eastings":/a2000g2000:"Northings"::."Difference":WeSn -Y-10 -O -K -P >> iow.ps
grdimage $lan_area -C.d_lan.cpt $lan_proj final_langstone.grd -Ba1000g1000:"Eastings":/a1000g1000:"Northings"::."Difference":WeSn -X10 -O -K >> lan.ps

# add a scale
#diff
psscale -D11/3.2/5/0.5 -B5 -C.d_bea.cpt -O -K >> bea.ps
psscale -D12/2.5/5/0.5 -B5 -C.d_chi.cpt -O -K >> chi.ps
psscale -D16.5/2.9/5/0.5 -B5 -C.d_iow.cpt -O -K >> iow.ps
psscale -D-13.4/4/5/0.5 -B5 -C.d_lan.cpt -O -K >> lan.ps

# cco
psscale -D11/13.2/5/0.5 -B5 -C.c_bea.cpt -O -K >> bea.ps
psscale -D12/12/5/0.5 -B5 -C.c_chi.cpt -O -K >> chi.ps
psscale -D16.5/12.9/5/0.5 -B5 -C.c_iow.cpt -O -K >> iow.ps
psscale -D-3.9/4/5/0.5 -B5 -C.c_lan.cpt -O -K >> lan.ps

# emu
psscale -D11/23.2/5/0.5 -B5 -C.e_bea.cpt -O -K >> bea.ps
psscale -D12/22.5/5/0.5 -B5 -C.e_chi.cpt -O -K >> chi.ps
psscale -D16.5/22.9/5/0.5 -B5 -C.e_iow.cpt -O -K >> iow.ps
psscale -D6/4/5/0.5 -B5 -C.e_lan.cpt -O -K >> lan.ps

# display the image
#gs -sPAPERSIZE=a4 bea.ps
#gs -sPAPERSIZE=a4 chi.ps
#gs -sPAPERSIZE=a4 iow.ps
#gs -sPAPERSIZE=a4 lan.ps

