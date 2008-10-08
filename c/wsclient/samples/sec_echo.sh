#!/bin/bash

if test -z $WSFC_HOME; then 
    WSFC_HOME=$PWD/../../..
fi
INST_DIR=$WSFC_HOME
SERVICE_HOME="$INST_DIR/services/sec_echo"

_SMPL_DIR="$PWD"

if [ $# -ne 1 ]
then
    echo "Usage : $0 server-port"
    exit
fi

    _PORT=$1
    echo "-------------------------------------------------------------------------"
    echo "Deploying server with required sec_policy for sec_echo service"

    echo "Replacing sec_echo/services.xml"
    if [ `uname -s` = Darwin ]
    then
        sed -e 's,AXIS2C_HOME,'$INST_DIR',g' -e 's,\.so,\.dylib,g' data/sec_echo_services.xml > $SERVICE_HOME/services.xml
    else
        sed 's,AXIS2C_HOME,'$INST_DIR',g' data/sec_echo_services.xml > $SERVICE_HOME/services.xml
    fi

    killall axis2_http_server
    cd $WSFC_HOME/bin
    echo "Start server @ $_PORT"
    ./axis2_http_server -p$_PORT &
    sleep 2
    cd $_SMPL_DIR
    echo "Run the sample"

$WSFC_HOME/bin/wsclient --soap --no-mtom --user alice --digest --password password --timestamp --sign-body --key /axis2c/deploy/bin/samples/rampart/keys/ahome/alice_key.pem --certificate /axis2c/deploy/bin/samples/rampart/keys/ahome/alice_cert.cert --recipient-certificate /axis2c/deploy/bin/samples/rampart/keys/ahome/bob_cert.cert --encrypt-signature --encrypt-payload http://localhost:9090/axis2/services/sec_echo <$WSFC_HOME/bin/samples/wsclient/data/echo.xml
     
killall axis2_http_server
echo "DONE"