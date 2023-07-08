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
[req]
default_bits = $BITS
distinguished_name = distinguished_name
prompt = no
default_md = sha256
default_keyfile = $CONF_NAME.key
req_extensions = v3_req

[distinguished_name]
C = $COUNTRY_NAME
L = $LOCATION_NAME
O = $OU_NAME
CN = $CN_NAME

[v3_req]
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF
}

BITS=4096
PASSPHRASE="selfsigned"
COUNTRY="US"
LOCATION="NY"
OU="dky.io"
EMAIL="support@dky.io"

make_ca() {
	echo "Generating Self-Signed Root CA and key"
	NAME=ca
	CN_NAME="$NAME.$OU"

	echo "Generating ca config"
	gen_config "$NAME" "$BITS" "$PASSPHRASE" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	# 3652 = 10 years
	$OPENSSL req -new -nodes -x509 -keyout ca.key -out ca.crt -config $NAME.conf -extensions v3_req -days 3652
}

make_int() {
	echo "Generating Intermediate CA and key"
	NAME=ca_int
	CN_NAME="$NAME.$OU"

	echo "Generating int config"
	gen_config "$NAME" "$BITS" "$PASSPHRASE" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	# 3652 = 10 years
	$OPENSSL req -new -keyout $NAME.key -out $NAME.csr -config $NAME.conf -extensions v3_req -days 3652
	$OPENSSL req -in $NAME.csr -noout -verify

	$OPENSSL x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in $NAME.csr -out $NAME.crt -extfile $NAME.conf -extensions v3_req -days 3652
	$OPENSSL verify -CAfile ca.crt ca_int.crt

	echo "Creating CA chain/bundle"
	cat ca_int.crt ca.crt > ca.pem
}


server_cert() {
	NAME=server
	CN_NAME="www.dky.io"

	echo "Creating $NAME key"
	$OPENSSL genrsa -des3 -passout pass:$PASSPHRASE -out $NAME.key 2048
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
	$OPENSSL genrsa -des3 -passout pass:$PASSPHRASE -out $NAME.key 2048
	gen_config "$NAME" "$BITS" "$PASSPHRASE" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	echo "Creating $NAME.csr"
	$OPENSSL req -new -key $NAME.key -out $NAME.csr -config $NAME.conf 
}

function self_sign_client {
	#Sign the client certificate with our CA cert.  Unlike signing our own server cert, this is what we want to do.
	$OPENSSL x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt -passin pass:$PASSPHRASE
}

make_ca
make_int
#server_key_cert
#self_sign_server
#client_certs
#self_sign_client
