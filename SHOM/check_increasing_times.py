import sys
import numpy as np
import matplotlib.pyplot as plt
import csv

def julianDay(gregorianDateTime, mjd=False):
    """

    For a given gregorian date format (YYYY,MM,DD,hh,mm,ss) get the Julian Day.
    hh,mm,ss are optional, and zero if omitted (i.e. midnight).

    Julian Day epoch: 12:00 January 1, 4713 BC, Monday
    Modified Julain Day epoch: 00:00 November 17, 1858, Wednesday

    mjd=True applies the offset from Julian Day to Modified Julian Day.

    Modified after code at http://paste.lisp.org/display/73536

    """

    import time
    import numpy as np

    try:
        nr, nc = np.shape(gregorianDateTime)
    except:
        nc = np.shape(gregorianDateTime)
        nr = 1

    if nc < 6:
        # We're missing some aspect of the time. Let's assume it's the least
        # significant value (i.e. seconds first, then minutes, then hours).
        # Set missing values to zero.
        numMissing = 6 - nc
        if numMissing > 0:
            extraCols = np.zeros([nr,numMissing])
            gregorianDateTime = np.hstack([gregorianDateTime, extraCols])

    if nr > 1:
        year = gregorianDateTime[:,0]
        month = gregorianDateTime[:,1]
        day = gregorianDateTime[:,2]
        hour = gregorianDateTime[:,3]
        minute = gregorianDateTime[:,4]
        second = gregorianDateTime[:,5]
    else:
        year = gregorianDateTime[0]
        month = gregorianDateTime[1]
        day = gregorianDateTime[2]
        hour = gregorianDateTime[3]
        minute = gregorianDateTime[4]
        second = gregorianDateTime[5]


    a = (14 - month) // 12
    y = year + 4800 - a
    m = month + (12 * a) - 3
    # Updated the day fraction based on MATLAB function:
    #   http://home.online.no/~pjacklam/matlab/software/util/timeutil/date2jd.m
    jd = day + (( 153 * m + 2) // 5) \
        + y * 365 + (y // 4) - (y // 100) + (y // 400) - 32045 \
        + (second + 60 * minute + 3600 * (hour - 12)) / 86400

    if mjd:
        return jd - 2400000.5
    else:
        return jd


for file in sys.argv[1:]:
    print '\n' + file

    f = open(file, 'r')

    dateTime = []
    elevation = []
    flags = []

    for row in csv.reader(f):
        dateTime.append(row[0:6])
        elevation.append(row[-3:-1])
        flags.append(row[-1])

    #for line in f:
    #    elevation.append(line.split(' ')[-1])   # yyyy/mm/dd hh:mm:ss [zz]
    #    tmp1 = line.split(' ')[0:2]             # [yyyy/mm/dd hh:mm:ss] zz
    #    tmp2 = tmp1[0].split('/')               # yyyy mm dd
    #    tmp3 = tmp1[1].split(':')               # hh mm ss
    #    dateTime.append(tmp2 + tmp3)            # yyyy mm dd hh mm ss

    inData = np.asarray(dateTime, dtype=float)
    elevation = np.asarray(elevation, dtype=float)
    flags = np.asarray(flags, dtype=str)

    outTime = julianDay(inData, mjd=True)

    outTimeDiffBack = np.diff(outTime)
    outTimeDiffForward = outTimeDiffBack

    # Do a brute-force elimination of the crappy data
    cInDataBack = inData
    cInElevationBack = elevation
    cInFlagsBack = flags
    cInDataForward = inData
    cInElevationForward = elevation
    cInFlagsForward = flags

    print 'Count\tUnordered(1)\tUnordered(2)'
    count = 0

    while True:
        count += 1

        backLength = np.sum(outTimeDiffBack < 0)
        forwardLength = np.sum(outTimeDiffForward < 0)

        if backLength == 0 or forwardLength == 0:
            print str(count) + '\t' + str(backLength) + '\t' + str(forwardLength),
            break
        elif backLength > 0 and forwardLength > 0:
            print str(count) + '\t' + str(backLength) + '\t' + str(forwardLength),

            # Backwards removal

            # Need to check whether sometimes it's better to go backwards
            # than forwards when getting rid of data.
            cInDataBack = cInDataBack[np.hstack([outTimeDiffBack >= 0, [True]])]
            cInElevationBack = cInElevationBack[np.hstack([outTimeDiffBack >= 0, [True]])]
            cInFlagsBack = cInFlagsBack[np.hstack([outTimeDiffBack >= 0, [True]])]

            # Redo the time conversion and the diff on the filtered data
            outTimeBack = julianDay(cInDataBack, mjd=True)
            outTimeDiffBack = np.diff(outTimeBack)

            # Add an extra True at the start to bump the False up to the value
            # which has decreased. Since diff starts from the first value, a
            # negative diff means it's a drop in the n+1 value.
            cInDataForward = cInDataForward[np.hstack([[True], outTimeDiffForward >= 0])]
            cInElevationForward = cInElevationForward[np.hstack([[True], outTimeDiffForward >= 0])]
            cInFlagsForward = cInFlagsForward[np.hstack([[True], outTimeDiffForward >= 0])]

            # Redo the time conversion and the diff on the filtered data
            outTimeForward = julianDay(cInDataForward, mjd=True)
            outTimeDiffForward = np.diff(outTimeForward)

        # On each iteration, replace the input data for the diff analysis with
        # the shortest data set of the two to speed up the process. This way,
        # we're always using whichever result eliminated the fewest data
        # points.
        if forwardLength > backLength:
            # We have more diffs in the forward removal results, so replace the
            # forward in data with the backwards in data.
            cInDataForward = cInDataBack
            cInElevationForward = cInElevationBack
            cInFlagsForward = cInFlagsBack
            outTimeForward = outTimeBack
            outTimeDiffForward = outTimeDiffBack

            print cInDataBack[outTimeDiffBack < 0]
        elif backLength > forwardLength:
            # The opposite
            cInDataBack = cInDataForward
            cInElevationBack = cInElevationForward
            cInFlagsBack = cInFlagsForward
            outTimeBack = outTimeForward
            outTimeDiffBack = outTimeDiffForward

            print cInDataForward[outTimeDiffForward < 0]

        else:
            # They're the same
            print cInDataForward[outTimeDiffForward < 0]

            pass



    # Now we have two cleaned data sets, we need to check which is longest.
    if np.shape(cInDataBack)[0] > np.shape(cInDataBack)[0]:
        cInData = cInDataBack
        cInElevation = cInElevationBack
        cInFlags = cInFlagsBack
    else:
        cInData = cInDataForward
        cInElevation = cInElevationForward
        cInFlags = cInFlagsForward

    outData = np.column_stack([cInData, cInElevation, cInFlags])
    # The column stack casts everything as strings, hence all the %s's below.
    np.savetxt(file[:-4] + '_cleaned.slv', outData, fmt='%s,%s,%s,%s,%s,%s,%s,%s,%s')
    #np.savetxt(file[:-4] + '_cleaned.slv', outData, fmt='%s,%s,%s,%s,%s,%s,%s,%s,%s')

    f.close()

    # Give the times when the succeeding times decrease
    #print file + ": "
    #for line in inData[outTimeDiff < 0]:
    #    print '{:04d}'.format(int(line[0])) + ',' + '{:02d}'.format(int(line[1])) + ',' + '{:02d}'.format(int(line[2])) + ',' + '{:02d}'.format(int(line[3])) + ',' + '{:02d}'.format(int(line[4])) + ',' + '{:02d}'.format(int(line[5]))


