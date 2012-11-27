#!/bin/bash

# Script to read Katsuto's boundary data files and produce MIKE21
# Tide Prediction of Heights files. These produce dfs0 files which 
# need to be merged into individual dfs1 files.

# Pierre Cazenave pwc101@soton.ac.uk

# 24/05/2010 - first go.
# 25/05/2010 - added support for passing the files to the command 
#					line.
# 21/07/2010 - merged changes from mk_mike21.sh from yesterday in
#					to this file. 
# 20/10/2010 - merged changes from mk_palaeo.sh (renamed from 
#				mk_mike21.sh), notably the clipping of boundaries.

templateFile=./uehara_template_predicted.21t
dos2unix $templateFile # Got bitten by this once...

if [ $# -eq 0 ]; then
	echo "No paths specified. Use all data in ./fixed? (Y/N)"
	read userinput
	if [ "$userinput" == "Y" -o "$userinput" == "y" ]; then
		allFiles=(./fixed/*m2*.dat)
	elif [ "$userinput" == "N" -o "$userinput" == "n" ]; then
		exit 1
	else
		echo "Unknown response. Exiting."
	fi
else
	allFiles=("$@")
fi


# The varying land boundary coordinates, extracted from Peltier's
# zero contour positions at each boundary. These are used in the
# lookup later on to ensure we only use data from the sea.
# There should be 22 values for each timestep back from present.
# Zero values essentially indicate there should be no clipping.
# NOTE: I have only obtained these numbers for the present day,
# and 12-6ka BP, hence the zeroes.
peltierWestMax=(64.208333 0 0 0 0 0 64.208333 64.208333 64.208333 64.208333 64.125 64.125 64.125 0 0 0 0 0 0 0 0 0)
peltierEastMin=(54.041667 0 0 0 0 0 54.041667 54.041667 54.041667 54.041667 54.125 54.125 54.541667 0 0 0 0 0 0 0 0 0)
peltierEastMax=(56.125 0 0 0 0 0 56.125 56.125 56.125 56.125 56.125 56.125 56.125 0 0 0 0 0 0 0 0 0)
peltierSouthMax=(-1.125 0 0 0 0 0 -1.125 -1.291667 -1.291667 -1.291667 -1.291667 1.2916670087 -1.375 0 0 0 0 0 0 0 0 0)
peltierNorthMin=(-13.875 0 0 0 0 0 -13.875 -13.875 -13.875 -13.875 -13.875 -13.8750000075 -13.875 0 0 0 0 0 0 0 0 0)
peltierNorthMax=(10.708333 0 0 0 0 0 11.541667 11.625 11.625 11.708333 11.708333 11.7916669921 11.375 0 0 0 0 0 0 0 0 0)

# Do each file specified in $allFiles
for ((file=0; file<${#allFiles[@]}; file++)); do
	inFile=${allFiles[file]}
	timeSince=$(echo $inFile | cut -f2 -d_ | cut -f1 -d.)

	# Use the value in timeSince to reference the land positions from the
	# various peltier* arrays above.
	timeSinceLand=$(echo $timeSince | tr -d "[A-Za-z]" | printf %i)

	outfile=bta0-${timeSince}.21t
	for i in ./generate_palaeo/${outfile%.*}_*predicted.21t; do
		if [ -e $i ]; then
			rm $i
		fi
	done

	# Work through each line in the boundary file
	numLines=$(($(wc -l < $inFile)-1)) # there's an extra newline

	for ((i=0; i<$numLines; i++)); do
		echo "File $(($file+1)) of ${#allFiles[@]}: $(basename "${inFile/m2/??}"): line $(($i+1)) of $numLines... "

		# Get the parameters for the current line in this $inFile
		currentLine=$(($i+2)) # skip the header
		m2Data=($(sed -n "${currentLine}p" $inFile))
		s2Data=($(sed -n "${currentLine}p" ${inFile/m2/s2}))
		n2Data=($(sed -n "${currentLine}p" ${inFile/m2/n2}))
		k1Data=($(sed -n "${currentLine}p" ${inFile/m2/k1}))
		o1Data=($(sed -n "${currentLine}p" ${inFile/m2/o1}))

		# Rather than change values in $??Data, just check if we're outside
		# a given range (i.e. we're on land), and ignore those values. The
		# resulting .21t files should only have values for land at that point.

		# Array for the coordinate output filenames
		boundaries=(east west north south)

		# Western boundary - no minimum for this data because its southernmost
		# value will always be over sea.
		wMax=$(echo "scale=2; ${m2Data[1]}-${peltierWestMax[timeSinceLand]}" | bc -l | awk '{if ($1>0) print 1; else print 0}')
		if [ ${m2Data[4]} -eq 2 ]; then
			if [ $wMax -eq 1 ]; then
				echo "Data point falls on land, skipping."
				echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz
				continue
			fi
		fi
		# Eastern boundary - we're ignoring the island in the middle of the Eastern
		# boundary. This is the least important of the boundaries, so it's not too
		# sensitive to changes due to its length.
		eMin=$(echo "scale=2; ${m2Data[1]}-${peltierEastMin[timeSinceLand]}" | bc -l | awk '{if ($1<0) print 1; else print 0}')
		eMax=$(echo "scale=2; ${m2Data[1]}-${peltierEastMax[timeSinceLand]}" | bc -l | awk '{if ($1>0) print 1; else print 0}')
		if [ ${m2Data[4]} -eq 1 ]; then
			if [ $eMax -eq 1 -o $eMin -eq 1 ]; then
				echo "Data point falls on land, skipping."
				echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz
				continue
			fi
		fi

		# Northern boundary - undergoes the most clipping because it seems the
		# Uehara model didn't have accurate Iceland coastline information. Also
		# encroaches on Norway at the eastern end, hence a minimum and maximum
		# check here.
		nMin=$(echo "scale=2; ${m2Data[0]}-(${peltierNorthMin[timeSinceLand]})" | bc -l | awk '{if ($1<0) print 1; else print 0}')
		nMax=$(echo "scale=2; ${m2Data[0]}-${peltierNorthMax[timeSinceLand]}" | bc -l | awk '{if ($1>0) print 1; else print 0}')
		if [ ${m2Data[4]} -eq 3 ]; then
			if [ $nMin -eq 1 -o $nMax -eq 1 ]; then
				echo "Data point falls on land, skipping."
				echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz
				continue
			fi
		fi
		# Southern boundary - This is a little more complicated because of the
		# Mediterranean sea section. There's no need to check the western end
		# because that's over the northeast Atlantic, and so is fine. However,
		# the eastern end along the French coast needs clipping, as do the
		# two basins in the Mediterranean, meaning four separate checks for the
		# Mediterranean alone.
		# Since I'm not using the data from the Mediterranean anyway, I'm leaving
		# those values hard-coded. The part of interest is the western French
		# coast, so it has a dynamic maximum value.
		# OK, change of plans. Since the number of basins in the Mediterranean
		# changes with time, and particularly since I'm excluding that part from
		# the model, I'm just going to extract data for the French coast, and bin
		# all the Mediterranean stuff.
		sFrenchMax=$(echo "scale=6; ${m2Data[0]}-(${peltierSouthMax[timeSinceLand]})" | bc -l | awk '{if ($1>0) print 1; else print 0}')
#		sMedWestMin=$(echo "scale=2; ${m2Data[0]}-12.375" | bc -l | awk '{if ($1<0) print 1; else print 0}')
#		sMedWestMax=$(echo "scale=2; ${m2Data[0]}-13.791667" | bc -l | awk '{if ($1>0) print 1; else print 0}')
#		 sMedEastMin=$(echo "scale=2; ${m2Data[0]}-14.125" | bc -l | awk '{if ($1<0) print 1; else print 0}')
#		 sMedEastMax=$(echo "scale=2; ${m2Data[0]}-15.041667" | bc -l | awk '{if ($1==0) print 1; else print 0}')
		if [ ${m2Data[4]} -eq 4 ]; then
			# In France
			if [ $sFrenchMax -eq 1 ]; then
				echo "Data point falls in France, skipping."
				echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz
				continue
			fi
#			if [ $sFrenchMax -eq 1 -a $sMedWestMin -eq 1 -a $sMedWestMax -eq 0 -a $sMedEastMin -eq 1 ]; then
#				echo "Data point falls on land, skipping."
#				echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz
#				continue
#			# In Italy
#			elif [ $sFrenchMax -eq 1 -a $sMedWestMin -eq 0 -a $sMedWestMax -eq 1 -a $sMedEastMin -eq 1 ]; then
#				echo "Data point falls on land, skipping."
#				echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz
#				continue
#				# East of the second basin
#			elif [ $sFrenchMax -eq 1 -a $sMedWestMin -eq 0 -a $sMedWestMax -eq 1 -a $sMedEastMin -eq 0 -a $sMedEastMax -eq 1 ]; then
#				echo "Data point falls on land, skipping."
#				echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz
#				continue
#			fi
		fi

		# Save all relevant coordinate points in a set of files, one for each
		# boundary. Also add these to the "land" files so that I can see what
		# the difference between the two is.
		echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates.xyz
		echo "${m2Data[0]} ${m2Data[1]} 1 0 0" >> ./boundaries/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}_coordinates_land.xyz

		while read line; do
			# Get the boundary type (east, west, south north) from the 5th column
			# value. Set the outfile for this line accordingly from Uehara's
			# readme.txt
			if [ ${m2Data[4]} -gt 4 ]; then
				echo "Unknown boundary type; exiting."
				exit 2
			fi
			currOut=./generate_palaeo/${outfile%.*}_${boundaries[$((${m2Data[4]}-1))]}_predicted.21t

			# The leg work...
			if [ "$line" == "Name = 'Setup Name'" ]; then
				echo "Name = 'harmonics_${timeSince}_${m2Data[0]}_${m2Data[1]}'" >> $currOut
			elif [ "$line" == "description = 'NAMETEST'" ]; then
				echo "description = 'bta0-${timeSince}_${m2Data[0]}_${m2Data[1]}'" >> $currOut
			# lat/longs
			elif [ "$line" == "x = 0" ]; then
				echo "x = ${m2Data[0]}" >> $currOut
			elif [ "$line" == "y = 0" ]; then
				echo "y = ${m2Data[1]}" >> $currOut
			# output file
			elif [ "$line" == "file_name = |.dfs0OUTPUTTEST.dfs0|" ]; then
				echo "file_name = |..\\dfs0\\predicted\\bta0-${timeSince}_${m2Data[0]}_${m2Data[1]}_${boundaries[$((${m2Data[4]}-1))]}_predicted.dfs0|" >> $currOut
			else
				echo "$line" >> $currOut
			fi
		done < $templateFile
	done
done
