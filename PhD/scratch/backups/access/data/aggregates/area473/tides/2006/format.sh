#!/bin/csh -f

# script to take the output of dumprdf.exe and get the z and time stamps

##----------------------------------------------------------------------------##

# get the navigation data z value and the time stamp associated with it
foreach i(`ls ../raw_data/rdf/dumprdf_output/*.txt | tac`)
	echo -n "$i... "
	tr "()" " " < $i | awk '/GPS/ {print $12"T"$13, $7}' > $i.tmp
	sed '/2006-254/s/2006-254/11-09-2006/g' $i.tmp > $i.tmp2
	sed '/2006-255/s/2006-255/12-09-2006/g' $i.tmp2 > $i.out
	\rm -f $i.tmp $i.tmp2
	\mv ../raw_data/rdf/dumprdf_output/*.out ./raw_data/
	echo "Done"
end
