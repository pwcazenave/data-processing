"""
Fixing the raw data into something useable is not as straightforward as it may
seem. The raw data files have lots of other data (notable temperature, which
might be useful in its own right) and the order of the columns varies. So,
simply awking columns is not appropriate. Instead, we need to properly parse
the header and extract the variable identifiers we're interested in before
writing out a simple time,speed,direction,flag CSV file. That should make
parsing and dumping into the SQLite database much more straightforward.

"""

from __future__ import print_function

import os
import glob

from pandas import read_csv


def header_index(file, endstr):
    """
    For a given file, find the line number which marks the end of the header.
    The header is defined as the top of the file at which the string
    `endstr' is found. Note, blank lines do not count in the header. This is
    for compatibility with pandas.read_csv(), which seems to ignore blank
    lines.

    Parameters
    ----------
    file : str
        Path to the file in question.
    endstr : str
        Pattern marking the end of the header.

    Returns
    -------
    lineno : int
        Line number representing the last line of the header (inclusive).

    """
    with open(file) as fp:
        # Do line counting manually so as to be able to omit blank lines.
        ind = 0
        for line in fp:
            if filter(None, line.strip()):
                ind += 1
            if line.startswith(endstr):
                return ind


if __name__ == '__main__':

    files = glob.glob(os.path.join('raw_data', '*.lst'))

    # The fields we're interested in for current direction and speed are:
    #   LCDAAP01, LCDAEL01, LCDAZZ01 - direction
    #   LCSAAP01, LCSAEL01 - speed
    # The :1 appended to the names in the tuples below refer to the instance of
    # each parameter code. For ADCP data, for example, there are multiple of
    # each value for each depth bin.
    direction_names = ('LCDAAP01:1', 'LCDAEL01:1', 'LCDAZZ01:1')
    speed_names = ('LCSAAP01:1', 'LCSAEL01:1')

    for ii, f in enumerate(files):
        print('File {} ({} of {})... '.format(f, ii + 1, len(files)), end='')

        # First find the header length.
        hidx = header_index(f, '  Cycle')

        # We'll use a pandas dataframe to hold the data which should allow us
        # to use the parameter codes to easily extract the relevant data.
        df = read_csv(f, header=hidx, sep=r'\s+')

        # Drop the first row which is the format specifier.
        df = df[1:]

        # Find the speed and direction data.
        for d in direction_names:
            if d in df.keys():
                direction = d
        for s in speed_names:
            if s in df.keys():
                speed = s

        if not direction or not speed:
            print('skipping (no speed/direction data)')
            continue

        # Split the flags into their own array. We're collapsing all flags into
        # a single this-is-a-dodgy-data-point rather than
        # this-data-is-a-bit-too-big or this-data-is-a-bit-too-small.

        # Note, because we truncated the dataframe by removing the first value
        # from all frames, we need to offset the indexing by one accordingly.
        dflag = []
        for vv, val in enumerate(df[direction]):
            if val[-1].isalpha():
                dflag.append('True')
                df[direction][vv + 1] = val[:-1]
            else:
                dflag.append('False')

        sflag = []
        for vv, val in enumerate(df[speed]):
            if val[-1].isalpha():
                sflag.append('True')
                df[speed][vv + 1] = val[:-1]
            else:
                sflag.append('False')

        flag = []
        for flg in zip(dflag, sflag):
            if 'True' in flg:
                flag.append('True')
            else:
                flag.append('False')

        df['Flag'] = flag

        # Save to CSV.
        prefix = os.path.splitext(os.path.basename(f))[0]
        fout = os.path.join('formatted', '{}.csv'.format(prefix))
        df.to_csv(fout,
                columns=['Date', 'Time', direction, speed, 'Flag'], header=False,
                index=False)

        print('saved to CSV ({})'.format(fout))

