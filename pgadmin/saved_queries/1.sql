SET LC_MONETARY="nl_NL.utf8";

CREATE DATABASE kasboek
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'nl_NL.utf8'
    LC_CTYPE = 'nl_NL.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

CREATE SCHEMA kasboek;

SET search_path TO kasboek;

CREATE TABLE kasboek.transacties
(
    datum timestamp without time zone,
    naam character varying COLLATE pg_catalog."default",
    rekening character varying COLLATE pg_catalog."default",
    tegenrekening character varying COLLATE pg_catalog."default",
    code character varying COLLATE pg_catalog."default",
    af_bij character varying COLLATE pg_catalog."default",
    bedrag money,
    mutatiesoort character varying COLLATE pg_catalog."default",
    mededeling character varying COLLATE pg_catalog."default"
);

SELECT account_iban, description
FROM transacties t1
LEFT JOIN spaarrekeningen t2 ON t1.opposing_iban = t2.iban
WHERE t2.iban IS null;
