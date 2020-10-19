#! /bin/sh

# This is the first half of a full transit clock deploy. The second half is clustered-server-deploy.sh
#
# Sequence of events triggered is:
# - delete all currently running TC containers
# - start RMI registry
# - start DB container
# - start cluster

if [ "$#" -ne 1 ]; then
  echo "Usage: cluster-full-deploy.sh <primary-agency-id>" >&2
  exit 1
fi

PRIMARY_AGENCY_ID=$1
echo "PRIMARY_AGENCY_ID: $PRIMARY_AGENCY_ID"

gcloud config set project transitclock-282522

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

. kill-all-containers.sh
. rmi-deploy.sh

RMI_HOSTNAME=`gcloud compute instances list | grep rmi-registry | awk '{print $5}'`
echo RMI_HOSTNAME: $RMI_HOSTNAME

. db-deploy.sh

DB_HOSTNAME=`gcloud compute instances list | grep db-$AGENCY_ID | awk '{print $5}'`
echo "DB_HOSTNAME: $DB_HOSTNAME"
PRIMARY_DB_HOSTNAME=$DB_HOSTNAME
echo "PRIMARY_DB_HOSTNAME: $PRIMARY_DB_HOSTNAME"

. cluster-deploy.sh

COUNT=90
echo sleeping for $COUNT seconds:
for i in `seq 1 $COUNT`
do
  printf "."
  sleep 1
done
echo

echo starting cluster config tool, enter 'add-core <agency-id> <static-gtfs-url> <gtfs-rt-url>' and then 'quit'
. cluster-config.sh

echo "first cluster started on `date`"
echo "run clustered-server-deploy.sh manually after 10 mins"


