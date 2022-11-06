-- Connect to database
\connect kasboek

-- Insert ING transactions
CREATE OR REPLACE PROCEDURE copy_from_ing(
   _source_file text
) AS
$$
BEGIN
  EXECUTE format('COPY transacties_ing (
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
  EXECUTE format('COPY transacties_asn (
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
  INSERT INTO words_asn SELECT * FROM ts_stat('SELECT tsv FROM transacties_asn');
  COMMIT;
END;
$$ LANGUAGE plpgsql;

-- CALL copy_from_asn('/mnt/miniodata/kasboek/transacties_asn.csv');
