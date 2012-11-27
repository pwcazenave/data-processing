#!/bin/bash
#
# script to write the solent sac data to tape
#

NET=$HOME/scratch/tmp/tape
LOCAL=/tmp/pwc101

totape(){
   for DIR in $NET/*; do
      echo $(basename $DIR)
#      cp -R $DIR $LOCAL
#      echo cp $DIR $LOCAL
      tar --strip-path=6 --create --verbose --file=/dev/nst0 $NET/$(basename $DIR)
#      echo tar cvf /dev/nst1 $LOCAL/$(basename $DIR)
#      \rm -r $LOCAL/$(basename $DIR)
#      echo "\rm -r $LOCAL/$(basename $DIR)"
   done
}

totape          # execute the function

exit 0
