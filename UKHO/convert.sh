#!/bin/bash

# Convert the original UKHO data from spherical to UTM30N.

# Convert to UTM30N.
if [ ! -d ascii/utm30n ]; then
    mkdir -p ascii/utm30n
fi

parallel awk '\{print\ \$2,\ \$1,\ \$3\}' {} \| proj\ +proj=utm\ +ellps=WGS84\ +zone=30 \> ascii/utm30n/{/} ::: ascii/*.ascii
