#!/bin/bash

# Remove the BODC headers from the data

parallel sed '0,/^Number/d' "{}" \| awk \'\{print \$1,\$2,\$3,\$4,\$5\}\' \> formatted/"{/}" ::: raw_data/*.lst
parallel sed '0,/^Cruise/d' "{}" \| tail -n +2 \| awk \'\{print \$1,\$3,\$5,\$7\}\' \> formatted/"{/}" ::: raw_data/*.txt
