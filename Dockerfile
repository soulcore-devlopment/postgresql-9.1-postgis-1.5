FROM ubuntu:precise

MAINTAINER "Étienne Loks <etienne.loks@iggdrasil.net>"

ENV PG_VERSION=9.1
ENV POSTGIS_VERSION=1.5
ENV PG_DATA=/var/lib/postgresql/data
 	
RUN apt-get update && apt-get install -y postgresql postgresql-client postgresql-contrib postgis postgresql-$PG_VERSION-postgis postgresql-plpython postgresql-plpython-$PG_VERSION nano 

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf

ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

#ADD docker-entrypoint.sh /docker-entrypoint.sh
#RUN chmod -v +x /docker-entrypoint.sh
RUN mkdir -p "$PG_DATA"
RUN chmod 775 -R "$PG_DATA"
RUN chown postgres:postgres "$PG_DATA"

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 775 /docker-entrypoint.sh
#RUN chmod -v +x /docker-entrypoint.sh

USER postgres
ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE 5432/tcp
#VOLUME [ "/etc/postgresql/$PG_VERSION", "/var/log/postgresql/$PG_VERSION", "/var/lib/postgresql/$PG_VERSION" ]
VOLUME [ "$PG_DATA" ]

CMD [ "/bin/bash", "-c", "\"/usr/lib/postgresql/$PG_VERSION/bin/postgres\" -D \"$PG_DATA\" -c config_file=\"/etc/postgresql/$PG_VERSION/main/postgresql.conf\"" ]