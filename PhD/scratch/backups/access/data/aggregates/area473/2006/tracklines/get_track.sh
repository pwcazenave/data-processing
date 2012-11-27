#!/bin/csh -f

# scipt to get the trackline data from the dumprdf output

##----------------------------------------------------------------------------##

# get the navigation data
foreach i(`ls ../raw_data/rdf/dumprdf_output/*.txt | tac`)
   echo -n "$i... "
   cat $i | tr "()" " " | awk '/GPS/ {print $3,$5,$12"T"$13}' > $i.tmp
   sed '/2006-254/s/2006-254/11-09-2006/g' $i.tmp > $i.tmp2
   sed '/2006-255/s/2006-255/12-09-2006/g' $i.tmp2 > $i.nav
   \rm -f $i.tmp $i.tmp2
   \mv ../raw_data/rdf/dumprdf_output/*.nav ./raw_data/
   rename ".txt.nav" "" ./raw_data/*.nav
   echo "Done!"
end
