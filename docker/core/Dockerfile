FROM openjdk:10

RUN apt-get update \
	&& apt-get install -y postgresql-client \
    && apt-get install -y vim

WORKDIR /
RUN mkdir /usr/local/transitclock
RUN mkdir /usr/local/transitclock/db
RUN mkdir /usr/local/transitclock/config
RUN mkdir /usr/local/transitclock/lib
RUN mkdir /usr/local/transitclock/logs
RUN mkdir /usr/local/transitclock/cache
RUN mkdir /usr/local/transitclock/data

WORKDIR /usr/local/transitclock

COPY Core.jar /usr/local/transitclock/lib/Core.jar
COPY setup-agency.sh /usr/local/transitclock/bin/setup-agency.sh
COPY create-prop-file.sh /usr/local/transitclock/bin/create-prop-file.sh
COPY start-core.sh /usr/local/transitclock/bin/start-core.sh
COPY ddl_postgres_org_transitime_db_structs.sql /usr/local/transitclock/db/ddl_postgres_org_transitime_db_structs.sql
COPY ddl_postgres_org_transitime_db_webstructs.sql /usr/local/transitclock/db/ddl_postgres_org_transitime_db_webstructs.sql

RUN chmod 777 /usr/local/transitclock/bin/*.sh

ENV PATH="/usr/local/transitclock/bin:${PATH}"

COPY hibernate.cfg.xml /usr/local/transitclock/config/hibernate.cfg.xml

CMD start-core.sh $AGENCY_ID $GTFS_URL $VEHICLE_POSITIONS_URL $PRESERVE_DB $RMI_HOSTNAME $DB_HOSTNAME 5432 $PRIMARY_AGENCY_HOST 5432 $PRIMARY_AGENCY_ID

