#!/usr/bin/env bash

shopt -s nullglob
shopt -s nocasematch

if [ $# -lt 1 ]
then 
   echo "Usage: $0 <cert-name>"
   exit 1
fi

DOMAINS="domains.ext"

function mkca () {
    CA_NAME=$1
    CA_DIR="ca/$CA_NAME"
    CA_FILE="$CA_DIR/$CA_NAME"

    if [ ! -d $CA_DIR ]; then
        read -n1 -p "The certificate authority '$CA_NAME' does not exist. Create it now? [y/n]: " CHOICE
        echo

        if [[ $CHOICE == "y" ]]; then
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
        else
            echo "Create a certificate authority first."
            exit 1
        fi
    fi
}

function mkcert () {
    NAME=$1
    DIR="certs/$NAME"
    FILE="$DIR/$NAME"

    mkdir -p $DIR

    openssl req\
        -new\
        -nodes\
        -newkey rsa:2048\
        -keyout $FILE.key\
        -out $FILE.csr\
        -subj "/C=IN/ST=West Bengal/L=SSA/O=$NAME/OU=Engineering/CN=$NAME"
    
    cp $DOMAINS $DIR/

    read -p "Enter domain names (eg. echo.org *.echo.org): " -a DNS
    for i in ${!DNS[@]}; do
        echo "DNS.$(($i + 1)) = ${DNS[$i]}" >> $DIR/$DOMAINS
    done

    read -p "Enter IPs (eg. 127.0.0.1 192.168.56.128): " -a IP
    for i in ${!IP[@]}; do
        echo "IP.$(($i + 1)) = ${IP[$i]}" >> $DIR/$DOMAINS
    done

    openssl x509\
        -req\
        -sha256\
        -days 3650\
        -in $FILE.csr\
        -CA $CA_FILE.pem\
        -CAkey $CA_FILE.key\
        -CAcreateserial\
        -extfile $DIR/$DOMAINS\
        -out $FILE.crt

    openssl pkcs12\
        -export\
        -inkey $FILE.key\
        -in $FILE.crt\
        -out $FILE.p12

    echo
    echo "Certificate '$NAME' created."
}

if [ -d certs/$1 ]; then
    echo "Certificate '$1' already exists -_-"
    exit 1
else
    LIST=(ca/*)
    echo "Certificate Authorities Available:"
    printf '%s\n' "${LIST[@]##*/}"
    read -p "Enter CA name: " CA_NAME

    mkca $CA_NAME
    mkcert $1
fi

