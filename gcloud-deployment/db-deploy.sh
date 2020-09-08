#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

DB_INSTANCE_COUNT=`gcloud compute instances list | grep -v ^NAME | grep ^db- | wc -l | awk '{print $1}'`
echo DB_INSTANCE_COUNT: $DB_INSTANCE_COUNT
DB_INDEX=`expr 1 + $DB_INSTANCE_COUNT`
echo DB_INDEX: $DB_INDEX

gcloud compute instances create-with-container db-$DB_INDEX \
  --container-stdin --container-tty \
  --container-image docker.io/postgres:9.6.3 \
  --boot-disk-size=10GB \
  --tags postgres \
  --container-env POSTGRES_PASSWORD=$PGPASSWORD

