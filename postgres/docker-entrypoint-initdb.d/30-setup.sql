CREATE OR REPLACE PROCEDURE copy_from(
   _source_file text
) AS
$$
BEGIN 
EXECUTE format('COPY kasboek.transacties (datum, naam, rekening, tegenrekening, code, af_bij, bedrag, mutatiesoort, mededeling) FROM %L csv header', _source_file);
END; 
$$ LANGUAGE plpgsql;

-- CALL copy_from('/mnt/miniodata/kasboek/transacties.csv');
