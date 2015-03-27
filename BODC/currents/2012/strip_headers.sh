#!/bin/bash

# Remove the BODC headers from the data

for file in raw_data/*.lst; do
    sed '0,/^\ Number/d' $file > ./formatted/$(basename $file)
done
