#! /bin/csh -f

# script to plot the exported single beam positions to create a trackline plot for the eastern english channel 2005 survey

set area=-R307130/325231/5591740/5600320
set proj=-Jx0.00125
set outfile=lines.ps

# sort out the numbering format
gmtset D_FORMAT %7.7lg

# make a basemap
psbasemap $area $proj -Ba2000g1000:"Eastings":/a1001g1000WeSn:"Northings"::."Tracklines for UTEC 473 - East and West": -K -Xc -Yc > $outfile

# add in the bathy, such as it is!
grdimage $area $proj -O -K ../swath/area473_2005_q.grd -C../swath/.utec_q.cpt >> $outfile

# add in the mask from the 2006 data so I can check which lines are in what
#grdimage $area $proj -O -K ../../difference/area473_2006_mask.grd -C../swath/.utec_q.cpt >> $outfile

# add in the difference grid for the 2005 and 2006 dataset to see which is
# causing the problem
#grdimage $area $proj -O -K ../../difference/area473_diff_05_06.grd -C../../difference/.diff_05_06.cpt >> $outfile

# add the data
echo -n "Starting... "
foreach input (`ls -C 0*`)
	# plot the lines
	set line_no=`echo $input | tr "_-" " " | awk '{print $1}'`
#	echo $line_no
	# 15/09/05
	if ($line_no <= 0014) then
		awk '{if (NR%10==0) print $1, $2}' $input | \
		psxy $area $proj -O -K -Sp0.025 -W1/0/131/255 >> $outfile
		# add the line number text
		tail -n 1 $input | \
		awk '{print $1,$2,"7 0 1 1",input}' input=$input |\
		pstext -G0/131/255 $area $proj -O -K >> $outfile
	# 16/09/05
	else if ($line_no >= 0015 && $line_no <= 0019) then
		awk '{if (NR%10==0) print $1, $2}' $input | \
		psxy $area $proj -O -K -Sp0.025 -W1/0/200/50 >> $outfile
		# add the line number text
		tail -n 1 $input | \
		awk '{print $1,$2,"7 0 1 1",input}' input=$input |\
		pstext -G0/200/50 $area $proj -O -K >> $outfile
	# 17/09/05
	else if ($line_no >= 0020 && $line_no <= 0037) then
		awk '{if (NR%10==0) print $1, $2}' $input | \
		psxy $area $proj -O -K -Sp0.025 -W1/200/20/0 >> $outfile
		# add the line number text
		tail -n 1 $input | \
		awk '{print $1,$2,"7 0 1 1",input}' input=$input |\
		pstext -G200/20/0 $area $proj -O -K >> $outfile
	# 18/09/05
	else if ($line_no >= 0047 && $line_no <= 0050) then
		awk '{if (NR%10==0) print $1, $2}' $input | \
		psxy $area $proj -O -K -Sp0.025 -W1/200/200/0 >> $outfile
		# add the line number text
		tail -n 1 $input | \
		awk '{print $1,$2,"7 0 1 1",input}' input=$input |\
		pstext -G200/200/0 $area $proj -O -K >> $outfile
	# 21/09/05
	else if ($line_no >= 0110 && $line_no <= 0120) then
		awk '{if (NR%10==0) print $1, $2}' $input | \
		psxy $area $proj -O -K -Sp0.025 -W1/0/0/0 >> $outfile
		# add the line number text
		tail -n 1 $input | \
		awk '{print $1,$2,"7 0 1 1",input}' input=$input |\
		pstext -G0/0/0 $area $proj -O -K >> $outfile
	# 22/09/05
	else
		awk '{if (NR%10==0) print $1, $2}' $input | \
		psxy $area $proj -O -K -Sp0.025 -W1/0/0/0 >> $outfile
		# add the line number text
		tail -n 1 $input | \
		awk '{print $1,$2,"7 0 1 1",input}' input=$input |\
		pstext -G0/0/0 $area $proj -O -K >> $outfile
	endif
end

# add in another basemap for the grid lines
psbasemap $area $proj -Bg1000 -O -K >> $outfile

# return the number format to its default
gmtset D_FORMAT %lg

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
echo "Done!"

