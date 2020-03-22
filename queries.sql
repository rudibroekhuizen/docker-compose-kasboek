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
    mededeling character varying COLLATE pg_catalog."default",
    tsvector tsvector
);

CREATE TABLE IF NOT EXISTS kasboek.mijn_rekeningen (
  id INT GENERATED ALWAYS AS IDENTITY,
  rekening text
);

INSERT INTO kasboek.mijn_rekeningen(rekening) VALUES ('NLxxINGB000xxxxxxx'); 

COPY kasboek.transacties (datum, naam, rekening, tegenrekening, code, af_bij, bedrag, mutatiesoort, mededeling) FROM '/mnt/miniodata/bucket/yourcsv.csv' csv header;

UPDATE kasboek.transacties SET tsvector = to_tsvector('simple', COALESCE(transacties.naam) || ' ' || COALESCE(transacties.rekening) || ' ' || COALESCE(transacties.tegenrekening) || ' ' || COALESCE(transacties.code) || ' ' || COALESCE(transacties.af_bij) || ' ' || COALESCE(transacties.mutatiesoort) || ' ' || COALESCE(transacties.mededeling));

CREATE TABLE kasboek.words AS SELECT * FROM ts_stat('SELECT tsvector FROM kasboek.transacties');

CREATE INDEX ON kasboek.words USING gin (word gin_trgm_ops);

SELECT t1.rekening, t1.tegenrekening, t1.naam, t1.mededeling
FROM kasboek.transacties t1
LEFT JOIN kasboek.spaarrekeningen t2 ON t1.tegenrekening = t2.rekening
WHERE t2.rekening IS null
AND tsvector @@ websearch_to_tsquery('simple','ikea');
