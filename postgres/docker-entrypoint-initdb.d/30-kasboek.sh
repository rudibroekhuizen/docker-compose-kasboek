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
  CREATE SCHEMA kasboek;
  CREATE TABLE kasboek.transactions
  (
    date timestamp without time zone,
    opposing_name character varying COLLATE pg_catalog."default",
    account_iban character varying COLLATE pg_catalog."default",
    opposing_iban character varying COLLATE pg_catalog."default",
    type character varying COLLATE pg_catalog."default",
    debit_credit character varying COLLATE pg_catalog."default",
    amount money,
    method character varying COLLATE pg_catalog."default",
    description character varying COLLATE pg_catalog."default"
  )
  WITH (
      OIDS = FALSE
  )
  TABLESPACE pg_default;
EOSQL
