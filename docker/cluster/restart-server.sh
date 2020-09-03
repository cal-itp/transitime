#! /bin/sh

echo 'starting server...'

export JAVA_OPTS="-Dtransitclock.apikey=bfd3d506 \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs \
  -Dtransitclock.configFiles=/usr/local/transitclock/config/transitclock.properties"

echo JAVA_OPTS: $JAVA_OPTS

# /usr/local/tomcat/bin/startup.sh
cat /usr/local/transitclock/config/transitclock.properties
echo
ls -al /usr/local/transitclock/logs

echo 'started server'

