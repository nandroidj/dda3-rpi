# dda3-rpi

## Hasura + PostgreSQL

1. Se instalan las dependencias *docker-compose* y *Docker*.

2. Se crea el archivo de extension *yaml* que contendra los servicios de *Hasura* y *PostgreSQL*

```
postgres:
    image: postgres:12.7
    restart: always
    container_name: postgres
    volumes:
      - ./db/:/docker-entrypoint-initdb.d/
      - ./db_data:/var/lib/postgresql/data
    environment:
      # POSTGRES_USER: admin
      POSTGRES_PASSWORD: postgrespassword
    ports:
      - "127.0.0.1:5432:5432"

  hasura:
    image: hasura/graphql-engine:v2.6.2
    container_name: hasura
    ports:
      - "127.0.0.1:8080:8080"
    depends_on:
      - postgres
    restart: always
    volumes:
      - ./migrations/hasura/migrations:/hasura-migrations
      - ./migrations/hasura/metadata:/hasura-metadata
    environment:
      ## postgres database to store Hasura metadata
      HASURA_GRAPHQL_METADATA_DATABASE_URL: postgres://postgres:postgrespassword@postgres:5432/postgres
      ## this env var can be used to add the above postgres database to Hasura as a data source. this can be removed/updated based on your needs
      PG_DATABASE_URL: postgres://postgres:postgrespassword@postgres:5432/postgres
      ## enable the console served by server
      HASURA_GRAPHQL_ENABLE_CONSOLE: "true" # set to "false" to disable console
      ## enable debugging mode. It is recommended to disable this in production
      HASURA_GRAPHQL_DEV_MODE: "true"
      HASURA_GRAPHQL_ENABLED_LOG_TYPES: startup, http-log, webhook-log, websocket-log, query-log
      ## uncomment next line to set an admin secret
      # HASURA_GRAPHQL_ADMIN_SECRET: myadminsecretkey
```


































