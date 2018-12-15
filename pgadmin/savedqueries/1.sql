SET LC_MONETARY="nl_NL.utf8";

CREATE SCHEMA kasboek;

CREATE DATABASE kasboek
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'nl_NL.utf8'
    LC_CTYPE = 'nl_NL.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
