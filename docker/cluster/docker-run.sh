#! /bin/sh

function checkVar() {
    if [ "$#" -ne 2 ]
    then
      echo env variable $1 not set
      exit 0
    fi
}

checkVar $RMI_HOST "RMI_HOST"
checkVar $DB_HOSTNAME "DB_HOSTNAME"
checkVar $PRIMARY_DB_HOSTNAME "PRIMARY_DB_HOSTNAME"
checkVar $PRIMARY_AGENCY_ID "PRIMARY_AGENCY_ID"

docker run --name transitclock-cluster-1 --rm -e PGPASSWORD=$PGPASSWORD -e RMI_HOST=$RMI_HOST -e DB_HOSTNAME=$DB_HOSTNAME -e PRIMARY_DB_HOSTNAME=$PRIMARY_DB_HOSTNAME -e PRIMARY_AGENCY_ID=$PRIMARY_AGENCY_ID -p 127.0.0.1:6789:6789 -p 127.0.0.1:1089:1089 -p 127.0.0.1:1090:1090 -p 127.0.0.1:1091:1091 transitclock-cluster
