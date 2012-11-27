#! /bin/bash

# script to turn the date and times in the ACDP data into a format which matlab can understand.

# ask for the input file:
echo -n "Input file: "
read 
input="$REPLY"
echo Working on $input
echo Output file will be input filename appended .out
echo Processing...

# use awk to remove the / and : from the time and date columns and replace it with spaces, then reprint all the columns using only spaces to delimit each column, reorder the columns to match the matlab scripts, and finally use grep to remove the header line. 

awk -F"/" '{print $1, $2, $3, $4}' $input | awk -F: '{print $1, $2, $3, $4}' | awk '{print $4, $3, $2, $5, $6, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28}' | grep -v ID > $input.out

echo Have created file called $input.out
exit 0

# spare code:
#$24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41
