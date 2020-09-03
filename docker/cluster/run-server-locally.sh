#! /bin/sh

# web app will run at localhost:8080/web

if [ "$#" -ne 1 ]; then
  echo "usage: run-server-locally.sh \<primary-config-file\>"
  exit 0
fi

CONFIG_FILE=$1
RMI_PID=`ps -ef | grep rmiregistry | grep -v grep | awk '{print $2}'`

if [ -z "$RMI_PID" ]; then
    echo rmiregistry not running...
    # rmiregistry &
fi

cp ~/projects/transitime/transitclockApi/target/api.war ~/tools/apache-tomcat-8.5.56/webapps || exit 0
cp ~/projects/transitime/transitclockWebapp/target/web.war ~/tools/apache-tomcat-8.5.56/webapps || exit 0

export JAVA_OPTS="-Dtransitclock.apikey=bfd3d506 \
-Dtransitclock.configFiles=$CONFIG_FILE \
-Dtransitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml"

echo JAVA_OPTS: $JAVA_OPTS

~/tools/apache-tomcat-8.5.56/bin/startup.sh

