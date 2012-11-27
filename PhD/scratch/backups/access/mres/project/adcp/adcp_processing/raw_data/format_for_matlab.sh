#!/bin/bash

# Format the raw data files for sites 1 and 2 as:
# yyyy mm dd hh mm ss dir mag

sites=(
   ./090206/Moored\ Instrumentation/Site\ 2/ADCP/Time-Series/Depth_Av/Site2_Depth_Av_Data.txt 
   ./090206/Moored\ Instrumentation/Site\ 3/ADCP/Time-Series/Depth_Av/Site3_Depth_Av_Data.txt
   )

for ((i=0; i<"${#sites[@]}"; i++)); do
   awk 'BEGIN {FS = "[/ :\t ]";} {OFS=","} {if (NR>1) print $3,$2,$1,$4,$5,$6,$15,$14}' "${sites[$i]}" > "../processed/28_$(($i+1)).csv"
done
