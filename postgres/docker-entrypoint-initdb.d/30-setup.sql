CREATE OR REPLACE PROCEDURE copy_from_ing(
   _source_file text
) AS
$$
BEGIN 
EXECUTE format('COPY kasboek.transacties_ing (datum, naam, rekening, tegenrekening, code, af_bij, bedrag, mutatiesoort, mededeling) FROM %L csv header', _source_file);
END; 
$$ LANGUAGE plpgsql;

-- CALL copy_from('/mnt/miniodata/kasboek/transacties_ing.csv');
