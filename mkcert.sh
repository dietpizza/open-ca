#!/usr/bin/env bash

NAME=$1
DIR="certs/$NAME"
ROOT_CA="../../RootCA/RootCA"
DOMAIN="../../domains.ext"

if [ $# -eq 0 ]
then 
   echo "Usage: $0 cert-name"
   exit 1
fi

if [ -d $DIR ] 
then
    echo "Certificate Already Exists!"
else
    mkdir -p $DIR
    cd $DIR

    openssl req\
        -new\
        -nodes\
        -newkey rsa:2048\
        -keyout $NAME.key\
        -out $NAME.csr\
        -subj "/C=BR/ST=BAHIA/L=SSA/O=LocalCert/CN=localhost.local"

    openssl x509\
        -req\
        -sha256\
        -days 1024\
        -in $NAME.csr\
        -CA $ROOT_CA.pem\
        -CAkey $ROOT_CA.key\
        -CAcreateserial\
        -extfile $DOMAIN\
        -out $NAME.crt

    openssl pkcs12\
        -export\
        -inkey $NAME.key\
        -in $NAME.crt\
        -out $NAME.p12
fi

