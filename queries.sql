-- Insert data
COPY kasboek.transacties (datum, naam, rekening, tegenrekening, code, af_bij, bedrag, mutatiesoort, mededeling) 
FROM '/mnt/miniodata/kasboek/yourcsv.csv' csv header;

-- Search terms
CREATE TABLE kasboek.words AS SELECT * FROM ts_stat('SELECT tsv FROM kasboek.transacties');

-- Search index
CREATE INDEX ON kasboek.words USING gin (word gin_trgm_ops);

-- Create table mijn_rekeningen
CREATE TABLE IF NOT EXISTS kasboek.mijn_rekeningen (
  id INT GENERATED ALWAYS AS IDENTITY,
  rekening text
);

-- Insert accountnumbers
INSERT INTO kasboek.mijn_rekeningen(rekening) VALUES ('NLxxINGB000xxxxxxx'); 






-- Search
SELECT t1.rekening, t1.tegenrekening, t1.naam, t1.mededeling
FROM kasboek.transacties t1
LEFT JOIN kasboek.spaarrekeningen t2 ON t1.tegenrekening = t2.rekening
WHERE t2.rekening IS null
AND tsvector @@ websearch_to_tsquery('simple','ikea');

-- Create function create md5
CREATE OR REPLACE FUNCTION create_md5_func() 
  RETURNS TRIGGER
AS
$$
BEGIN
    UPDATE kasboek.transacties SET md5=md5(naam)::uuid;
  RETURN new;
END;
$$
LANGUAGE plpgsql;

-- Create trigger create md5
CREATE TRIGGER create_md5_trigger 
AFTER INSERT ON kasboek.transacties
FOR EACH STATEMENT EXECUTE PROCEDURE create_md5_func();

-- Add column md5
ALTER TABLE kasboek.transacties ADD COLUMN md5 uuid;

-- Create hash
UPDATE kasboek.transacties SET md5 = md5(CONCAT(datum,naam,rekening,mededeling,tegenrekening,code,af_bij,bedrag,mutatiesoort,mededeling))::uuid;

-- Show duplicates
SELECT * FROM kasboek.transacties a, kasboek.transacties b WHERE (a.md5)=(b.md5) and a.ctid < b.ctid;

-- Delete duplicates
DELETE FROM kasboek.transacties a USING kasboek.transacties b WHERE (a.md5)=(b.md5) AND a.ctid < b.ctid;
--
