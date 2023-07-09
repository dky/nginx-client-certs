# CSR Generate 

Automate generating CA certs, Server certs, and Client Certs for certificate based auth. These certs were used with Nginx client based authentication.
## Usage:

`generate.sh` will only create a `CA` cert used to sign a client cert used for cert based auth. The cert will last for 10 years.
If you need intermediate certs and server certs un-comment `make_int` and `make_server` which will then generate the server certs and intermediate certs.

```
./generate.sh
```

## Customization:

### Replace global the variables:

```
COUNTRY="US"
LOCATION="NY"
OU="dky.io"
EMAIL="support@dky.io"
```

With your own variables. 

You'll likely want to also modify the `CN_NAME` variable within the server_key_cert function. 

## Nginx installation

1. Run `./generate.sh` This should generate both the CA cert + the Client cert.
2. Copy `ca.crt` to the remote target.
3. Configure Nginx:

```
ssl_client_certificate /etc/nginx/ca.crt;
ssl_verify_client on;
```

4. If you need a `.pfx` file we have a helper script `combine.sh` that will generate a pfx file you can import into a keychain.


## Troubleshooting

`validate.sh` makes a curl call to the protected endpoint providing the client cert, key and the ca.crt. Use this to make sure certs are functional.
