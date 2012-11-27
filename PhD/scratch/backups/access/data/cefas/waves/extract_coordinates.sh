#!/bin/bash

# Quick hack to extract the coordinates and names from the kml file.

# 1. Find relevant tages
# 2. Get rid of tabs (might be a bad idea because then word separators become columns
# 3. Join every third line
# 4. Chop off the first two lines
# 5. Remove XML tags
# 6. Remove duplicate whitespace
# 7. Reverse the line
# 8. Reorder the columns
# 9. Re-reverse the line
# 10. Output to file

grep -E "longitude|latitude|name" WaveNetlocationsicons.kml | \
    tr "\t" " " | \
    awk 'ORS=NR%3?" ":RS' | \
    awk '{if (NR>2) print $0}' | \
    sed 's/<longitude>//g;s/<\/longitude>//g;s/<latitude>//g;s/<\/latitude>//g;s/<name>//g;s/<\/name>//g' | \
    sed 's/[\ ]\+/\ /g;s/^\ //g' | \
    rev | \
    awk '{printf "%s %s %s %s %s %s %s %s %s %s %s\n", $3,$4,$5,$6,$7,$8,$9,$10,$11,$1,$2}' | \
    rev \
    > WaveNetlocationsicons.xyz

