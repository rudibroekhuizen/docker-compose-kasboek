-- Insert ING transactions
CREATE OR REPLACE PROCEDURE copy_from_ing(
   _source_file text
) AS
$$
BEGIN 
EXECUTE format('COPY kasboek.transacties_ing (datum, naam, rekening, tegenrekening, code, af_bij, bedrag, mutatiesoort, mededeling) FROM %L csv header', _source_file);
CREATE TABLE kasboek.words_ing AS SELECT * FROM ts_stat('SELECT tsv FROM kasboek.transacties_ing');
CREATE INDEX ON kasboek.words_ing USING gin (word gin_trgm_ops);
END; 
$$ LANGUAGE plpgsql;

-- CALL copy_from_ing('/mnt/miniodata/kasboek/transacties_ing.csv');


-- Insert ASN transactions
CREATE OR REPLACE PROCEDURE copy_from_asn(
   _source_file text
) AS
$$
BEGIN 
EXECUTE format('COPY kasboek.transacties_asn (datum, naam, rekening, tegenrekening, code, af_bij, bedrag, mutatiesoort, mededeling) FROM %L csv header', _source_file);
CREATE TABLE kasboek.words_asn AS SELECT * FROM ts_stat('SELECT tsv FROM kasboek.transacties_asn');
CREATE INDEX ON kasboek.words_asn USING gin (word gin_trgm_ops);
END; 
$$ LANGUAGE plpgsql;

-- CALL copy_from_asn('/mnt/miniodata/kasboek/transacties_asn.csv');
