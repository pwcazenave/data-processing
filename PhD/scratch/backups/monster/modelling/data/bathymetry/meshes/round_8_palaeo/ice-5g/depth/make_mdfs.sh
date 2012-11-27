#!/bin/bash

# Script to create new mdfs from a base mdf file using a range of bathymetry
# data.

baseMDF=./bte0y-000_v5_peltier.mdf
bathyDir=../../../../raw_data/peltier/raw_data/0.5k/

for i in $bathyDir/*fixed_land.xyz; do 
    echo $i
    sed 's,ice5g_v1.2_00.0k_10min_altitude_-17_17_43_67_fixed_land.xyz,'"$(echo $i | awk -F\/ '{print $NF}')"',g' \
    $baseMDF \
    > ./bte0y-$(echo $i | cut -f5 -d_ | tr -d [A-Za-z])k_v5_peltier_test.mdf
done
