#!/usr/bin/env bash

if [ "$4" == "0" ]; then
  setup-agency.sh $1 $2 $3 $6 $7 $8 $9 ${10}
else
  create-prop-file.sh $1 $2 $3 $6 $7
fi

echo 'starting core...'

java \
  -Dtransitclock.configFiles=/usr/local/transitclock/config/transitclock.properties \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs \
  -Dtransitclock.rmi.rmiHost=$5 \
  -jar /usr/local/transitclock/lib/Core.jar

echo 'started core'

tail -f /dev/null
