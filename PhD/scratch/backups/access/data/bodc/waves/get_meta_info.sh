#!/bin/bash

# script to extract the metadata from the headers of the new wave data

sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' Report.htm | \
   grep -A150 Information\ for | \
   tr "°" " " | \
   tr "\n" "\t" | \
   sed 's/--/\
/g' \
   >! extracted_report.txt

# then edit the columns in a spreadsheet as necessary.
