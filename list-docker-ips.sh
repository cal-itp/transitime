#! /bin/sh

SAVED_IFS=$IFS
IFS=$'\n'

for i in `docker ps | grep -v ^CONTAINER`
do
  # echo $i
  HASH=`echo $i | awk '{print $1}'`
  NAME=`echo $i | awk '{print $2}'`
  echo $NAME: `docker inspect $HASH | grep \"IPAddress | sed 's/.*"IPAddress"://' | sed 's/"//g'`
done

IFS=$SAVED_IFS
