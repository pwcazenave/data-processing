#!/bin/bash

# Script to merge the various palaeomodels magnitude and direction into a single file with a column per palaeomodel (e.g. 0ka, 0.5 ka etc.).

awk -F, '{printf "%.6f,%.6f\n", $1,$2}' depth_bte0y-00.0k_v5_peltier_HMvar_SM32_d50_var_decoupling_transport_area_residual_bed.csv > /tmp/collated_dir.txt
awk -F, '{printf "%.6f,%.6f\n", $1,$2}' depth_bte0y-00.0k_v5_peltier_HMvar_SM32_d50_var_decoupling_transport_area_residual_bed.csv > /tmp/collated_mag.txt

for i in *v5*residual_bed*.csv; do 
    awk -F, '{printf "%.2f\n", $3}' $i > /tmp/dir.txt
    awk -F, '{printf "%.20f\n", $4}' $i > /tmp/mag.txt
    paste -d "," /tmp/collated_dir.txt /tmp/dir.txt > /tmp/collated_dir.txt2
    paste -d "," /tmp/collated_mag.txt /tmp/mag.txt > /tmp/collated_mag.txt2
    mv /tmp/collated_dir.txt2 /tmp/collated_dir.txt
    mv /tmp/collated_mag.txt2 /tmp/collated_mag.txt
done

mv /tmp/collated_dir.txt ./palaeo_residual_direction_0-10.5k.csv
mv /tmp/collated_mag.txt ./palaeo_residual_0-10.5k.csv
