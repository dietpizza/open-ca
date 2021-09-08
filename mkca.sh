#!/usr/bin/env bash

if [ $# -eq 0 ]
then 
   echo "Usage: $0 cert-name"
   exit 1
fi

NAME=$1
DIR="ca/$NAME"

if [ -d $DIR ] 
then
    echo "Certificate Authority already exists -_-"
    exit 1
else
    mkdir -p $DIR

    openssl req\
        -x509\
        -nodes\
        -new\
        -sha256\
        -days 3650\
        -newkey rsa:2048\
        -keyout "$DIR/$NAME.key"\
        -out "$DIR/$NAME.pem"\
        -subj "/C=IN/O=$NAME/OU=Enginnering/CN=$NAME"

    openssl x509\
        -outform pem\
        -in "$DIR/$NAME.pem"\
        -out "$DIR/$NAME.crt"
fi

