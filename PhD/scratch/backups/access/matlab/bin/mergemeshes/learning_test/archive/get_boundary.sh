#!/bin/bash

# Assuming a straight boundary between meshes to be merged, this script
# will extract the points along the boundary to be merged. Specify whether
# it's the northern (0), southern (1), western (2) or eastern boundary (3).

mesh=${mesh:-./west_test.mesh}
boundary=${boundary:-3}

echo $mesh

case $boundary in
    0)
        # Actual column to extract is 4
        colEx=4
        printf "Using %s boundary.\n" 'northern'
        ;;
    1)
        colEx=3
        printf "Using %s boundary.\n" 'southern'
        ;;
    2)
        colEx=1
        printf "Using %s boundary.\n" 'western'
        ;;
    3)
        colEx=2
        printf "Using %s boundary.\n" 'eastern'
        ;;
    *)
        echo "Check specified merge boundary value."
        exit 1
        ;;
esac

# Find the boundary points. MIKE stores values as 16 point decimals, 
# hence %.16f.
set -x
bval=$(awk '{if (NF==5) print $2,$3,$4}' $mesh | minmax -C --D_FORMAT=%.16f | cut -f$colEx)

# Extract the points along the common boundary
awk '{if (NF==5 && $2=='$bval') print $2,$3,$4}' $mesh | sort -k2 > boundary.xyz
