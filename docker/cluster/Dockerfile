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

RUN curl -o /usr/local/transitclock/lib/Core.jar https://storage.googleapis.com/transitclock-resources/core/Core.jar
RUN curl -o /usr/local/transitclock/lib/core-admin.jar https://storage.googleapis.com/transitclock-resources/core/core-admin.jar

COPY setup-agency.sh /usr/local/transitclock/bin/setup-agency.sh
COPY create-prop-file.sh /usr/local/transitclock/bin/create-prop-file.sh
COPY delete-db.sh /usr/local/transitclock/bin/delete-db.sh
COPY is-core-running.sh /usr/local/transitclock/bin/is-core-running.sh
COPY kill-core-process.sh /usr/local/transitclock/bin/kill-core-process.sh
COPY start-cluster.sh /usr/local/transitclock/bin/start-cluster.sh
COPY ddl_postgres_org_transitime_db_structs.sql /usr/local/transitclock/db/ddl_postgres_org_transitime_db_structs.sql
COPY ddl_postgres_org_transitime_db_webstructs.sql /usr/local/transitclock/db/ddl_postgres_org_transitime_db_webstructs.sql

RUN chmod 777 /usr/local/transitclock/bin/*.sh

ENV PATH="/usr/local/transitclock/bin:${PATH}"

COPY hibernate.cfg.xml /usr/local/transitclock/config/hibernate.cfg.xml

EXPOSE 6789 1089 1090 1091 1092 1093 1094 1095 1096 1097 1098 1099

CMD start-cluster.sh

