#!/usr/bin/env bash

NAME=$1
DIR="certs/$NAME"
ROOT_DIR="root"
DOMAIN="domains.ext"

if [ $# -eq 0 ]
then 
   echo "Usage: $0 cert-name"
   exit 1
fi

if [ -d $DIR ] 
then
    echo "Certificate already exists -_-"
    exit 1
else
    mkdir -p $DIR

    openssl req\
        -new\
        -nodes\
        -newkey rsa:2048\
        -keyout $DIR/cert.key\
        -out $DIR/cert.csr\
        -subj "/C=BR/ST=BAHIA/L=SSA/O=LocalCert/CN=localhost"

    openssl x509\
        -req\
        -sha256\
        -days 3650\
        -in $DIR/cert.csr\
        -CA $ROOT_DIR/root.pem\
        -CAkey $ROOT_DIR/root.key\
        -CAcreateserial\
        -extfile $DOMAIN\
        -out $DIR/cert.crt

    openssl pkcs12\
        -export\
        -inkey $DIR/cert.key\
        -in $DIR/cert.crt\
        -out $DIR/cert.p12
fi

