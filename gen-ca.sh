#!/bin/bash

IPSEC=${IPSEC:-ipsec}

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 2 ]; then
    echo usage: $0 dir caname
    exit 1
fi

# __DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

dir=$1
caname=$2

mkdir -p $dir/$caname/ca
cd $dir/$caname/ca

caKey=$caname-key.pem
caCert=$caname-cert.pem
if [ ! -e $caKey ]; then
    $IPSEC pki --gen --type rsa --size 4096 --outform pem >$caKey
    chmod 600 $caKey
    $IPSEC pki --self --ca --lifetime 3650 --outform pem \
           --in $caKey --type rsa \
           --dn "C=CH, O=strongSwan, CN=$caname" \
           >$caCert
    echo "---------------- CA Certificate ----------------"
    $IPSEC pki --print --in $caCert
else
    echo "There is already a ca key for $caname"
fi
