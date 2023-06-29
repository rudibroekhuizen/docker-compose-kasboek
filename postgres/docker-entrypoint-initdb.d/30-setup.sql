--
-- Connect to database
\connect kasboek

-- Insert ING transactions
CREATE OR REPLACE PROCEDURE copy_from_ing(
   _source_file text
) AS
$$
BEGIN
  EXECUTE format('COPY transacties_ing_raw (
    datum,
    naam,
    rekening,
    tegenrekening,
    code,
    af_bij,
    bedrag,
    mutatiesoort,
    mededeling
    ) FROM %L csv header', _source_file);
  MERGE INTO transacties_ing ti
  USING transacties_ing_raw tir  
  ON (ti.md5_hash = tir.md5_hash)
  WHEN MATCHED THEN
  UPDATE SET
    datum = tir.datum,
    naam = tir.naam,
    rekening = tir.rekening,
    tegenrekening = tir.tegenrekening,
    code = tir.code,
    af_bij = tir.af_bij,
    bedrag = tir.bedrag,
    mutatiesoort = tir.mutatiesoort,
    mededeling = tir.mededeling,
    md5_hash = tir.md5_hash
  WHEN NOT MATCHED THEN
  INSERT (
    datum,
    naam,
    rekening,
    tegenrekening,
    code,
    af_bij,
    bedrag,
    mutatiesoort,
    mededeling,
    md5_hash)
  VALUES (
    tir.datum,
    tir.naam,
    tir.rekening,
    tir.tegenrekening,
    tir.code,
    tir.af_bij,
    tir.bedrag,
    tir.mutatiesoort,
    tir.mededeling,
    tir.md5_hash);
  TRUNCATE TABLE words_ing;
  INSERT INTO words_ing SELECT * FROM ts_stat('SELECT tsv FROM transacties_ing');
  COMMIT; 
END;
$$ LANGUAGE plpgsql;

-- CALL copy_from_ing('/mnt/miniodata/kasboek/transacties_ing.csv');


-- Insert ASN transactions
CREATE OR REPLACE PROCEDURE public.copy_from_asn(
	IN _source_file text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
  EXECUTE format('COPY transacties_asn_raw (
    boekingsdatum,
    opdrachtgeversrekening,
    tegenrekeningnummer,
    naam_tegenrekening,
    adres,
    postcode,
    plaats,
    valutasoort_rekening,
    saldo_rekening_voor_mutatie,
    valutasoort_mutatie,
    transactiebedrag,
    journaaldatum,
    valutadatum,
    interne_transactiecode,
    globale_transactiecode,
    volgnummer_transactie,
    betalingskenmerk,
    omschrijving,
    afschriftnummer
    ) FROM %L csv header', _source_file);
  MERGE INTO transacties_asn ta
  USING transacties_asn_raw tar
  ON MD5(ROW(ta.boekingsdatum, ta.tegenrekeningnummer, ta.naam_tegenrekening, ta.transactiebedrag, ta.journaaldatum, ta.volgnummer_transactie, ta.omschrijving)::text) = MD5(ROW(tar.boekingsdatum, tar.tegenrekeningnummer, tar.naam_tegenrekening, tar.transactiebedrag, tar.journaaldatum, tar.volgnummer_transactie, tar.omschrijving)::text)
  WHEN MATCHED THEN DO NOTHING
  WHEN NOT MATCHED THEN
  INSERT (
    boekingsdatum,
    opdrachtgeversrekening,
    tegenrekeningnummer,
    naam_tegenrekening,
    adres,
    postcode,
    plaats,
    valutasoort_rekening,
    saldo_rekening_voor_mutatie,
    valutasoort_mutatie,
    transactiebedrag,
    journaaldatum,
    valutadatum,
    interne_transactiecode,
    globale_transactiecode,
    volgnummer_transactie,
    betalingskenmerk,
    omschrijving,
    afschriftnummer)
  VALUES (
    tar.boekingsdatum,
    tar.opdrachtgeversrekening,
    tar.tegenrekeningnummer,
    tar.naam_tegenrekening,
    tar.adres,
    tar.postcode,
    tar.plaats,
    tar.valutasoort_rekening,
    tar.saldo_rekening_voor_mutatie,
    tar.valutasoort_mutatie,
    tar.transactiebedrag,
    tar.journaaldatum,
    tar.valutadatum,
    tar.interne_transactiecode,
    tar.globale_transactiecode,
    tar.volgnummer_transactie,
    tar.betalingskenmerk,
    tar.omschrijving,
    tar.afschriftnummer);
  COMMIT;
  TRUNCATE TABLE words_asn;
  INSERT INTO words_asn SELECT * FROM ts_stat('SELECT tsv FROM transacties_asn');
END;
$BODY$;
ALTER PROCEDURE public.copy_from_asn(text)
    OWNER TO postgres;

-- CALL copy_from_asn('/mnt/miniodata/kasboek/transacties_asn.csv');
--
