#!/bin/bash

# This should supersede mk_combo.sh and mk_new_combo.sh.

# Uses grdmath to create a grid at two resolutions. Principally the
# continental shelf will be high resolution whereas the continental
# slopes will be coarser because they'll be mostly filled with GEBCO
# data. I'm still using the old GEBCO data as the new data causes
# the model to blow up much too easily.
#
# In order of decreasing quality, the data are as follows:
#       Tarbat Ness
#       Wee Bankie
#       Cornish
#       SeaZone
#       BritNed
#       Irish Sea
#       CMAP
#       GEBCO

set -eu

proj=-Jm0.5
today=$(date "+%Y-%m-%d")

infiles=(../cmap/raw_data/corrected_CMAP_bathy.xyz ../gebco/gridone/Grid/gridone_palaeo_area.xyz ../britned/raw_data/britned_bathy_wgs84.txt ../seazone/Bathy/seazone_msl.xyz ../bodc/random_bathy/raw_data/1kmdep.xyz ../ukho/bathy/tarbat_ness_sarclet_head/processed/raw_data/tarbatNess-SarcletHead_20m_latlong.xyz /media/g/data/ukho/bathy/wee_bankie_gourdon/processed/raw_data/weeBankie-Gourdon_utm_20m_latlong.xyz /media/g/data/mca/hi1059/raw_data/hi1059_b_ll.xyz)

# fine parameters
#farea=$(minmax -I0.001 ${infiles[0]} ${infiles[2]} ${infiles[3]} ${infiles[4]}) # everything bar the GEBCO data
farea=-R-9.99/4.83/48.50/56.00 # result of the above to save time (excludes Scottish data)
fgres=100e
foutfiles=(./grids/quick/cmap_${fgres}.grd ./grids/quick/gebco_${fgres}.grd ./grids/quick/britned_${fgres}.grd ./grids/quick/seazone_${fgres}.grd ./grids/quick/irish_sea_${fgres}.grd ./grids/quick/tnsh_${fgres}.grd ./grids/quick/wbg_${fgres}.grd ./grids/quick/cornwall_${fgres}.grd)

# coarse parameters
carea=-R-17/17/43/67 # GEBCO domain
cgres=2500e
coutfiles=(./grids/quick/cmap_${cgres}.grd ./grids/quick/gebco_${cgres}.grd ./grids/quick/britned_${cgres}.grd ./grids/quick/seazone_${cgres}.grd ./grids/quick/irish_sea_${cgres}.grd ./grids/quick/tnsh_${cgres}.grd ./grids/quick/wbg_${cgres}.grd ./grids/quick/cornwall_${cgres}.grd)

