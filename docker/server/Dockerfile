FROM openjdk:10

ENV TRANSITCLOCK_CORE /transitclock-core

RUN apt-get update \
    && apt-get install -y postgresql-client \
    && apt-get install -y vim

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.56
ENV TOMCAT_TGZ_URL https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -x \
    && curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm bin/*.bat \
    && rm tomcat.tar.gz*

EXPOSE 8080

WORKDIR /
RUN mkdir /usr/local/transitclock
RUN mkdir /usr/local/transitclock/db
RUN mkdir /usr/local/transitclock/config
RUN mkdir /usr/local/transitclock/logs
RUN mkdir /usr/local/transitclock/cache
RUN mkdir /usr/local/transitclock/data

WORKDIR /usr/local/transitclock

# RUN  curl -s https://api.github.com/repos/TheTransitClock/transitime/releases/latest | jq -r ".assets[].browser_download_url" | grep 'Core.jar\|api.war\|web.war' | xargs -L1 wget

COPY api.war $CATALINA_HOME/webapps
COPY web.war $CATALINA_HOME/webapps
COPY hibernate.cfg.xml /usr/local/transitclock/config/hibernate.cfg.xml
COPY start-server.sh /usr/local/transitclock/bin/start-server.sh
COPY create-prop-file.sh /usr/local/transitclock/bin/create-prop-file.sh

ENV PATH="/usr/local/transitclock/bin:${PATH}"

RUN \
    sed -i 's/\r//' /usr/local/transitclock/bin/*.sh &&\
    chmod 777 /usr/local/transitclock/bin/*.sh

