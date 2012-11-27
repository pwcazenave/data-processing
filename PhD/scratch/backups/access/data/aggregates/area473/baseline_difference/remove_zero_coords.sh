#!/bin/bash

for i in ./tracklines/2006/*.line; do
   cat $i | \
      while read line; do
	 three=$(echo $line | awk '{ print $3}')
	 if [ $three != 0.000000 ]; then
            echo $line >> ${i%.line}.test
         fi
      done
done
