#! /bin/sh

ID=`docker ps | grep transitclock- | cut -d ' ' -f1`
if [ ! -z "$ID" ]
then
  docker stop $ID
fi
