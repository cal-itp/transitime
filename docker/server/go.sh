export PGPASSWORD=transitclock

ID=`docker ps | grep -v ^CONTAINER | grep transitclock-server-instance | cut -d ' ' -f1`

if [ ! -z "$ID" ]
then
  docker stop $ID
  docker rm transitclock-server-instance
fi

cp ../../hibernate.cfg.xml .
cp ../../transitclockApi/target/api.war .
cp ../../transitclockWebapp/target/web.war .

docker build --no-cache -t transitclock-server .

# do we need to link to the postgres container for the server?
docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD  -v ~/logs:/usr/local/transitclock/logs/ -v ~/ehcache:/usr/local/transitclock/cache/  -p 8080:8080 transitclock-server start-server.sh
