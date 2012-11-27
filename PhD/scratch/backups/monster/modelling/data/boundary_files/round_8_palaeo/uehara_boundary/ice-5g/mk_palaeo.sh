#!/bin/bash

# Script to read Katsuto's boundary data files and produce MIKE21
# Tide Prediction of Heights files. These produce dfs0 files which 
# need to be merged into individual dfs1 files.
#
# If passing files as an argument, the wildcard should be the tidal
# constituent, not the time before present:
#
# prompt$ ./mk_mike21.sh ./fixed/bte0x-m2-??ka_m.dat
#
# Pierre Cazenave pwc101@soton.ac.uk

# 24/05/2010 - first go.
# 25/05/2010 - added support for passing the files to the command 
#					line.
# 20/07/2010 - added checks for coordinates to extract data which 
#					aren't on land (i.e. clip the inputs).
#				- also changed input directory to ./fixed, rather 
#					than ./formatted, the latter being in cm and not
#					metres.
#				- moved output destination for the dfs0 files to the
#					parent directory because the .21t files now live 
#					in their own subdirectory.
#				- output the clipped coordinates to MIKE21 friendly 
#					.xyz files to check that the clipping has worked.
#				- fixed a bug in the lon/lat assignments in the output 
#					files. Previously, the fields weren't being populated 
#					with the updated values.
#				- changed template file to not use numbers as placeholders,
#					instead, it uses all caps strings.
# 04/10/2010 - amended the land clipping to use variable positions as
#				a function of the time before present. The lookup table
#				is defined based on the positions from Peltier's ICE-5G
#				zero contour, plus a little wiggle room.
# 22/10/2010 - amended paths for the new ICE-5G derived boundary conditions.
# 08/11/2010 - added new coordinates for the intervening 0.5ka intervals
#				up to 112ka BP.
#			 - because of the new input file formats, some assumptions I'd made
#				about how to index the positions of land no longer hold. As
#				such, you MUST run this file with the first input file being
#				000ka BP, and increase in 0.5ka increments. If you don't, the
#				minima and maxima addressed in the boundary position arrays
#				will be wrong. 
#				
# TODO:
#		 - need to be able to use the southernmost value from the western
#		 boundary as the westernmost value on the southern boundary so that
#		 they share a common point. Not sure about how to achieve this...
#
# NOTE: Best off running this on sarge - Windows 7 seems to enjoy using
# upwards of 12GB of RAM running this through Cygwin and PuTTYcyg. I'm 
# assuming this is a Cygwin bug rather than Windows, though the rogue 
# process is dwm.exe (the window manager...). Also, it runs a lot faster
# on native Linux than through Cygwin.
#

