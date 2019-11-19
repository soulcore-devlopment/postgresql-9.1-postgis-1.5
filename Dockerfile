FROM ubuntu:precise

MAINTAINER "Étienne Loks <etienne.loks@iggdrasil.net>"

ENV PG_VERSION=9.1
ENV POSTGIS_VERSION=1.5
ENV PG_DATA=/var/lib/postgresql/$PG_VERSION/main
ENV PG_RUN=$PG_DATA/wasrun

ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

RUN apt-get update && apt-get install -y postgresql postgresql-client postgresql-contrib postgis postgresql-$PG_VERSION-postgis postgresql-plpython postgresql-plpython-$PG_VERSION nano && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/data_directory/##data_directory/g' /etc/postgresql/$PG_VERSION/main/postgresql.conf

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf
RUN echo "data_directory = '${PG_DATA}'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf

RUN chown -R postgres:postgres /etc/postgresql && \
    chmod -R 775 /etc/postgresql

RUN cp /etc/ssl/certs/ssl-cert-snakeoil.pem $PG_DATA/server_.crt
RUN cp /etc/ssl/private/ssl-cert-snakeoil.key $PG_DATA/server_.key

RUN rm $PG_DATA/server.crt
RUN rm $PG_DATA/server.key

RUN mv $PG_DATA/server_.crt $PG_DATA/server.crt
RUN mv $PG_DATA/server_.key $PG_DATA/server.key

RUN mkdir -p /run/postgresql && \
    chown -R postgres:postgres /run/postgresql && \
    chmod -R 775 /run/postgresql

#lrwxrwxrwx 1 postfix input   36 Nov 11 22:59 server.crt -> /etc/ssl/certs/ssl-cert-snakeoil.pem
#lrwxrwxrwx 1 postfix input   38 Nov 11 22:59 server.key -> /etc/ssl/private/ssl-cert-snakeoil.key

#RUN mkdir -p $PG_BASE
#RUN chmod 700 -R $PG_BASE
#RUN chown -v postgres:postgres $PG_BASE

#RUN mkdir -p "$PG_DATA"
#RUN chmod 777 -R "$PG_DATA"
#RUN chown -v postgres:postgres "$PG_DATA"

RUN mkdir -p $PG_DATA && \
    chown -R postgres:postgres $PG_DATA && \
    chmod -R 700 $PG_DATA

# this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)

#VOLUME $PG_DATA
#VOLUME [/var/lib/postgresql/data]

#ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat
RUN chmod -v a+x /docker-entrypoint.sh

EXPOSE 5432/tcp

USER postgres

ENTRYPOINT [ "/bin/bash", "/docker-entrypoint.sh" ]

#CMD [ "/bin/sh", "service postgresql start" ]
#CMD [ "/bin/bash", "-c", "service postgresql start" ]
#CMD ["postgres"]
#USER postgres
#CMD [ "/bin/bash", "-c", "/usr/lib/postgresql/$PG_VERSION/bin/postgres -D $PG_DATA -c config_file=\"/etc/postgresql/$PG_VERSION/main/postgresql.conf\"" ]

CMD [ "/bin/bash", "-c", "/usr/lib/postgresql/$PG_VERSION/bin/postgres -D $PG_DATA -c config_file=\"/etc/postgresql/$PG_VERSION/main/postgresql.conf\"" ]


