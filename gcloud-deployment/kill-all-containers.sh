#! /bin/sh

INSTANCE_NAMES=""

SAVED_IFS=$IFS
IFS=$'\n'

echo running intances:
for i in `gcloud compute instances list | grep -v ^NAME | awk '{print $1}'`
do
    echo "  "$i
    INSTANCE_NAMES=$INSTANCE_NAMES" "$i
done

IFS=$SAVED_IFS

echo INSTANCE_NAMES: $INSTANCE_NAMES

if [ ! -z "$INSTANCE_NAMES" ]; then
    gcloud compute instances delete $INSTANCE_NAMES --delete-disks=all
fi
