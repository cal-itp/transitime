export PGPASSWORD=transitclock

PERFORM_BUILD=1
PRESERVE_DB=1

for i in "$@"; do
  if [ "$i" == "-skip-build" ]; then
    PERFORM_BUILD=0
    shift
  fi
  if [ "$i" == "-kill-db" ]; then
    PRESERVE_DB=0
    shift
  fi
done

if [ "$#" -ne 2 ]; then
  echo "Usage: go.sh <agency-id> <rmi-hostname>" >&2
  exit 1
fi

AGENCY_ID=$1
RMI_HOSTNAME=$2

LINE=`grep "^$AGENCY_ID " agency-list.txt`

if [ -z "$LINE" ]; then
  echo cannot find agency ID $AGENCY_ID in agency-list.txt
  exit 1
fi

GTFS_URL=`echo $LINE | cut -d ' ' -f2`
echo GTFS_URL: $GTFS_URL

VEHICLE_POSITIONS_URL=`echo $LINE | cut -d ' ' -f3`
echo VEHICLE_POSITIONS_URL: $VEHICLE_POSITIONS_URL

SAVED_IFS=$IFS
IFS=$'\n'

ID=`docker ps | grep -v ^CONTAINER | grep transitclock-core-$AGENCY_ID | cut -d ' ' -f1`

if [ ! -z "$ID" ]; then
  docker stop $ID
  docker rm $ID
fi

if [ "$PRESERVE_DB" == "0" ]; then
  ID=`docker ps | grep -v ^CONTAINER | grep transitclock-db-$AGENCY_ID | cut -d ' ' -f1`

  if [ ! -z "$ID" ]; then
    docker stop $ID
    docker rm $ID
  fi
fi

IFS=$SAVED_IFS

if [ "$PERFORM_BUILD" == "1" ]; then
  cp ../../hibernate.cfg.xml .
  cp ../../transitclock/target/Core.jar .
  cp ../../transitclock/src/main/resources/ddl_postgres_org_transitime_db_structs.sql .
  cp ../../transitclock/src/main/resources/ddl_postgres_org_transitime_db_webstructs.sql .
fi

SAVED_IFS=$IFS
IFS=$'\n'

if [ "$PERFORM_BUILD" == "1" ]; then
  docker build --no-cache -t transitclock-core .
fi

PRIMARY_AGENCY_HOST="172.17.0.3"
PRIMARY_AGENCY_ID=`head -1 agency-list.txt | cut -d ' ' -f1`

if [ "$PRESERVE_DB" == "0" ]; then
  docker run --name transitclock-db-$AGENCY_ID --rm -e POSTGRES_PASSWORD=$PGPASSWORD -d postgres:9.6.3

  echo sleeping for a few...
  sleep 5
else
  echo skipping build...
fi

DB_HOSTNAME=`docker inspect transitclock-db-$AGENCY_ID | grep -i ipaddress | tail -1 | cut -d '"' -f4`
echo DB_HOSTNAME: $DB_HOSTNAME

docker run --name transitclock-core-$AGENCY_ID --rm -e PGPASSWORD=$PGPASSWORD transitclock-core start-core.sh \
  $AGENCY_ID $GTFS_URL $VEHICLE_POSITIONS_URL $PRESERVE_DB $RMI_HOSTNAME $DB_HOSTNAME \
  5432 $PRIMARY_AGENCY_HOST 5432 $PRIMARY_AGENCY_ID
