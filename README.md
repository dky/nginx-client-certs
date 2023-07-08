# CSR Generate 

Automate generating CA certs, Server certs, and Client Certs for certificate based auth. 

This script was generated when I needed to setup certificate based auth using Nginx and got sick of manually running the openssl command to generate each set of certs.

## Usage:

Shell script contains 6 functions, functionality of each function is broke out below:

```
./generate.sh
```

You'll get prompted a few times to enter the passprhase for the intermediate ca key. Make sure to remmeber this and repeat it.

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
