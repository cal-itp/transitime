#! /bin/sh

while [ 1 ]
do
    echo '------------------- starting core admin tool -------------------'
    java -jar /usr/local/transitclock/lib/core-admin.jar -port 6789
done