#!/bin/bash

# Strip headers and dump only the xyz data.

for file in raw_data/*.lst; do
    echo "lonDD latDD z" > formatted/$(basename ${file%.*}).txt
    sed '1,/Number/d' $file | grep -v [A-Z] | \
        awk '{print $5,$4,$NF}' >> formatted/$(basename ${file%.*}).txt
done
