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
CREATE TABLE transacties_ing_raw
(
  datum TIMESTAMP WITHOUT TIME ZONE,
  naam TEXT,
  rekening TEXT,
  tegenrekening TEXT,
  code TEXT,
  af_bij TEXT,
  bedrag MONEY,
  mutatiesoort TEXT,
  mededeling TEXT,
  md5_hash UUID
);

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
  md5_hash UUID,
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

CREATE TABLE words_ing
(
  word text,
  ndoc integer,
  nentry integer
);

CREATE INDEX words_ing_word_idx
ON words_ing USING gin
(word gin_trgm_ops);

CREATE OR REPLACE function create_md5_hash_ing() RETURNS TRIGGER AS 
$$
  BEGIN 
    NEW.md5_hash := md5(ROW(NEW.datum, NEW.naam, NEW.rekening, NEW.tegenrekening, NEW.code, NEW.af_bij, NEW.bedrag, NEW.mutatiesoort, NEW.mededeling)::text)::uuid;
    RETURN NEW;
  END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER create_md5_hash_ing BEFORE INSERT OR UPDATE ON transacties_ing_raw FOR EACH ROW EXECUTE PROCEDURE create_md5_hash_ing();


-- ASN
CREATE TABLE transacties_asn_raw
(
  boekingsdatum TIMESTAMP WITHOUT TIME ZONE,
  opdrachtgeversrekening TEXT,
  tegenrekeningnummer TEXT,
  naam_tegenrekening TEXT,
  adres TEXT,
  postcode TEXT,
  plaats TEXT,
  valutasoort_rekening TEXT,
  saldo_rekening_voor_mutatie MONEY,
  valutasoort_mutatie TEXT,
  transactiebedrag MONEY,
  journaaldatum TEXT,
  valutadatum TEXT,
  interne_transactiecode TEXT,
  globale_transactiecode TEXT,
  volgnummer_transactie TEXT,
  betalingskenmerk TEXT,
  omschrijving TEXT,
  afschriftnummer TEXT
);

CREATE TABLE transacties_asn
(
  id INT GENERATED ALWAYS AS IDENTITY,
  boekingsdatum TIMESTAMP WITHOUT TIME ZONE,
  opdrachtgeversrekening TEXT,
  tegenrekeningnummer TEXT,
  naam_tegenrekening TEXT,
  adres TEXT,
  postcode TEXT,
  plaats TEXT,
  valutasoort_rekening TEXT,
  saldo_rekening_voor_mutatie MONEY,
  valutasoort_mutatie TEXT,
  transactiebedrag MONEY,
  journaaldatum TEXT,
  valutadatum TEXT,
  interne_transactiecode TEXT,
  globale_transactiecode TEXT,
  volgnummer_transactie TEXT,
  betalingskenmerk TEXT,
  omschrijving TEXT,
  afschriftnummer TEXT,
  af_bij TEXT,
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

CREATE TABLE words_asn
(
  word text,
  ndoc integer,
  nentry integer
);

CREATE INDEX words_asn_word_idx
ON words_asn USING gin
(word gin_trgm_ops);

--CREATE OR REPLACE function create_md5_hash_asn() RETURNS TRIGGER AS 
--$$
--  BEGIN 
--    NEW.md5_hash := md5(ROW(NEW.boekingsdatum, NEW.tegenrekeningnummer, NEW.naam_tegenrekening, NEW.transactiebedrag, NEW.journaaldatum, NEW.volgnummer_transactie, NEW.omschrijving)::text)::uuid;
--    RETURN NEW;
--  END;
--$$ LANGUAGE 'plpgsql';

--CREATE TRIGGER create_md5_hash_asn BEFORE INSERT OR UPDATE ON transacties_asn_raw FOR EACH ROW EXECUTE PROCEDURE create_md5_hash_asn();

-- Populate column af_bij
CREATE OR REPLACE function create_sign_asn() RETURNS TRIGGER AS 
$$
  BEGIN 
    NEW.af_bij := SIGN(NEW.transactiebedrag::numeric);
    RETURN NEW;
  END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER create_sign_asn BEFORE INSERT OR UPDATE ON transacties_asn FOR EACH ROW EXECUTE PROCEDURE create_sign_asn();


-- All
CREATE TABLE IF NOT EXISTS mijn_rekeningen (
id INT GENERATED ALWAYS AS IDENTITY,
rekening text
);
--
