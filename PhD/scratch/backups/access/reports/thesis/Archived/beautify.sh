#!/bin/bash

# Script to rather hackishly fix a number of formatting
# inconsistencies. We're going for consistency across the entire
# thesis here...

# Fixes:
#   - en dashes and the surrounding spaces:
#       "test -- test" becomes "test--test"
#   - side scan becomes sidescan
#   - figure captions use A., not A).
#   - captions all end with a fullstop.
#   - use seabed, not sea bed.
#   - similarly, sealevel, not sea-level or sea level.
#   - anything palaeo is not hyphenated.

for file in "$@"; do
    # Text based things (en dashes etc.)
    sed -i \
        's/\ --\ /--/g;
        s/side\ scan/sidescan/g;
        s/sea\ bed/seabed/g;
        s/sea\ level/sealevel/g;
        s/palaeo-/palaeo/g;' \
        $file
    # Make sure captions have both long and short versions
    sed -i 's/caption{/caption\[\]{/g' $file
    # Fix figure caption fullstops
    sed -i \
        '/caption\[.*[a-z]}$/s/}$/\.}/g' \
        $file
    # Fix figure caption subfigure references. Do this the easy way.
    sed -i \
        '/caption\[/s/\ A)/\ A\./g;
        /caption\[/s/\ B)/\ B\./g;
        /caption\[/s/\ C)/\ C\./g;
        /caption\[/s/\ D)/\ D\./g;
        /caption\[/s/\ E)/\ E\./g;
        /caption\[/s/\ F)/\ F\./g;
        /caption\[/s/\ G)/\ G\./g;
        /caption\[/s/\ H)/\ H\./g;
        /caption\[/s/\ I)/\ I\./g;
        /caption\[/s/\ J)/\ J\./g;
        ' \
        $file
    # Remove semi-colons from figure captions as separators between
    # subfigure references.
    sed -i \
        '/caption\[/s/;\ A./\.\ A\./g;
        /caption\[/s/;\ B\./\.\ B\./g;
        /caption\[/s/;\ C\./\.\ C\./g;
        /caption\[/s/;\ D\./\.\ D\./g;
        /caption\[/s/;\ E\./\.\ E\./g;
        /caption\[/s/;\ F\./\.\ F\./g;
        /caption\[/s/;\ G\./\.\ G\./g;
        /caption\[/s/;\ H\./\.\ H\./g;
        /caption\[/s/;\ I\./\.\ I\./g;
        /caption\[/s/;\ J\./\.\ J\./g;
        ' \
        $file
done


