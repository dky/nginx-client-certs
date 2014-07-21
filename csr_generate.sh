#!/usr/bin/env bash

OPENSSL=/usr/bin/openssl

function gen_config () {

CONF_NAME=$1
BITS=$2
PASS=$3
COUNTRY_NAME=$4
LOCATION_NAME=$5
OU_NAME=$6
CN_NAME=$7
EMAIL=$8

cat << EOF > ./$CONF_NAME.conf
[ req ]
default_bits = $BITS
default_keyfile = $CONF_NAME.key
distinguished_name = distinguished_name
prompt = no
input_password = $PASSPHRASE

[ distinguished_name ]
C = $COUNTRY_NAME
L = $LOCATION_NAME
O = $OU_NAME
CN = $CN_NAME
emailAddress = $EMAIL
EOF
}

BITS=2048
PASSPHRASE="selfsigned"
COUNTRY="US"
LOCATION="NY"
OU="dky.io"
EMAIL="support@dky.io"

function ca_key_cert {
	NAME=ca
	CN_NAME="$NAME.$OU"

	echo "Creating $NAME.key"
	$OPENSSL genrsa -des3 -passout pass:$PASSPHRASE -out $NAME.key 4096
	gen_config "$NAME" "$BITS" "$PASSPHRASE" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	echo "Creating $NAME.crt"
	$OPENSSL req -new -x509 -days 365 -key $NAME.key -out $NAME.crt -config $NAME.conf
}

function server_key_cert {
	NAME=server
	CN_NAME="www.dky.io"

	echo "Creating $NAME key"
	$OPENSSL genrsa -des3 -passout pass:$PASSPHRASE -out $NAME.key 1024
	gen_config "$NAME" "$BITS" "$PASSPHRASE" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	echo "Creating $NAME.csr"
	$OPENSSL req -new -key $NAME.key -out $NAME.csr -config $NAME.conf 
}

function self_sign_server {
	#self sign the server cert using our own CA
	$OPENSSL x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt -passin pass:$PASSPHRASE
}

function client_certs {
	NAME=client
	CN_NAME="$NAME.$OU"

	echo "Creating $NAME key"
	$OPENSSL genrsa -des3 -passout pass:$PASSPHRASE -out $NAME.key 1024
	gen_config "$NAME" "$BITS" "$PASSPHRASE" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	echo "Creating $NAME.csr"
	$OPENSSL req -new -key $NAME.key -out $NAME.csr -config $NAME.conf 
}

function self_sign_client {
	#Sign the client certificate with our CA cert.  Unlike signing our own server cert, this is what we want to do.
	$OPENSSL x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt -passin pass:$PASSPHRASE
}

function combine_client_certs { 
	$OPENSSL pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
}

ca_key_cert
server_key_cert
self_sign_server
client_certs
self_sign_client
#combine_client_certs
