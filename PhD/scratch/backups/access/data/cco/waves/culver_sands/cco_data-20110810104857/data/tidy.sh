#!/bin/bash

# Script to quickly tidy the wave data to a more useable
# format

for i in waves/*.txt
    do awk '!/9999/ {if (NR>1) print $1,$2,$6,$8,$10}' $i \
        > ./formatted/$(basename $i)
done

