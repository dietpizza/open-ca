#!/usr/bin/env bash

ROOT="RootCA"

if [ -d $ROOT ] 
then
    echo "RootCA Already Exists!"
else
    mkdir -p $ROOT
    cd $ROOT

    openssl req\
        -x509\
        -nodes\
        -new\
        -sha256\
        -days 1024\
        -newkey rsa:2048\
        -keyout $ROOT.key\
        -out $ROOT.pem\
        -subj "/C=BR/CN=LocalCA"

    openssl x509\
        -outform pem\
        -in $ROOT.pem\
        -out $ROOT.crt
fi

