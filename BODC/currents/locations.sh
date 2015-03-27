#/bin/bash

# Get the locations for all the current meter data.

parallel grep -H \. {} \| sed \'4q\;d\' \| awk \'\{print \$1,\$2\}\' \| cut -f3- -d\/ ::: ????/raw_data/*.lst > locations.csv

# Post-process to get sensible positions (decimal degrees) and nicely formatted sites.
cut -c1-8,15-16,18-21,23,24-26,28-31,33 --output-delimiter=' ' locations.csv | \
    awk '{OFS=","}{if ($7 == W) print $1,$2+($3/60),0-($5+($6/60)); else print $1,$2+($3/60),$5+($6/60)}' | \
    sponge locations.csv
parallel grep -H \. {} \| awk '/Cruise/\{getline\;print\ substr\(\$1,15,8\),\$6,\$5\;\}' ::: ????/raw_data/*.txt | tr " " "," >> locations.csv

# Remove duplicates.
sort -u -k1 -t, locations.csv | sponge locations.csv

# Sanity check values.
awk -F, '{OFS=","}{if (NR > 1 && $2 > 30) print $0; else print $0}' locations.csv | sponge locations.csv

# Add the header.
echo "site,latDD,lonDD" > h.csv
cat h.csv locations.csv | sponge locations.csv
rm h.csv


