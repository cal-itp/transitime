#!/usr/bin/env bash

find /usr/local/transitclock/config/ -type f -exec sed -i s#"POSTGRES_PORT_5432_TCP_ADDR"#"$POSTGRES_PORT_5432_TCP_ADDR"#g {} \;
find /usr/local/transitclock/config/ -type f -exec sed -i s#"POSTGRES_PORT_5432_TCP_PORT"#"$POSTGRES_PORT_5432_TCP_PORT"#g {} \;
find /usr/local/transitclock/config/ -type f -exec sed -i s#"PGPASSWORD"#"$PGPASSWORD"#g {} \;
find /usr/local/transitclock/config/ -type f -exec sed -i s#"AGENCYNAME"#"$AGENCYNAME"#g {} \;

rmiregistry &

echo 'starting server...'

export JAVA_OPTS="-Dtransitclock.apikey=bfd3d506 -Dtransitclock.configFiles=/usr/local/transitclock/config/transitclock.properties"

echo JAVA_OPTS $JAVA_OPTS

/usr/local/tomcat/bin/startup.sh

echo 'started server'

tail -f /dev/null
