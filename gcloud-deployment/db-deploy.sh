#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

AGENCY_ID="monterey-0"

gcloud compute instances create-with-container db-$AGENCY_ID \
  --container-stdin --container-tty \
  --container-image docker.io/postgres:9.6.3 \
  --boot-disk-size=10GB \
  --tags postgres \
  --container-env POSTGRES_PASSWORD=$PGPASSWORD

AGENCY_ID="monterey-1"

gcloud compute instances create-with-container db-$AGENCY_ID \
  --container-stdin --container-tty \
  --container-image docker.io/postgres:9.6.3 \
  --boot-disk-size=10GB \
  --tags postgres \
  --container-env POSTGRES_PASSWORD=$PGPASSWORD

AGENCY_ID="monterey-2"

gcloud compute instances create-with-container db-$AGENCY_ID \
  --container-stdin --container-tty \
  --container-image docker.io/postgres:9.6.3 \
  --boot-disk-size=10GB \
  --tags postgres \
  --container-env POSTGRES_PASSWORD=$PGPASSWORD
