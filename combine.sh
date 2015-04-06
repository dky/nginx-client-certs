#!/bin/bash

openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