templateFile=./uehara_template.21t
dos2unix $templateFile # Just in case...

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
# These need to be updated to include the 500 year interval positions. 
# For now, though, I've just double the sets.
peltierWestMax=(64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.208333 64.125 64.125 64.125 64.125 64.1660268515 64.1660268515 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
peltierEastMin=(54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.041667 54.125 54.125 54.125 54.125 54.541667 54.541667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
peltierEastMax=(56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 56.125 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
peltierSouthMax=(-1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.125 -1.291667 -1.291667 -1.291667 -1.291667 -1.291667 -1.291667 -1.291667 -1.291667 1.2916670087 1.2916670087 -1.375 -1.375 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
peltierNorthMin=(-13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.875 -13.8750000075 -13.8750000075 -13.875 -13.875 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
peltierNorthMax=(10.708333 10.708333 10.708333 10.708333 10.708333 11.5 11.5 11.5 11.5 11.5 11.5 11.5197594494 11.541667 11.541667 11.541667 11.625 11.625 11.625 11.625 11.708333 11.708333 11.708333 11.708333 11.7916669921 11.7916669921 11.375 11.375 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)

# Counter for the positions in the coordinate min/max arrays above.
timeSinceLand=-1 
# Initialises at -1 so the first iteration takes it to zero. Bash arrays are 
# indexed from zero.

# Do each file specified in $allFiles
for ((file=0; file<${#allFiles[@]}; file++)); do
	inFile=${allFiles[file]}
	timeSince=$(echo $inFile | cut -f2 -d_ | cut -f1 -d.)
	prefix=$(basename ${inFile%-*})

	# Use the value in timeSince to reference the land positions from the 
	# various peltier* arrays above.
	#timeSinceLand=$(echo $timeSince | tr -d "[A-Za-z]" | printf %i)
	timeSinceLand=$((${timeSinceLand}+1))

	outFile=${prefix}-${timeSince}.21t
	for i in ./generate_palaeo/${outFile%.*}*.21t ./boundaries/${outFile%.*}_*.xyz; do
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
#		sMedEastMin=$(echo "scale=2; ${m2Data[0]}-14.125" | bc -l | awk '{if ($1<0) print 1; else print 0}')
#		sMedEastMax=$(echo "scale=2; ${m2Data[0]}-15.041667" | bc -l | awk '{if ($1==0) print 1; else print 0}')
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
#			# East of the second basin
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
			# value. Set the outFile for this line accordingly from Uehara's 
			# readme.txt
			if [ ${m2Data[4]} -gt 4 ]; then
				echo "Unknown boundary type; exiting."
				exit 2
			fi
			#currOut=./generate_palaeo/${outFile%.*}_${boundaries[$((${m2Data[4]}-1))]}.21t
			currOut=./generate_palaeo/${outFile%.*}.21t

			# The leg work...
			if [ "$line" == "Name = TEMPNAME" ]; then
				echo "Name = 'harmonics_${timeSince}_${m2Data[0]}_${m2Data[1]}_${boundaries[$((${m2Data[4]}-1))]}'" >> $currOut
			elif [ "$line" == "StationName = TEMPSTATIONNAME" ]; then
				echo "StationName = '${prefix}-${timeSince}_${m2Data[0]}_${m2Data[1]}'" >> $currOut
			# lat/longs all the same across m2, s2 etc.
			elif [ "$line" == "StationLongitude = LON" ]; then
				echo "StationLongitude = ${m2Data[0]}" >> $currOut
			elif [ "$line" == "StationLatitude = LAT" ]; then
				echo "StationLatitude = ${m2Data[1]}" >> $currOut
			# m2 data
			elif [ "$line" == "Phase = M2P" ]; then
				echo "Phase = ${m2Data[3]}" >> $currOut
			elif [ "$line" == "Amplitude = M2A" ]; then
				echo "Amplitude = ${m2Data[2]}" >> $currOut
			# s2 data
			elif [ "$line" == "Phase = S2P" ]; then
				echo "Phase = ${s2Data[3]}" >> $currOut
			elif [ "$line" == "Amplitude = S2A" ]; then
				echo "Amplitude = ${s2Data[2]}" >> $currOut
			# n2 data
			elif [ "$line" == "Phase = N2P" ]; then
				echo "Phase = ${n2Data[3]}" >> $currOut
			elif [ "$line" == "Amplitude = N2A" ]; then
				echo "Amplitude = ${n2Data[2]}" >> $currOut
			# k1 data
			elif [ "$line" == "Phase = K1P" ]; then
				echo "Phase = ${k1Data[3]}" >> $currOut
			elif [ "$line" == "Amplitude = K1A" ]; then
				echo "Amplitude = ${k1Data[2]}" >> $currOut
			# o1 data
			elif [ "$line" == "Phase = O1P" ]; then
				echo "Phase = ${o1Data[3]}" >> $currOut
			elif [ "$line" == "Amplitude = O1A" ]; then
				echo "Amplitude = ${o1Data[2]}" >> $currOut
			# output file
			elif [ "$line" == "OutputFileName = TEMPOUTPUTFILENAME" ]; then
				echo "OutputFileName = |..\\dfs0\\${prefix}-${timeSince}_${m2Data[0]}_${m2Data[1]}_${boundaries[$((${m2Data[4]}-1))]}.dfs0|" >> $currOut
			else
				echo "$line" >> $currOut
			fi
		done < $templateFile
	done
done
