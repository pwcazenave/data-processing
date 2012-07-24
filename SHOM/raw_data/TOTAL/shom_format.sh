#!/bin/bash

# Take the SHOM raw data, cut out the appropriate columns. Keep single file per
# station to make loading to the SQL database easier. Add pass flag (P) so that
# the number of columns matches that in the NTSLF data. There's no QA on the
# SHOM data, so we're just assuming all data are P.

for i in *.slv; do
    cut -c1-4,6-7,9-10,12-13,15-16,18-19,20-27,28- --output-delimiter="," $i | \
        tr -d " " | awk -F, '{if (NF==7) print $0",-9999,P"; else print $0",P"}' > ../../formatted/$i
done
