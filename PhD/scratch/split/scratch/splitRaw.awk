#!/usr/bin/env awk

# Script to split a monster file into sixteen separate files
# based on the width of the domain.
#
# Pierre Cazenave 04/11/2010 pwc101@soton.ac.uk

BEGIN {
	west = ARGV[1];
	east = ARGV[2];
	south = ARGV[3];
	north = ARGV[4];
	splitx = ARGV[5];
	splity = ARGV[6];

	incx = (east-west)/splitx
	incy = (north-south)/splity

	print $2

	for (x = 0; x < splitx; x++)
		for (y = 0; y < splity; y++) {
			printf "min x:\t%f\tmax x:\t%f\tmin y:\t%f\tmax y:\t%f\n", west+(incx*x),west+(incx*(x+1)),south+(incy*y),south+(incy*(y+1))
			minx=west+(incx*x)
			maxx=west+(incx*(x+1))
			miny=south+(incy*y)
			maxy=south+(incy*(y+1))
			print minx,maxx,miny,maxy
			if (100 > minx && 100 < maxx && 100 > miny && 100 < maxy) {
				printf "%s\n","something"
			}
		}

		#for (y = 0; y < splity; y++)
			#print x,y

	

	
#	print east-west,north-south,(east-west)/splitx,(north-south)/splitx

}
