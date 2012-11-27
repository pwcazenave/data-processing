#!/bin/bash

# We need an identical grain size mesh file for each of the palaeobathymetry
# time slices.

baseFile=./bte0y-00.0k_v4_peltier_test_seds.dfsu

for i in $(seq -f 0%2.1f 0.5 0.5 8); do
    cp $baseFile ${baseFile/00\.0/$i}
done
