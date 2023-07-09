#!/usr/bin/env bash
# Use this script to validate client certificate authentication works

URL=$1
curl --cert client.crt --key client.key --cacert ca.crt $URL
