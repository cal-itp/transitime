#! /bin/sh
KILL_DB_INSTANCES=0

for i in "$@"; do
  if [ "$i" == "-kill-db" ]; then
    KILL_DB_INSTANCES=1
    shift
  fi
done

echo KILL_DB_INSTANCES: $KILL_DB_INSTANCES

for i in `docker ps | grep transitclock-core- | cut -d ' ' -f1`
do
  docker stop $i
done

if [ "$KILL_DB_INSTANCES" == "1" ]; then
  for i in `docker ps | grep transitclock-db- | cut -d ' ' -f1`
  do
    docker stop $i
  done
fi

