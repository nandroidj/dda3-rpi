#!/bin/bash

# -- Set local IP --
IP=$MACINTOSH_HOSTIP 

SUBJECT_CA="/C=AR/ST=GBA/L=GBA/O=FiUBA/OU=CA/CN=$IP"
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


function copy_server_keys_to_broker () {
   cp ca.crt ../broker/certs/
   cp server.crt ../broker/certs/
   cp server.key ../broker/certs/
}

function move_actors_keys_to_certs () {

  mv ca.key ../certs/ca/
  mv ca.crt ../certs/ca/

  mv server.key ../certs/server/
  mv server.csr ../certs/server/
  mv server.crt ../certs/server/

  mv  client.key ../certs/client/
  mv client.csr ../certs/client/
  mv client.crt ../certs/client/

}


generate_CA
generate_server
generate_client

copy_server_keys_to_broker
move_actors_keys_to_certs


