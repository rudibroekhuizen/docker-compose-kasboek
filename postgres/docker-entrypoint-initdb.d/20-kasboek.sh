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
  
  CREATE TRIGGER create_tsv BEFORE INSERT OR UPDATE
  ON kasboek.transacties FOR EACH ROW EXECUTE FUNCTION
  tsvector_update_trigger(tsv, 'pg_catalog.simple', 
  naam,
  rekening,
  tegenrekening,
  mededeling
  );
  
  COPY kasboek.transacties (datum, naam, rekening, tegenrekening, code, af_bij, bedrag, mutatiesoort, mededeling) 
  FROM '/mnt/miniodata/kasboek/transacties.csv' csv header;

  CREATE TABLE kasboek.words AS SELECT * FROM ts_stat('SELECT tsv FROM kasboek.transacties');

  CREATE INDEX ON kasboek.words USING gin (word gin_trgm_ops);

  CREATE TABLE IF NOT EXISTS kasboek.mijn_rekeningen (
  id INT GENERATED ALWAYS AS IDENTITY,
  rekening text
  );
  
EOSQL