mkrawgrd(){
    # Create grids from the arguments supplied
    gres=$1
    area=$2
    # The array of filenames is a little more complicated
    declare -a files=("${!3}")
    declare -a outfiles=("${!4}")

    for ((i=0; i<${#files[@]}; i++)) do
        if [ ! -e ${outfiles[i]} ]; then
            # xyz2grd creates weird patterns.
            #xyz2grd $area -I$gres ${files[i]} -G${outfiles[i]} || true # so we don't exit with no data in grid (i.e. UKHO data sets).

            # Replaced with surface+grdmask+grdmath approach.
            surface $area -I$gres ${files[i]} -G${outfiles[i]%.grd}_surface.grd -V || continue # so we don't exit with no data in grid (i.e. UKHO data sets).
            grdmask $area -I$gres ${files[i]} -G${outfiles[i]%.grd}_mask.grd -V -NNaN/1/1 -S5k
            grdmath ${outfiles[i]%.grd}_surface.grd ${outfiles[i]%.grd}_mask.grd MUL = ${outfiles[i]}
        fi
    done
}

mkbestgrd(){
    # grdmath's AND operator will take two grids and use data from one
    # in preference over the other. With this, I should be able to build
    # up a better and better grid until only the best data occupy each part
    # of the grid.

    # Create the best grid from the arguments supplied
    gres=$1
    # The array of filenames is a little more complicated
    declare -a files=("${!2}")

    processOrder=(1 0 4 2 3 7 5 6)
    inc=0;
    for ((i=0; i<${#processOrder[@]}; i++)) do
        if [ $i -eq 0 ]; then
            grdmath ${files[1]} ${files[0]} AND = ./grids/quick/tmp$inc.grd
            inc=$(($inc+1))
        elif [ $i -lt ${#processOrder[@]} ]; then
            grdmath ./grids/quick/tmp$(($i-1)).grd ${files[${processOrder[i]}]} AND = ./grids/quick/tmp$inc.grd
            inc=$(($inc+1))
        else
            grdmath ./grids/quick/tmp$(($i-1)).grd ${files[${processOrder[i]}]} AND = ./grids/quick/combo_${gres}.grd
        fi
    done
#    # GEBCO and CMAP
#    grdmath ${files[1]} ${files[0]} AND = ./grids/quick/tmp1.grd
#    # Previous step and Irish Sea
#    grdmath ./grids/quick/tmp1.grd ${files[4]} AND = ./grids/quick/tmp2.grd
#    # Previous step and BritNed
#    grdmath ./grids/quick/tmp2.grd ${files[2]} AND = ./grids/quick/tmp3.grd
#    # Previous step and SeaZone
#    grdmath ./grids/quick/tmp3.grd ${files[3]} AND = ./grids/quick/tmp4.grd
#    # Previous step and Cornwall
#    grdmath ./grids/quick/tmp4.grd ${files[7]} AND = ./grids/quick/tmp5.grd
#    # Previous step and TarbatNess
#    grdmath ./grids/quick/tmp5.grd ${files[5]} AND = ./grids/quick/tmp6.grd
#    # Previous step and WeeBankie
#    grdmath ./grids/quick/tmp6.grd ${files[6]} AND = ./grids/quick/combo_${gres}.grd
    \rm -f ./grids/quick/tmp?.grd
}

plot(){
    # Plot the grid from the arguments supplied
    area=$1
    gres=$2
    minz=$3
    maxz=$4

    # Plot the relevant combo grid
    makecpt -T$minz/$maxz/10 -Z > ./cpts/shelf.cpt
    psbasemap $area $proj -Xc -Yc -Ba10f5WeSn -K -P > ./images/${gres}_combo.ps
    grdimage $area $proj -C./cpts/shelf.cpt ./grids/quick/combo_${gres}.grd -O \
        >> ./images/${gres}_combo.ps
    formats ./images/${gres}_combo.ps
}

exportxyz(){
    # Export everything below 1 metre altitude
    grd2xyz -S $1 | awk '{if ($3<1) print $0}' > $2
}

mkrawgrd $fgres $farea infiles[@] foutfiles[@]
#mkrawgrd $cgres $carea infiles[@] coutfiles[@]
mkbestgrd $fgres foutfiles[@]
#mkbestgrd $cgres coutfiles[@]
#exportxyz ./grids/quick/combo_${fgres}.grd ../../modelling/data/bathymetry/raw_data/combo_grid/${today}_combo_${fgres}.xyz
#exportxyz ./grids/quick/combo_${cgres}.grd ../../modelling/data/bathymetry/raw_data/combo_grid/${today}_combo_${cgres}.xyz
#awk '{if ($1<=-9.99 || $1>=4.83 || $2<=48.50 || $2>=56.00) print $0}' \
#    ../../modelling/data/bathymetry/raw_data/combo_grid/${today}_combo_${cgres}.xyz \
#    > ../../modelling/data/bathymetry/raw_data/combo_grid/${today}_combo_${cgres}_excluded.xyz
# Exclude the DORIS area. We'll use better bathy there
#awk '{if ($1<=-2.5 || $1>=-1.9 || $2<=50.3 || $2>=50.65) print $0}' \
#    ../../modelling/data/bathymetry/raw_data/combo_grid/${today}_combo_${fgres}.xyz \
#    > ../../modelling/data/bathymetry/raw_data/combo_grid/${today}_combo_${fgres}_doris_excluded.xyz
plot $carea $cgres -100 0
plot $carea $fgres -50 0
