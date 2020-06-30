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

IFS=$SAVED_IFS

docker stop transitclock-db
docker rm transitclock-db

# docker rmi -f transitclock-core

cp ../../hibernate.cfg.xml .
cp ../../transitclock/target/Core.jar .
cp ../../transitclock/src/main/resources/ddl_postgres_org_transitime_db_structs.sql .
cp ../../transitclock/src/main/resources/ddl_postgres_org_transitime_db_webstructs.sql .

docker run --name transitclock-db -p 5432:5432 -e POSTGRES_PASSWORD=$PGPASSWORD -d postgres:9.6.3

SAVED_IFS=$IFS
IFS=$'\n'

for i in `cat agency-list.txt`
do
  AGENCYID=`echo $i|cut -d ' ' -f1`
  GTFS_URL=`echo $i|cut -d ' ' -f2`
  GTFSRTVEHICLEPOSITIONS=`echo $i|cut -d ' ' -f3`

  if [ $PERFORM_BUILD == "1" ]; then
    docker build --no-cache -t transitclock-core-$AGENCYID .
  else
    echo skipping build...
  fi

  docker run --name transitclock-core-instance-$AGENCYID --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD  -v ~/logs:/usr/local/transitclock/logs/ -v ~/ehcache:/usr/local/transitclock/cache/ transitclock-core-$AGENCYID start-core.sh $AGENCYID $GTFS_URL $GTFSRTVEHICLEPOSITIONS /usr/local/transitclock/config/transitclock.properties $1
done
