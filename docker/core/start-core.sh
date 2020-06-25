#!/usr/bin/env bash
echo 'starting core...'

java \
  -Dtransitclock.configFiles=/usr/local/transitclock/config/transitclock.properties \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs \
  -Dtransitclock.rmi.secondaryRmiPort=0 \
  -jar /usr/local/transitclock/lib/Core.jar

tail -f /dev/null
