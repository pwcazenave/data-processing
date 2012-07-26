#!/bin/bash

# Do the analysis of a year's data from Avonmouth to compare against the
# results from T_TIDE.

tappy.py analysis \
    --def_filename=/users/modellers/pica/Work/data/proc/tides/sparse.def \
    --outputxml=AVO2.xml \
    --quiet ./raw_data/AVO2.txt

cat AVO2.xml
