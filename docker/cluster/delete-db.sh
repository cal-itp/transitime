#! /bin/sh

if [ "$#" -ne 4 ]; then
  echo "Usage: delete-db <agency-id> <db-hostname> <primary-agency-db-hostname> <primary-agency-id>" >&2
  exit 1
fi

AGENCY_ID=$1
DB_HOSTNAME=$2
PRIMARY_DB_HOSTNAME=$3
PRIMARY_AGENCY_ID=$4
DBNAME=agency-$AGENCY_ID
DB_PORT=5432

echo AGENCY_ID: $AGENCY_ID
echo DB_HOSTNAME: $DB_HOSTNAME
echo PRIMARY_DB_HOSTNAME: $PRIMARY_DB_HOSTNAME
echo PRIMARY_AGENCY_ID: $PRIMARY_AGENCY_ID
echo DBNAME: $DBNAME

dropdb -h $DB_HOSTNAME -p $DB_PORT -U postgres --if-exists $DBNAME

if psql -U postgres -ltq | grep -q -w agency-$PRIMARY_AGENCY_ID
then
  CMD="psql -h $DB_HOSTNAME -p $DB_PORT -U postgres -q -d agency-$PRIMARY_AGENCY_ID --command=\"delete from webagencies where agencyid='"
  CMD="$CMD$AGENCY_ID';\""
  eval $CMD
fi
