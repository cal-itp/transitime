#! /bin/sh

TMP_ZIP="/tmp/gtfs.zip"

SAVED_IFS=$IFS
IFS=$'\n'

for i in `cat ../docker/core/agency-list.txt`
do
    # echo "  i: $i"
    GTFS_URL=`echo $i | awk '{print $2}'`
    echo "  GTFS_URL: $GTFS_URL"
    curl -o $TMP_ZIP $GTFS_URL
    jar tf $TMP_ZIP
done

IFS=$SAVED_IFS
