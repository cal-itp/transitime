export PGPASSWORD=transitclock

PERFORM_BUILD=1

for i in "$@"; do
  if [ "$i" == "-skip-build" ]; then
    PERFORM_BUILD=0
    shift
  fi
done

ID=`docker ps | grep -v ^CONTAINER | grep transitclock-server-instance | cut -d ' ' -f1`

if [ ! -z "$ID" ]
then
  docker stop $ID
  docker rm $ID
fi

cp ../../hibernate.cfg.xml .
cp ../../transitclockApi/target/api.war .
cp ../../transitclockWebapp/target/web.war .
cp ../core/create-prop-file.sh .

if [ $PERFORM_BUILD == "1" ]; then
  docker build --no-cache -t transitclock-server .
fi

PRIMARY_AGENCY_ID=`head -1 ../core/agency-list.txt | cut -d ' '  -f1`
echo PRIMARY_AGENCY_ID: $PRIMARY_AGENCY_ID

LINE=`grep "^$PRIMARY_AGENCY_ID " ../core/agency-list.txt`

GTFS_URL=`echo $LINE | cut -d ' ' -f2`
echo GTFS_URL: $GTFS_URL

VEHICLE_POSITIONS_URL=`echo $LINE | cut -d ' ' -f3`
echo VEHICLE_POSITIONS_URL: $VEHICLE_POSITIONS_URL

RMI_HOSTNAME=`docker inspect transitclock-rmi-registry-instance | grep -i ipaddress | tail -1 | cut -d \" -f4`
echo RMI_HOSTNAME: $RMI_HOSTNAME

DB_HOSTNAME=`docker inspect transitclock-db-$PRIMARY_AGENCY_ID | grep -i ipaddress | tail -1 | cut -d \" -f4`
echo DB_HOSTNAME: $DB_HOSTNAME

docker run --name transitclock-server-instance --rm -e PGPASSWORD=$PGPASSWORD -p 8080:8080 transitclock-server start-server.sh $PRIMARY_AGENCY_ID $GTFS_URL $VEHICLE_POSITIONS_URL $RMI_HOSTNAME $DB_HOSTNAME
