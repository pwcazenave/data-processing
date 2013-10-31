#!/bin/bash

# Format the additional 2012 data. This data uses a new format, hence a new script.

for i in new/2012*.csv; do
    if [ ! -f ./formatted/$(basename ${i%.*}).txt ]; then

        # Liverpool is a special case because it's name is "Liverpool,
        # Gladstone Dock, so the columns are off by one to account for the
        # comma in the name.
        if [ $i == "new/2012LIV.csv" ]; then
            awk -F, '{OFS=","}
            {
                if (NR > 2)
                    if ($14 = " ")
                        print $11,$13,"0","P";
                    else
                        print $11,$13,"0",$14
            }' $i | \
                tr ":/ " "," | \
                sed 's/,,/,/g' \
                > ./formatted/$(basename ${i%.*}).txt
        else
            awk -F, '{OFS=","}
            {
                if (NR > 2)
                    if ($13 = " ")
                        print $10,$12,"0","P";
                    else
                        print $10,$12,"0",$13
            }' $i | \
                tr ":/ " "," | \
                sed 's/,,/,/g' \
                > ./formatted/$(basename ${i%.*}).txt
        fi
    fi
done
