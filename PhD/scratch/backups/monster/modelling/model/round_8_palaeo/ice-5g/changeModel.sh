#!/bin/bash

# Change the mesh and output files for a set of input files. Supply new mesh as
# single argument ($1).

set -eu

if [ "${#}" -ne 1 ]; then
    echo "Error: supply only a mesh name as argument."
    exit 1
fi

templateModel=./template-hydro.m21fm

for i in ./M*; do

    echo -n "Working on $i... "
    # New output file prefix for the results
    newout=$(echo "$i" | sed 's/gebco_v8/'"${1%.mesh}"'/g')
    if [ ! -f "$newout" ]; then
        cp "$template" "$newout"
    else
        echo "Output file already exists. Quitting."
        exit 1
    fi

    # Change the mesh (line 11)
    sed -i '11s/TAKEMEOUTMESH/'"$1"'/g' "$newout"
    # The results files (lines 1528 and 1641)
    sed -i '1528s/TAKEMEOUTPREFIX/'"${1%.mesh}"'/g' "$newout"
    sed -i '1641s/TAKEMEOUTPREFIX/'"${1%.mesh}"'/g' "$newout"

    echo "done."
done


