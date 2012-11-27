#!/bin/bash

# We need an identical wavelength and height mesh file for each of the 
# palaeobathymetry time slices.

baseFileW=./bte0y-00.0k_v5_peltier_bedforms_wavelength.dfsu
baseFileH=./bte0y-00.0k_v5_peltier_bedforms_height.dfsu

for i in $(seq -f 0%2.1f 0.5 0.5 8); do
    cp $baseFileW ${baseFileW/00\.0/$i}
    cp $baseFileH ${baseFileH/00\.0/$i}
done
