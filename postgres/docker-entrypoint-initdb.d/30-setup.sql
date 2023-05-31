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
CREATE OR REPLACE PROCEDURE copy_from_asn(
   _source_file text
) AS
$$
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
  ON MD5(ROW(ti.boekingsdatum, ti.tegenrekeningnummer, ti.naam_tegenrekening, ti.transactiebedrag, ti.journaaldatum, ti.volgnummer_transactie, ti.omschrijving)::text) = MD5(ROW(tir.boekingsdatum, tir.tegenrekeningnummer, tir.naam_tegenrekening, tir.transactiebedrag, tir.journaaldatum, tir.volgnummer_transactie, tir.omschrijving)::text)
  WHEN MATCHED THEN
  UPDATE SET
    boekingsdatum = tar.boekingsdatum,
    opdrachtgeversrekening = tar.opdrachtgeversrekening,
    tegenrekeningnummer = tar.tegenrekeningnummer,
    naam_tegenrekening = tar.naam_tegenrekening,
    adres = tar.adres,
    postcode = tar.postcode,
    plaats = tar.plaats,
    valutasoort_rekening = tar.valutasoort_rekening,
    saldo_rekening_voor_mutatie = tar.saldo_rekening_voor_mutatie,
    valutasoort_mutatie = tar.valutasoort_mutatie,
    transactiebedrag = tar.transactiebedrag,
    journaaldatum = tar.journaaldatum,
    valutadatum = tar.valutadatum,
    interne_transactiecode = tar.interne_transactiecode,
    globale_transactiecode = tar.globale_transactiecode,
    volgnummer_transactie = tar.volgnummer_transactie,
    betalingskenmerk = tar.betalingskenmerk,
    omschrijving = tar.omschrijving,
    afschriftnummer = tar.afschriftnummer,
	md5_hash = tar.md5_hash
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
    afschriftnummer,
    md5_hash)
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
    tar.afschriftnummer,
    tar.md5_hash);
  COMMIT;
  TRUNCATE TABLE words_asn;
  INSERT INTO words_asn SELECT * FROM ts_stat('SELECT tsv FROM transacties_asn');
END;
$$ LANGUAGE plpgsql;

-- CALL copy_from_asn('/mnt/miniodata/kasboek/transacties_asn.csv');
--
