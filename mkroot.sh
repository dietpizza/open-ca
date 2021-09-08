#!/usr/bin/env bash

echo "Enter CA name:"
read -i NAME

if [ -z $NAME] then
    NAME="KepSign"
fi

DIR="root/$NAME"

if [ -d $DIR ] 
then
    echo "Authority already exists -_-"
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
        -subj "/C=BR/CN=LocalCA"

    openssl x509\
        -outform pem\
        -in "$DIR/$NAME.pem"\
        -out "$DIR/$NAME.crt"
fi

