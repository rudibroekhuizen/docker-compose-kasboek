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
  COMMIT;
END;
$$ LANGUAGE plpgsql;

-- CALL copy_from_asn('/mnt/miniodata/kasboek/transacties_asn.csv');
--
