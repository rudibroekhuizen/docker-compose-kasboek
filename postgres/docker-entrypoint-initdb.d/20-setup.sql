--
-- Create database
SET LC_MONETARY="nl_NL.utf8";
CREATE DATABASE kasboek
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'nl_NL.utf8'
    LC_CTYPE = 'nl_NL.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to database
\connect kasboek

CREATE EXTENSION pg_trgm;


-- ING
CREATE TABLE transacties_ing
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
ON transacties_ing FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(tsv, 'pg_catalog.simple', 
  naam,
  rekening,
  tegenrekening,
  mededeling
);


-- ASN
CREATE TABLE transacties_asn
(
  id INT GENERATED ALWAYS AS IDENTITY,
  boekingsdatum TEXT,
  opdrachtgeversrekening TEXT,
  tegenrekeningnummer TEXT,
  naam_tegenrekening TEXT,
  adres TEXT,
  postcode TEXT,
  plaats TEXT,
  valutasoort_rekening TEXT,
  saldo_rekening_voor_mutatie TEXT,
  valutasoort_mutatie TEXT,
  transactiebedrag TEXT,
  journaaldatum TEXT,
  valutadatum TEXT,
  interne_transactiecode TEXT,
  globale_transactiecode TEXT,
  volgnummer_transactie TEXT,
  betalingskenmerk TEXT,
  omschrijving TEXT,
  afschriftnummer TEXT,
  tsv TSVECTOR
);

CREATE TRIGGER create_tsv_asn BEFORE INSERT OR UPDATE
ON transacties_asn FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(tsv, 'pg_catalog.simple', 
  opdrachtgeversrekening,
  tegenrekeningnummer,
  naam_tegenrekening,
  omschrijving
);


-- All
CREATE TABLE IF NOT EXISTS mijn_rekeningen (
id INT GENERATED ALWAYS AS IDENTITY,
rekening text
);
