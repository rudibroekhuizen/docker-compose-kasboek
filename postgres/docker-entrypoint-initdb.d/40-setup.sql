-- Create group readonly
CREATE ROLE readonly;
GRANT CONNECT ON DATABASE kasboek TO readonly;
GRANT USAGE ON SCHEMA "public" TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA "public" TO readonly;

-- Create user and add to group readonly
CREATE USER grafana WITH PASSWORD 'secret_passwd';
GRANT readonly TO grafana;



-- Create group readwrite
CREATE ROLE readwrite;
GRANT CONNECT ON DATABASE kasboek TO readwrite;
GRANT USAGE ON SCHEMA "public" TO readwrite;
GRANT USAGE, CREATE ON SCHEMA "public" TO readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "public" TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA "public" TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT USAGE ON SEQUENCES TO readwrite;

-- Create user and add to group readwrite
CREATE USER admin WITH PASSWORD 'secret_passwd';
GRANT readwrite TO admin;
