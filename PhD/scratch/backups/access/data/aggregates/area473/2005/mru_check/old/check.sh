#! /bin/csh -f

# script to plot the 5 days' sample data for the mru vs nadir vs time

gmtset INPUT_DATE_FORMAT yyyy-mm-dd
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm

set area=-R2005-09-01T00:00/2005-09-30T00:00/0/2000
set proj=-JX24cT/12
set suffix=mru.ps

# get the basics in
#psbasemap $area $proj -Xc -Yc -B -K > $outfile

# start the loop
#foreach input (`ls ./raw_data/0?[1-9]*.new`)
foreach input (`ls ./raw_data/0137_-_474_e_7.txt.new`)

	# just in case
	gmtset D_FORMAT %.3f

	# set the outfile format
	set outfile=./images/`echo $input | tr "/" " " | awk '{print $3}'`.$suffix

	# create a trendline
	awk '{print $1, $3}' $input | trend1d -fT -N500 -Fxr > trend1d_3

	# create the new area based on the trendline
	set area=-R`minmax -fT -C trend1d_3 | \
	awk '{print $1"/"$2"/""-200""/"0}'`

	# plot the image using the trendline output
	psbasemap $area $proj -K -B0 > $outfile
	psxy $area $proj -Ba5Mf5Mg5M/a50f50g50WeSn -O -K -W1/220/0/0 trend1d_3 -Sp0.01 >> $outfile
	set area=-R`minmax -fT -C $input | awk '{print $1"/"$2"/"$9"/"$10}'`
	awk '{print $1, $5}' $input | psxy $area $proj -Ba5Mf5Mg5M/a50f50g50wESn -O -K -W1/0/0/0 >> $outfile

	# what's all this??
#	set area=-R`minmax -fT -C $input | awk '{print $1"/"$2"/"$7"/"$8+1000}'`
#	awk '{print $1, $4}' $input | psxy $area $proj -O -K -W1/0/220/0 -Sp0.01 >> $outfile

#	set area=-R`minmax -fT -C $input | awk '{print $1"/"$2"/"$9"/"$10}'`
#        awk '{print $1, $5}' $input | psxy $area $proj -Ba5Mf5Mg5M/a0.5f0.5g0.5wEsn -O -K -W1/0/0/220 >> $outfile

	gmtset D_FORMAT %lg
#	\rm temp temp2 trend1d_3

# end the loop
end

# display the image
#gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
