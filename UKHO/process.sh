#!/bin/bash

# Combine and process the raw bathymetry data from the UKHO.

# Grid resolution (metres).
res=${res:-15}

# Convert to UTM30N.
for i in raw/wgs84/[0-9]*.csv; do
    if [ ! -f raw/utm30n/$(basename ${i%.*}_utm30n.csv) ]; then
        echo "x,y,z" > raw/utm30n/$(basename ${i%.*}_utm30n.csv);
        awk -F, '{if (NR>1) print $2" "$1" "$3}' $i | \
            proj +proj=utm +ellps=WGS84 +zone=30 | \
            tr " 	" "," >> raw/utm30n/$(basename ${i%.*}_utm30n.csv)
    fi
done

files=(raw/utm30n/[0-9]*.csv raw/utm30n/[A-Za-z]*.csv)
#area=$(gmt gmtinfo -I10 -h1 ${files[@]})
area=-R320680/547810/5479050/5583970

# ASCII data.
echo "x,y,z" > combined/plymouth.csv
parallel grep -hv [A-Za-z] ::: ${files[@]} | tr " 	" "," >> combined/plymouth.csv

# Grids.
gmt blockmean $area -I${res} combined/plymouth.csv > combined/plymouth_${res}m.csv
gmt grdmask $area -I${res} -S200 -NNaN/1/1 combined/plymouth_${res}m.csv -Gnc/plymouth_${res}m_mask.nc

# No interpolation.
#gmt xyz2grd $area -I${res} combined/plymouth_${res}m.csv -Gnc/plymouth_${res}m.nc
#gmt grdreformat nc/plymouth_${res}m.nc tiffs/plymouth_${res}m.tiff=gd:gtiff

# Surface interpolation.
#gmt surface $area -I${res} -T0 combined/plymouth_${res}m.csv -Gnc/plymouth_${res}m_surface.nc
#gmt grdmath nc/plymouth_${res}m_surface.nc nc/plymouth_${res}m_mask.nc MUL = nc/plymouth_${res}m_masked.nc
#gmt grdreformat nc/plymouth_${res}m_masked.nc tiffs/plymouth_${res}m_masked.tiff=gd:gtiff

# Nearest neighbour interpolation.
gmt nearneighbor $area -I${res} -N4 -S200 combined/plymouth_${res}m.csv -Gnc/plymouth_${res}m_nearneighbor.nc
gmt grdmath nc/plymouth_${res}m_nearneighbor.nc nc/plymouth_${res}m_mask.nc MUL = nc/plymouth_${res}m_neighbormasked.nc
gmt grdreformat nc/plymouth_${res}m_neighbormasked.nc tiffs/plymouth_${res}m_neighbormasked.tiff=gd:gtiff
gmt grd2xyz -s nc/plymouth_${res}m_neighbormasked.nc > combined/plymouth_${res}m_neighbormasked.xyz
