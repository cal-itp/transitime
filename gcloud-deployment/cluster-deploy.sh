#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

if [ -z "$RMI_HOST" ]; then
    echo "env variable RMI_HOST needs to be set"
    exit 0
fi

if [ -z "$DB_HOSTNAME" ]; then
    echo "env variable DB_HOSTNAME needs to be set"
    exit 0
fi

if [ -z "$PRIMARY_DB_HOSTNAME" ]; then
    echo "env variable PRIMARY_DB_HOSTNAME needs to be set"
    exit 0
fi

if [ -z "$PRIMARY_AGENCY_ID" ]; then
    echo "env variable PRIMARY_AGENCY_ID needs to be set"
    exit 0
fi

CLUSTER_INSTANCES=`gcloud compute instances list | grep -v ^NAME | grep ^transitclock-cluster- | wc -l | awk '{print $1}'`
echo CLUSTER_INSTANCES: $CLUSTER_INSTANCES
CLUSTER_INDEX=`expr 1 + $CLUSTER_INSTANCES`
echo CLUSTER_INDEX: $CLUSTER_INDEX

gcloud compute instances create-with-container transitclock-cluster-$CLUSTER_INDEX \
  --container-stdin --container-tty \
  --container-image gcr.io/transitclock-282522/cluster \
  --boot-disk-size=10GB \
  --tags transitclock-cluster \
  --container-env PGPASSWORD=$PGPASSWORD,RMI_HOST=$RMI_HOST,DB_HOSTNAME=$DB_HOSTNAME,PRIMARY_DB_HOSTNAME=$PRIMARY_DB_HOSTNAME,PRIMARY_AGENCY_ID=$PRIMARY_AGENCY_ID
