
#/usr/bin/env bash
# echo "local   all             postgres peer" > "/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
# echo "host all all 0.0.0.0/0 md5" > "/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
# service postgresql restart
#!/bin/bash

#set -e


#su postgres;

#if [ `$(/usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER --dbname $POSTGRES_DB -c "SELECT 1 as "exist" from pg_database WHERE datname = 'template_postgis';" | grep -q 1) != 1` ]; then
#fi


#_!/bin/bash


#if [ "$1" = 'postgres' ]; then
#    chown -R postgres "$PGDATA"

#    if [ -z "$(ls -A "$PGDATA")" ]; then
#        gosu postgres initdb
#    fi

#    exec gosu postgres "$@"
#fi

#exec "$@"

#if [ "$1" = 'postgres' ]; then

#fi
set -e

#if [ ! -s "$PG_RUN" ]; then
echo "(no file?):${PG_RUN}"

if [ ! $(ls -a ${PG_RUN}) ]; then
#if [ -z "$(ls -A "$PG_DATA")" ]; then
   
    echo "(no):${PG_RUN}"

    echo "(starting postgres)"

    #service postgresql start
    #/usr/lib/postgresql/$PG_VERSION/bin/pg_ctl initdb --pgdata $PG_DATA -w
    #--silent
    /usr/lib/postgresql/$PG_VERSION/bin/pg_ctl start --pgdata $PG_DATA -w -o "'--config-file=/etc/postgresql/${PG_VERSION}/main/postgresql.conf'";

    #/usr/lib/postgresql/$PG_VERSION/bin/pg_ctl initdb --pgdata $PG_DATA && \
    #/usr/lib/postgresql/$PG_VERSION/bin/postgres -D $PG_DATA -c config_file="/etc/postgresql/$PG_VERSION/main/postgresql.conf";
    
    echo "(alter role)" #--username "$POSTGRES_USER"
    /usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 --dbname "$POSTGRES_DB" <<-EOSQL
    ALTER ROLE $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';
EOSQL

    echo "(create template_postgis)"
    /usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 --dbname "$POSTGRES_DB" <<-'EOSQL'
    CREATE DATABASE template_postgis WITH        
        TEMPLATE = template0
        ENCODING = 'UTF8';
EOSQL
    echo "(add extensions)"
    /usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 template_postgis <<-'EOSQL'
    CREATE EXTENSION plpythonu;
    CREATE EXTENSION "uuid-ossp";
    CREATE EXTENSION fuzzystrmatch;
EOSQL

    echo "(run postgis files)"
    /usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 template_postgis -f /usr/share/postgresql/${PG_VERSION}/contrib/postgis-$POSTGIS_VERSION/postgis.sql; #>/dev/null;
    /usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 template_postgis -f /usr/share/postgresql/${PG_VERSION}/contrib/postgis-$POSTGIS_VERSION/spatial_ref_sys.sql; #>/dev/null
    
    echo "(set database as template)";
    /usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 --dbname "$POSTGRES_DB" <<-'EOSQL'
    UPDATE pg_database SET datistemplate=true WHERE datname='template_postgis';
EOSQL

    #cat "none" > "${PG_DATA}/wasrun";
    #touch "${PG_DATA}/wasrun";
    #chmod 777 "${PG_DATA}/wasrun";

    cat /dev/null > "${PG_RUN}";
    echo "(created): ${PG_RUN}"
    #chown postgres:postgres "${PG_DATA}/wasrun";
    #chmod a+rwx "${PG_DATA}/wasrun";

    echo "stop service ..."
    #service postgresql stop 
    #--silent
    /usr/lib/postgresql/$PG_VERSION/bin/pg_ctl stop --pgdata $PG_DATA -w;
    #kill -INT `head -1 $PG_DATA/postmaster.pid`
    #kill -TERM `head -1 $PG_DATA/postmaster.pid`;

    echo "xxxxx"
    exec "$@";
    
    #cat /dev/null > "$PG_DATA/wasrun";
    #chown postgres:postgres "$PG_DATA/wasrun";
    #chmod 775 "$PG_DATA/wasrun";

fi

exec "$@";

# the eosql need a identation (tab)
#/usr/lib/postgresql/$PG_VERSION/bin/psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-'EOSQL'
#DO $$DECLARE r record;
#BEGIN
#    FOR r IN SELECT table_schema, table_name FROM information_schema.tables
#            WHERE table_type = 'VIEW' AND table_schema = 'public'
#    LOOP
#        EXECUTE 'GRANT ALL ON ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || ' TO webuser';
#    END LOOP;
#END$$;

#DO $$
#    DECLARE exist integer;
#BEGIN
#    SELECT 1 INTO exist from pg_database WHERE datname = 'template_postgis';
#
#    IF exist = 1 THEN
#        CREATE DATABASE template_postgis;
#
#        PERFORM exist;
#    END IF;
#END $$;
#EOSQL