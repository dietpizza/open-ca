#!/usr/bin/env bash

if [ $# -lt 2 ]
then 
   echo "Usage: $0 <cert-name> <ca-name>"
   exit 1
fi

NAME=$1
DIR="certs/$NAME"
FILE="$DIR/$NAME"

CA_NAME=$2
CA_DIR="ca/$CA_NAME"
CA_FILE="$CA_DIR/$CA_NAME"

DOMAINS="domains.ext"

function mkca () {
    mkdir -p $CA_DIR

    openssl req\
        -x509\
        -nodes\
        -new\
        -sha256\
        -days 3650\
        -newkey rsa:2048\
        -keyout "$CA_DIR/$CA_NAME.key"\
        -out "$CA_DIR/$CA_NAME.pem"\
        -subj "/C=IN/O=$CA_NAME/OU=Enginnering/CN=$CA_NAME"

    openssl x509\
        -outform pem\
        -in "$CA_DIR/$CA_NAME.pem"\
        -out "$CA_DIR/$CA_NAME.crt"
    echo
    echo "Certificate Authority '$CA_NAME' created."
}

function mkcert () {
    mkdir -p $DIR

    openssl req\
        -new\
        -nodes\
        -newkey rsa:2048\
        -keyout $FILE.key\
        -out $FILE.csr\
        -subj "/C=IN/ST=West Bengal/L=SSA/O=$NAME/OU=Engineering/CN=$NAME"

    openssl x509\
        -req\
        -sha256\
        -days 3650\
        -in $FILE.csr\
        -CA $CA_FILE.pem\
        -CAkey $CA_FILE.key\
        -CAcreateserial\
        -extfile $DOMAINS\
        -out $FILE.crt

    openssl pkcs12\
        -export\
        -inkey $FILE.key\
        -in $FILE.crt\
        -out $FILE.p12

    echo
    echo "Certificate '$NAME' created."
}

if [ -d $DIR ] 
then
    echo "Certificate '$NAME' already exists -_-"
    exit 1
else
    if [ ! -d $CA_DIR ]
    then
        read -n1 -p "The Authority '$CA_NAME' does not exist. Create it now? [y/n]: " CHOICE
        echo
        case $CHOICE in 
            [Yy] ) mkca;;
            [Nn] ) exit 1;;
            * ) echo "Please answer yes or no."; exit 1;;
        esac
    fi

    mkcert
fi

