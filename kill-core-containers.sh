#! /bin/sh

for i in `docker ps | grep transitclock-core-instance- | cut -d ' ' -f1`
do
  docker stop $i
done

