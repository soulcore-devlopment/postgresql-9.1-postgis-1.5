#!/bin/bash
# echo "local   all             postgres peer" > "/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
# echo "host all all 0.0.0.0/0 md5" > "/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
# service postgresql restart

set -e

#su postgres;

#if [ `$(psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER --dbname $POSTGRES_DB -c "SELECT 1 as "exist" from pg_database WHERE datname = 'template_postgis';" | grep -q 1) != 1` ]; then

#fi

#if [ ! -s "$PG_DATA" ]; then

if [ ! $(ls -a "${PG_DATA}/wasrun") ]; then

service postgresql start;

psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER --dbname $POSTGRES_DB <<-EOSQL
    ALTER ROLE $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';
EOSQL

psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER --dbname $POSTGRES_DB <<-'EOSQL'
    CREATE DATABASE template_postgis TEMPLATE template0;
EOSQL

psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER template_postgis <<-'EOSQL'
    CREATE EXTENSION plpythonu;
    CREATE EXTENSION "uuid-ossp";
    CREATE EXTENSION fuzzystrmatch;
EOSQL

psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER template_postgis -f /usr/share/postgresql/${PG_VERSION}/contrib/postgis-$POSTGIS_VERSION/postgis.sql; #>/dev/null;
psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER template_postgis -f /usr/share/postgresql/${PG_VERSION}/contrib/postgis-$POSTGIS_VERSION/spatial_ref_sys.sql; #>/dev/null

psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER --dbname $POSTGRES_DB <<-'EOSQL'
    UPDATE pg_database SET datistemplate=true WHERE datname='template_postgis';
EOSQL

su -;

cat /dev/null > "${PG_DATA}/wasrun";
chown postgres:postgres "${PG_DATA}/wasrun";
chmod a+rw "${PG_DATA}/wasrun";

su postgres;

#cat "none" > "${PG_DATA}/wasrun";
#touch "${PG_DATA}/wasrun";
#chmod 777 "${PG_DATA}/wasrun";

service postgresql stop;

fi

exec "$@"

# the eosql need a identation (tab)
#psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-'EOSQL'
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