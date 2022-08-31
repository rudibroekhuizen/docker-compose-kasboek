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
  
  CREATE TABLE kasboek.transacties_ing
  (
    id INT GENERATED ALWAYS AS IDENTITY,
    datum TIMESTAMP WITHOUT TIME ZONE,
    naam TEXT,
    rekening TEXT,
    tegenrekening TEXT,
    code TEXT,
    af_bij TEXT,
    bedrag MONEY,
    mutatiesoort TEXT,
    mededeling TEXT,
    tsv TSVECTOR
  );
  
  CREATE TRIGGER create_tsv_ing BEFORE INSERT OR UPDATE
  ON kasboek.transacties_ing FOR EACH ROW EXECUTE FUNCTION
  tsvector_update_trigger(tsv, 'pg_catalog.simple', 
  naam,
  rekening,
  tegenrekening,
  mededeling
  );
  
  CREATE TABLE IF NOT EXISTS kasboek.mijn_rekeningen_ing (
  id INT GENERATED ALWAYS AS IDENTITY,
  rekening text
  );
  
EOSQL
