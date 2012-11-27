#!/bin/bash

# Script to take the pdfs in the current directory, extract the 
# authors, year and title from each one. Output is written to a
# skeleton .bib file.

OLDIFS=$IFS
IFS=$'\n'

files=($(\ls *.pdf))
bibfile=./new_refs.bib

IFS=$OLDIFS

for ((i=0; i<"${#files[@]}"; i++)); do
   
   echo "$i of ${#files[@]}"

   # Split the input
   title=$(echo ${files[$i]} | rev | cut -f1 -d\) | rev | cut -f2- -d\  )
   year=$(echo ${files[$i]} | cut -f2 -d\( | cut -f1 -d\) )
   authors=$(echo ${files[$i]} | cut -f1 -d\( );
   
   # Output the BibTeX file
   echo \@article\{$(echo ${authors%%,*} | tr "[:upper:]" "[:lower:]" | tr -d " ")${year}, >> $bibfile
   echo "	author=\""$authors"\"," >> $bibfile
   echo "	title=\"{"${title%.pdf}"}\"," >> $bibfile
   echo "	year=\""$year"\"," >> $bibfile
   echo "	volume=\"\"," >> $bibfile
   echo "	number=\"\"," >> $bibfile
   echo "	pages=\"\"," >> $bibfile
   echo "	journal=" >> $bibfile
   echo "}" >> $bibfile
   echo >> $bibfile

done
