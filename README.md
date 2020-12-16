# Kasboek

Geeft inzicht in banktransacties. Gebruikt PostgreSQL en Grafana voor zoeken en tonen van gegevens. 

## Gebruik

Start de minio container:
```
docker-compose up -d minio
```

Upload file met naam transacties.csv via http://localhost:9000/minio/kasboek/. 

Start overige containers:

```
docker-compose up -d
```

Browse naar het dashboard http://localhost:3000/dashboards.
