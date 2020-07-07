FROM openjdk:10

RUN apt-get update

EXPOSE 1099

WORKDIR /
RUN mkdir -p /usr/local/rmiregistry/bin

RUN curl -X GET -o /usr/local/rmiregistry/bin/start-registry.sh https://storage.googleapis.com/storage/v1/b/transitclock-resources/o/start-registry.sh?alt=media

ENV PATH="/usr/local/rmiregistry/bin:${PATH}"

RUN \
    sed -i 's/\r//' /usr/local/rmiregistry/bin/*.sh &&\
    chmod 777 /usr/local/rmiregistry/bin/*.sh &&\
    start-registry.sh


