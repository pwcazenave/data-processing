#!/bin/bash

# For the sites which passed the MATLAB script (ea_river_climatology.m)
# criteria, find the corresponding metadata and create a new metadata file.

mt=./metadata/metadata.csv
clim=./climatology/*.csv

head -n1 $mt > metadata/climatology_metadata.csv

for file in $clim; do
    id=$(basename "$file" .csv)

    grep -w ^$id $mt >> metadata/climatology_metadata.csv

done
