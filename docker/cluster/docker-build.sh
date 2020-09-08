#! /bin/sh

cp ../../hibernate.cfg.xml .
cp ../../transitclock/src/main/resources/ddl_postgres_org_transitime_db_structs.sql .
cp ../../transitclock/src/main/resources/ddl_postgres_org_transitime_db_webstructs.sql .

docker build --no-cache -t transitclock-cluster .

