#!/usr/bin/env bash
# Create a .p12 bundle for importing into keychain if you are on OSX

openssl pkcs12 -export -legacy -clcerts -in client.crt -inkey client.key -out client.p12
