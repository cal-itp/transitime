export PGPASSWORD=transitclock

PERFORM_BUILD=1

for i in "$@"; do
  if [ "$i" == "-skip-build" ]; then
    PERFORM_BUILD=0
    shift
  fi
done

if [ "$#" -ne 1 ]; then
  echo "Usage: go.sh <rmi-hostname>" >&2
  exit 1
fi

SAVED_IFS=$IFS
IFS=$'\n'

for i in `docker ps | grep -v ^CONTAINER | grep transitclock-core- | cut -d ' ' -f1`
do
  docker stop $i
  docker rm $i
done

if [ "$PERFORM_BUILD" == "1" ]; then
  for i in `docker ps | grep -v ^CONTAINER | grep transitclock-db- | cut -d ' ' -f1`
  do
    docker stop $i
    docker rm $i
  done
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

PRIMARY_AGENCY_HOST="172.17.0.3"
PRIMARY_AGENCY_ID=halifax
FIRST_PORT=5433
MAPPED_PORT=$FIRST_PORT

for i in `cat agency-list.txt`
do
  AGENCYID=`echo $i|cut -d ' ' -f1`
  GTFS_URL=`echo $i|cut -d ' ' -f2`
  GTFSRTVEHICLEPOSITIONS=`echo $i|cut -d ' ' -f3`

  if [ "$PERFORM_BUILD" == "1" ]; then
    docker build --no-cache -t transitclock-core-$AGENCYID .
    docker run --name transitclock-db-$AGENCYID --rm -p $MAPPED_PORT:5432 -e POSTGRES_PASSWORD=$PGPASSWORD -d postgres:9.6.3

    echo MAPPED_PORT: $MAPPED_PORT
    DB_HOSTNAME=`docker inspect transitclock-db-$AGENCYID | grep -i ipaddress | tail -1 | cut -d '"' -f4`
    echo DB_HOSTNAME: $DB_HOSTNAME

    echo sleeping for a few...
    sleep 5
  else
    echo skipping build...
  fi

  docker run --name transitclock-core-instance-$AGENCYID --rm -e PGPASSWORD=$PGPASSWORD  -v ~/logs:/usr/local/transitclock/logs/ -v ~/ehcache:/usr/local/transitclock/cache/ transitclock-core-$AGENCYID start-core.sh $AGENCYID $GTFS_URL $GTFSRTVEHICLEPOSITIONS $PERFORM_BUILD $1 $DB_HOSTNAME 5432 $PRIMARY_AGENCY_HOST 5432 $PRIMARY_AGENCY_ID

  MAPPED_PORT=`expr $MAPPED_PORT + 1`
done
