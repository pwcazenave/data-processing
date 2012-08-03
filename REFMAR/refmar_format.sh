#!/bin/bash

# Take the SHOM raw data, cut out the appropriate columns. Keep single file per
# station to make loading to the SQL database easier. Add pass flag (P) so that
# the number of columns matches that in the NTSLF data. There's no QA on the
# SHOM data, so we're just assuming all data are P.

for i in raw_data/*.txt; do
    sed '1,8d' $i | \
        tr "/:; " "," | \
        awk -F"," '{OFS=","}{print $3,$2,$1,$4,$5,$6,$7,"-9999,P"}' > ./formatted/$(basename $i)
done
