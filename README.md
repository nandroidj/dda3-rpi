# dda3-rpi

## Hasura + PostgreSQL

1. Se instalan las dependencias *docker-compose* y *Docker*.

2. Se crea el archivo de extension *yaml* que contendra los servicios de *Hasura* y *PostgreSQL* siguiendo el [tutorial](https://hasura.io/docs/latest/graphql/core/getting-started/docker-simple/) provisto por la documentacion del motor GraphQL.

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

3. A partir del [paso a paso](https://hasura.io/docs/latest/graphql/core/migrations/migrations-setup/) se setean las migraciones y la metadata que posibilitan alterar la base de datos *PostgreSQL* conectada a *Hasura*. 

4. Luego, se crea la migracion correspondiente al modelo de datos que cuenta con las tablas: `devices`, `telemetries` y `commands` con sus correspondientes claves unicas y foraneas.

```
-- Tables
CREATE TABLE public.telemetries (
  id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  device_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
  temperature integer NOT NULL,
  humidity integer NOT NULL
);

CREATE TABLE public.commands (
  id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  device_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  command text,
  parameter integer
);

CREATE TABLE public.devices (
  id uuid DEFAULT public.gen_random_uuid() NOT NULL,
  name text
);


-- Primary keys
ALTER TABLE ONLY public.telemetries
    ADD CONSTRAINT telemetries_id_key UNIQUE (id);

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_id_key UNIQUE (id);

-- Foreign keys
ALTER TABLE ONLY public.telemetries
    ADD CONSTRAINT telemetries_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
    
ALTER TABLE ONLY public.commands
    ADD CONSTRAINT commands_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
```



## MQTT - Mosquitto Broker

En primer lugar, se instala el cliente *Mosquitto*, *Broker* basado en el protocolo *MQTT*, utilizando el comando `brew install mosquitto` y su correspondiente instalacion para [RPi](https://mosquitto.org/2013/01/mosquitto-debian-repository/).  




### Creacion de certificados

1. Se adapta el *script* provisto en la clase numero dos para crear los certificados correspondientes al broker (servidor) y el esp32 + dht22 (cliente) para Mac OS agregando el archivo de la variable de entorno `.env.sh`, luego se otorga permisos de ejecucion con `chmod +x create_certificates.sh` y por ultimo se corre el script.

```
#!/bin/bash

# -- Set local IP --
IP=$HOST_IP

SUBJECT_CA="/C=AR/ST=GBA/L=GBA/O=FiUBA/OU=CA/CN=$IP
SUBJECT_SERVER="/C=AR/ST=GBA/L=GBA/O=FiUBA/OU=Server/CN=$IP"
SUBJECT_CLIENT="/C=AR/ST=GBA/L=GBA/O=FiUBA/OU=Client/CN=$IP"


function generate_CA () {
   echo "$SUBJECT_CA"
   openssl req -x509 -nodes -sha256 -newkey rsa:2048 -subj "$SUBJECT_CA"  -days 365 -keyout ca.key -out ca.crt
}

function generate_server () {
   echo "$SUBJECT_SERVER"
   openssl req -nodes -sha256 -new -subj "$SUBJECT_SERVER" -keyout server.key -out server.csr
   openssl x509 -req -sha256 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
}

function generate_client () {
   echo "$SUBJECT_CLIENT"
   openssl req -new -nodes -sha256 -subj "$SUBJECT_CLIENT" -out client.csr -keyout client.key 
   openssl x509 -req -sha256 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365
}

function copy_keys_to_broker () {
   cp ca.crt ../mosquitto/certs/
   cp server.crt ../mosquitto/certs/
   cp server.key ../mosquitto/certs/
}

generate_CA
generate_server
generate_client
#copy_keys_to_broker
```

2. Se agrega los certificados del cliente: `ca.crt`, `client.crt`, `client.key`, en el repositorio correspondiente. Asimismo tal como se puede observar en el script se agregan los certificados del servidor en el servicio *mosquitto*.


### Mosquitto


A continuacion se presentan la configuracion de *mosquitto* instalado en el sistema operativo:

1. Se agrega el archivo `mosquitto.conf` en la ruta relativa `mosquitto/config` con el contenido: 

```
listener 8883
cafile /mosquitto/certs/ca.crt
keyfile /mosquitto/certs/server.key
certfile /mosquitto/certs/server.crt
require_certificate true
```

2. Se almacenan los certificados en la ruta `mosquitto/certs`. Cabe aclarar que no estos han sido agregados al `.gitignore` por cuestiones de seguridad.

3. Se reinicia el servicio lanzando el comando `systemctl mosquitto restart`. En mac OS el analogo a `systemctl` es `launchctl`.




## Links de Interés

- [How-To Create Self-signed SSL Certificates For IoT Application](https://bacnh.com/how-create-self-signed-certificates)

- [Mosquitto TLS](http://www.steves-internet-guide.com/mosquitto-tls/)




















