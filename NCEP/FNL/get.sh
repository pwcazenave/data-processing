#!/usr/bin/bash --login

set -eu

# Experienced Wget Users: add additional command-line flags here
#   Use the -r (--recursive) option with care
#   Do NOT use the -b (--background) option - simultaneous file downloads
#       can cause your data access to be blocked
opts="-qcN"

# Replace "xxxxxx" with your password
# IMPORTANT NOTE:  If your password uses a special character that has special
#                  meaning to csh, you should escape it with a backslash
#                  Example:  set passwd = "my\!password"
passwd=${passwd:-xxxxxx}
num_chars=$(echo "$passwd" | awk '{print length($0)}')

cert_opt=""
# If you get a certificate verification error (version 1.10 or higher),
# uncomment the following line:
#set cert_opt = "--no-check-certificate"

# authenticate - NOTE: You should only execute this command ONE TIME.
# Executing this command for every data file you download may cause
# your download privileges to be suspended.
wget -q $cert_opt -O auth_status.rda.ucar.edu --save-cookies auth.rda.ucar.edu.$$ --post-data="email=pica@pml.ac.uk&passwd=$passwd&action=login" https://rda.ucar.edu/cgi-bin/login

# Sort out the time stuff.
#     J  F  M  A  M  J  J  A  S  O  N  D
dom=(31 28 31 30 31 30 31 31 30 31 30 31)
monthnames=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

# What years?
years=({2003..2013})
#
# download the file(s)
# NOTE:  if you get 403 Forbidden errors when downloading the data files, check
#        the contents of the file 'auth_status.rda.ucar.edu'
for year in ${years[@]}; do
    if [ ! -d ./$year ]; then
        mkdir ./$year
    fi
    if [ $(echo "scale=0; $year % 4" | bc -l) -eq 0 ]; then
        dom[1]=29
    else
        dom[1]=28
    fi

    for month in {01..12}; do
        echo -n "${monthnames[$((10#$month - 1))]} $year: "
        for rawday in $(seq 1 ${dom[$((10#$month - 1))]}); do
            day=$(printf %02d $rawday)
            echo -n "$day "
            for rawhour in 0 6 12 18; do
                hour=$(printf %02d $rawhour)
                if [ $year -ge 2007 -a $month -ge 12 -a $rawday -lt 6 ]; then
                    grib=grib1
                elif [ $year -eq 2007 -a $month -eq 12 -a $rawday -eq 6 ]; then
                    if [ $hour -le 6 ]; then
                        grib=grib1
                    else
                        grib=grib2
                    fi
                elif [ $year -ge 2007 -a $month -ge 12 -a $rawday -gt 6 ]; then
                    grib=grib2
                fi

                wget $cert_opt $opts --load-cookies auth.rda.ucar.edu.$$ http://rda.ucar.edu/data/ds083.2/$grib/$year/$year.$month/fnl_${year}${month}${day}_${hour}_00.$grib

            done
        done
        echo
    done
    # Move the files to their own directory.
    mv fnl_${year}????_??_??.grib? $year
done

# clean up
rm auth.rda.ucar.edu.$$ auth_status.rda.ucar.edu
