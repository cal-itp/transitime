FROM openjdk:10

RUN apt-get update

EXPOSE 1099

WORKDIR /
RUN mkdir -p /usr/local/rmiregistry/bin

COPY start-registry.sh /usr/local/rmiregistry/bin/start-registry.sh

ENV PATH="/usr/local/rmiregistry/bin:${PATH}"

RUN \
    sed -i 's/\r//' /usr/local/rmiregistry/bin/*.sh &&\
    chmod 777 /usr/local/rmiregistry/bin/*.sh

CMD ["start-registry.sh"]


