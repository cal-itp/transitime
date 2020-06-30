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
  docker rm transitclock-server-instance
fi

cp ../../hibernate.cfg.xml .
cp ../../transitclockApi/target/api.war .
cp ../../transitclockWebapp/target/web.war .

if [ $PERFORM_BUILD == "1" ]; then
  docker build --no-cache -t transitclock-server .
fi

# do we need to link to the postgres container for the server?
docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD  -v ~/logs:/usr/local/transitclock/logs/ -v ~/ehcache:/usr/local/transitclock/cache/  -p 8080:8080 transitclock-server start-server.sh
