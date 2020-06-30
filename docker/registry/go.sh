PERFORM_BUILD=1

for i in "$@"; do
  if [ "$i" == "-skip-build" ]; then
    PERFORM_BUILD=0
    shift
  fi
done

ID=`docker ps | grep -v ^CONTAINER | grep transitclock-rmi-registry-instance | cut -d ' ' -f1`

if [ ! -z "$ID" ]
then
  docker stop $ID
  docker rm $ID
fi

if [ $PERFORM_BUILD == "1" ]; then
  docker build --no-cache -t transitclock-rmi-registry .
fi

docker run --name transitclock-rmi-registry-instance --rm  -p 1099:1099 transitclock-rmi-registry start-registry.sh
