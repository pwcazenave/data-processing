#!/bin/bash

# Assuming a straight boundary between meshes to be merged, this script
# will extract the points along the boundary to be merged. Specify whether
# it's the northern (0), southern (1), western (2) or eastern boundary (3).

mesh=${mesh:-./uniform_v1_ne.mesh}
boundary=${boundary:-2}
outfile=${outfile:-boundary.xyz}

printf "Using mesh: %s " $(basename $mesh)

case $boundary in
    0)
        # Actual column to extract is 4
        colEx=4
        printf "and the %s boundary.\n" 'northern'
        ;;
    1)
        colEx=3
        printf "and the %s boundary.\n" 'southern'
        ;;
    2)
        colEx=1
        printf "and the %s boundary.\n" 'western'
        ;;
    3)
        colEx=2
        printf "and the %s boundary.\n" 'eastern'
        ;;
    *)
        echo "Check specified merge boundary value."
        exit 1
        ;;
esac

# Find the boundary points. 
# MIKE stores values as 12 point decimals in this mesh file
# (uniform_v1_ne.mesh), hence %.12f.
bval=$(awk '{if (NF==5) print $2,$3,$4}' $mesh | minmax -C --D_FORMAT=%.12f | cut -f$colEx)

printf "Minimum value: %.12f\n" $bval

# Extract the points along the common boundary
awk '{if (NF==5 && $2=='$bval') print $2,$3,$4}' $mesh | sort -k2 > ${outfile}
