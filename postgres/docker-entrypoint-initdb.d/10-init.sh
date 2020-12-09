#/bin/bash
set -e

# Include PostgreSQL settings
echo "include_dir = '/conf.d'" >> "$PGDATA/postgresql.conf"
