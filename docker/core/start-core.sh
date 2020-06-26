#!/usr/bin/env bash

setup-agency.sh $1 $2 $3 $4

echo 'starting core...'

java \
  -Dtransitclock.configFiles=/usr/local/transitclock/config/transitclock.properties \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs \
  -Dtransitclock.rmi.secondaryRmiPort=0 \
  -jar /usr/local/transitclock/lib/Core.jar

echo 'started core'

tail -f /dev/null
