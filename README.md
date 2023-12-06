# Kasboek

Geeft inzicht in banktransacties. Gebruikt PostgreSQL en Grafana voor zoeken en tonen van gegevens. 

## Gebruik

Start de containers:
```sh
docker-compose up -d
```

Upload .csv file via http://localhost:9000/minio/kasboek/. 

Verbind met de database:
```sh
docker-compose exec postgres bash -c 'psql -d kasboek -U $POSTGRES_USER $POSTGRES_DB'
```

Importeer transacties ING:
```sh
CALL copy_from_ing('/mnt/miniodata/kasboek/transacties_ing.csv');
```

Importeer transacties ASN:
```sh
CALL copy_from_asn('/mnt/miniodata/kasboek/transacties_asn.csv');
```

Browse naar het dashboard http://localhost:3000/dashboards.
