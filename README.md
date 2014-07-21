#CSR Generate 

Shell script to automate generating CA certs, Server certs, and Client Certs for certificate based auth. This script was generated when I needed to setup certificate bashed auth using Nginx and got sick of manually running the openssl command to generate each set of certs.

##Usage:

Shell script contains 6 functions, functionality of each function is broke out below:

- gen_config - This is the main function that generates the configuration files to automate the openssl certificate generation process. No need to mess with this function as it's called by the other functions.

- ca_key_cert - Generate the CA key and certificate to sign other requests. 
- server_key_cert - Generates server key, certificate and csr.  
- self_sign_server - Sign our server cert using our own CA. 
- client_certs - Client key and CSR. 
- self_sign_client - Sign the client cert with our CA cert 
- combine_client_certs - Combine the client cert and key into a .p12 file. We can then import this into OSX keychain. 

##To customize:

###Replace global the variables:

```
BITS=2048
PASSPHRASE="selfsigned"
COUNTRY="US"
LOCATION="NY"
OU="dky.io"
EMAIL="support@dky.io"
```

With your own variables. 

You'll likely want to also modify the `CN_NAME` variable within the server_key_cert function. 
