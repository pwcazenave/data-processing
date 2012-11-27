#! /bin/csh -f

# script to ouput the profiles of the bathymetry made using surfer

set map_area=-R578117/588284/91508/98686
set map_proj=-Jx0.002
set text_area=-R0/30/0/20
set text_proj=-JX30/20
set map_outfile=plots/report_locations.ps

# the location map
#set colours=`cat colours.rgb | grep -v "*ligh*" | awk '{print $1}'`
#foreach c ($colours)

psbasemap $map_area $map_proj -Ba2000f1000:"Eastings":/a2000f1000:"Northings":WeSn -Xc -Yc -K > $map_outfile
grdimage $map_area $map_proj -I../../bathy/utec_survey/utec/utec_grad.grd -C../../bathy/utec_survey/utec/utec.cpt ../../bathy/utec_survey/utec/utec_mask.grd -O -K -Bg1000 >> $map_outfile

psscale -D21.1/6.5/5/0.5 -B5 -C../../bathy/utec_survey/utec/utec.cpt -O -K >> $map_outfile
pstext $text_area $text_proj -O -K << TEXT >> $map_outfile
21 9.5 12 0 1 1 Depth (m)
TEXT

#1!> start the loop
# perhaps a more elegant way of getting all the filenames might be:
#set iterations=`ls raw_data/*.dat | tr "/" " " | awk '{print $2}'`
#foreach i ($iterations)
foreach i (dunes_ribbon_bedrock_003.dat)
set input=raw_data/$i

	# what am i working on?
	echo Working on $input

	set plot_outfile=plots/individual/profile_$i.ps
	set plot_area=-R`cat $input | minmax | tr "/<>" "   " | awk '{printf "%1d %4d %2s %2s\n", $12,($13+50),($10-0.5),($11+0.5)}' | tr " " "/"`
	set plot_proj=-JX15/8

	# plot the transect location on the location map plots/locations.ps
	awk '{print $1, $2}' $input | psxy $map_area $map_proj -Bg500 -O -K -W8/0/0/0 >> $map_outfile
	# plot the profiles in $plot_outfile:
	psbasemap $plot_area $plot_proj -Ba200f100g100:"Distance along line (m)":/a1f0.5g0.5WeSn:"Depth (m) CD": -Xc -Y17 -K -P > $plot_outfile
	grdtrack $input -G../../bathy/utec_survey/utec/utec_mask.grd > $i.xy 
	awk '{print $4, $3}' $i.xy | psxy $plot_area $plot_proj -O -K -W1/0/0/255 >> $plot_outfile

	# calculate and plot a number of "strength" trend lines
	# create a set of three different trends and plot them on top of the existing data
#	awk '{print $4, $3}' $i.xy | trend1d -N50 -Fxmr > temp1.xy
#	psxy $plot_area $plot_proj -W1/200/0/50 -O -K temp1.xy >> $plot_outfile
#	awk '{print $4, $3}' $i.xy | trend1d -N20 -Fxmr > temp2.xy
#	psxy $plot_area $plot_proj -W1/0/200/50 -O -K temp2.xy >> $plot_outfile
#	awk '{print $4, $3}' $i.xy | trend1d -N30 -Fxmr > temp3.xy
#	psxy $plot_area $plot_proj -W1/50/0/200 -O -K temp3.xy >> $plot_outfile

	# create a new plot area for the residual values
#	set plot_area_subset=-R`cat temp1.xy | minmax | tr "/<>" "   " | awk '{printf "%1d %4d %2s %1s\n", $6,($7+50),($10-0.2),($11+0.2)}' | tr " " "/"`
#	psbasemap $plot_area_subset $plot_proj -Ba200f100g100:"Distance along line (m)":/a0.5g0.25WeSn:"Residual Depth (m)": -Y-13 -O -K -P >> $plot_outfile
#	awk '{print $1, $3}' temp1.xy | psxy $plot_area_subset $plot_proj -W1/200/0/50 -O -K >> $plot_outfile
#               awk '{print $1, $3}' temp2.xy | psxy $plot_area_subset $plot_proj -W1/0/200/50 -O -K >> $plot_outfile
#               awk '{print $1, $3}' temp3.xy | psxy $plot_area_subset $plot_proj -W1/50/0/200 -O -K >> $plot_outfile
	
	# remove the random files 
	\rm -f *.xy

	# what have i just finished working on?
	echo Done $input
	echo Created file ./$plot_outfile
	echo 
#1!> end the loop
end

gs $plot_outfile
#end
