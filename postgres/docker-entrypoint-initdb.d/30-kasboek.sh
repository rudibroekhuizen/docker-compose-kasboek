#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" <<-EOSQL
  SET LC_MONETARY="nl_NL.utf8";
  CREATE DATABASE kasboek
      WITH 
      OWNER = postgres
      ENCODING = 'UTF8'
      LC_COLLATE = 'nl_NL.utf8'
      LC_CTYPE = 'nl_NL.utf8'
      TABLESPACE = pg_default
      CONNECTION LIMIT = -1;
EOSQL

psql --dbname=kasboek -v ON_ERROR_STOP=1 --username="$POSTGRES_USER" <<-EOSQL
  CREATE EXTENSION pg_trgm;
  
  CREATE SCHEMA kasboek;
  
  CREATE TABLE kasboek.transacties
  (
    id INT GENERATED ALWAYS AS IDENTITY,
    datum timestamp without time zone,
    naam character varying COLLATE pg_catalog."default",
    rekening character varying COLLATE pg_catalog."default",
    tegenrekening character varying COLLATE pg_catalog."default",
    code character varying COLLATE pg_catalog."default",
    af_bij character varying COLLATE pg_catalog."default",
    bedrag money,
    mutatiesoort character varying COLLATE pg_catalog."default",
    mededeling character varying COLLATE pg_catalog."default",
    tsvector tsvector
  );
  
  CREATE TRIGGER create_tsv BEFORE INSERT OR UPDATE
  ON kasboek.transacties FOR EACH ROW EXECUTE FUNCTION
  tsvector_update_trigger(tsvector, 'pg_catalog.simple', 
  naam,
  rekening,
  tegenrekening,
  code,
  mededeling
  );
EOSQL
