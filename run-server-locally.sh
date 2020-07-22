#! /bin/sh

# web app will run at localhost:8080/web

RMI_PID=`ps -ef | grep rmiregistry | grep -v grep | awk '{print $2}'`

if [ -z "$RMI_PID" ]; then
    echo rmiregistry not running...
    # rmiregistry &
fi

cp transitclockApi/target/api.war ~/tools/apache-tomcat-8.5.56/webapps || exit 0
cp transitclockWebapp/target/web.war ~/tools/apache-tomcat-8.5.56/webapps || exit 0

export JAVA_OPTS="-Dtransitclock.apikey=bfd3d506 \
-Dtransitclock.configFiles=halifax.properties \
-Dtransitclock.hibernate.configFile=hibernate.cfg.xml"

echo JAVA_OPTS: $JAVA_OPTS

~/tools/apache-tomcat-8.5.56/bin/startup.sh

