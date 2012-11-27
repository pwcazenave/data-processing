#!/bin/csh -f

# script to take the output from the svp logs and turn it into CARIS friendly input files

# make a tmp directory

\mkdir ./tmp

set p1=./tmp/part1.tmp
set p2=./tmp/part2.tmp
set p3=./tmp/part3.tmp
set p4=./tmp/part4.tmp

# start a loop
foreach infile (`ls *.log`)
	# what am I working on?
	echo Working on $infile

	# set a date variable from the file name
	#set date=`echo $infile | tr "_.-" " " | awk '{print $1,$2,$3}'`
	# can't get that to work

	# grep out the appropriate lines for the svp measurements, and add a date
	grep -v : $infile | awk '{print "11/09/2006",$1, $2, $3}' > $p1

	# grep in the timestamps and save to a new file
	grep : $infile | tr "_*" " " > $p2

	# grep out to text from the top of part2.tmp to a third part
	grep -v e $infile | grep -v a | grep : | tr "_*" " " > $p3

	# paste the two correct files together, and reorder the columns as needed
	paste $p1 $p3 > $p4
	awk '{print $1, $5, $2, $3, $4}' $p4 > ./output/`echo $infile | tr "." " " | awk '{print $1".new"}'`

	echo Done $infile
        echo Created file ./output/`echo $infile | tr "." " " | awk '{print $1".new"}'`
        echo
# end the loop
end

# remove all the temp files, and its directory
\rm -r ./tmp
