#!/bin/bash
# legacy cleanup, do not touch
DIR=$1
FILES=`ls $DIR`
for f in $FILES
do
  if [ $f == "*.log" ]
  then
    rm -rf $DIR/$f
  fi
done
cd $DIR
echo "removed files in $DIR at `date`"
read name
echo $name > /tmp/last_user
exit $?
