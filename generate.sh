#!/usr/bin/env bash

OPENSSL=/usr/bin/openssl

function gen_config () {

CONF_NAME=$1
BITS=$2
COUNTRY_NAME=$3
LOCATION_NAME=$4
OU_NAME=$5
CN_NAME=$6
EMAIL=$7

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
COUNTRY="US"
LOCATION="NY"
OU="dky.io"
EMAIL="support@dky.io"

make_ca() {
	echo "Generating Self-Signed Root CA and key"
	NAME=ca
	CN_NAME="$NAME.$OU"

	echo "Generating ca config"
	gen_config "$NAME" "$BITS" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"

	$OPENSSL req -new -nodes -x509 -keyout ca.key -out ca.crt -config $NAME.conf -extensions v3_req -days 3652
}

make_int() {
	echo "Generating Intermediate CA and key"
	NAME=ca_int
	CN_NAME="$NAME.$OU"

	echo "Generating int config"
	gen_config "$NAME" "$BITS" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"

	echo "write key"
	$OPENSSL req -new -keyout $NAME.key -out $NAME.csr -config $NAME.conf -extensions v3_req -days 3652
	$OPENSSL req -in $NAME.csr -noout -verify

	$OPENSSL x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in $NAME.csr -out $NAME.crt -extfile $NAME.conf -extensions v3_req -days 3652
	$OPENSSL verify -CAfile ca.crt ca_int.crt

	echo "Creating CA chain/bundle"
	cat ca_int.crt ca.crt > ca.pem
}

make_server() {
	NAME=server
	CN_NAME="www.dky.io"

	echo "Creating $NAME key"
	gen_config "$NAME" "$BITS" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	echo "Creating $NAME.csr"
	$OPENSSL req -new -nodes -keyout $NAME.key -out $NAME.csr -config $NAME.conf
	$OPENSSL req -in $NAME.csr -noout -verify

	$OPENSSL x509 -req -CA ca_int.crt -CAkey ca_int.key -CAcreateserial -in $NAME.csr -out $NAME.crt -extfile $NAME.conf -extensions v3_req -days 3652
	$OPENSSL verify -CAfile ca.pem server.crt
}

make_client() {
	NAME=client
	CN_NAME="$NAME.$OU"

	echo "Creating $NAME key"
	gen_config "$NAME" "$BITS" "$COUNTRY" "$LOCATION" "$OU" "$CN_NAME" "$EMAIL"
	echo "Creating $NAME.csr"
	$OPENSSL req -new -nodes -keyout $NAME.key -out $NAME.csr -config $NAME.conf

	$OPENSSL req -in $NAME.csr -noout -verify

	$OPENSSL x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in $NAME.csr -out $NAME.crt -extfile $NAME.conf -extensions v3_req -days 3652

	$OPENSSL verify -CAfile ca.pem $NAME.crt
}

make_ca
make_int
make_server
make_client
