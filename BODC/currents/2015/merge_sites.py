"""
We have duplicate sites. Find those and merge the records. This may yield
discontinuities in the time records.

NOTE:
It turns out, this is probably unwise. Whilst many of the sites are duplicate
locations, the time series overlap. So, what I think it actually happening is
that the locations aren't precise enough and the records are therefore
erroneously reported as duplicates. I'm not sure what I can do about that.

"""

import os
import glob

from pandas import read_csv


def unique_rows(a):
    """
    Find unique entries per row of array.

    Parameters
    ----------
    a : ndarray
        Array of size (n, 2) to sort by rows.

    Returns
    -------
    s : ndarray
        Array of unique rows from `a'.

    Notes
    -----
    Lifted from http://stackoverflow.com/questions/16970982

    """

    b = np.ascontiguousarray(a).view(np.dtype((np.void, a.dtype.itemsize * a.shape[1])))
    _, idx = np.unique(b, return_index=True)

    unique_a = np.unique(b).view(a.dtype).reshape(-1, a.shape[1])

    return unique_a


if __name__ == '__main__':

    locs = os.path.join('metadata', 'bodc_series_metadata_summary.csv')

    metadata = read_csv(locs, header=23, parse_dates={'start_time':[9], 'end_time':[10]})

    locations = np.array((metadata['Longitude A'], metadata['Latitude A'])).transpose()
    unique_locations = unique_rows(locations)
    # Get indices for duplicate rows.
    uidx = []
    for pos in unique_locations:
        idx = np.where(np.sum(np.abs(locations - pos), axis=1) == 0)[0]
        if len(idx) > 1:
            uidx.append(idx.tolist())

    # Merge the time series.
    for dup in uidx:
        files = [os.path.join('formatted', 'b{:07d}.csv'.format(i)) for i in metadata['BODC reference'][dup]]
        order = np.argsort([i.toordinal() for i in metadata['start_time'][dup]])
        dateval, timeval, dirval, speedval, flagval = [], [], [], [], []
        for f in order:
            with open(files[f]) as d:
                rawdata = d.readlines()

                for val in rawdata:
                    flag = 'F'
                    line = filter(None, val.strip().split(' '))
                    # Skip a record if we're missing some aspect of the data.
                    if len(line) >= 5:
                        _, datestr, timestr, direction, speed = filter(None, val.strip().split(' '))[:5]
                    dateval.append(datestr.split('/'))
                    timeval.append(timestr.split('.'))
                    if speed[-1].isalpha():
                        speed = speed[:-1]
                        flag = 'T'
                    if direction[-1].isalpha():
                        direction = direction[:-1]
                        flag = 'T'
                    dirval.append(float(direction))
                    speedval.append(float(speed))
                    flagval.append(flag)





