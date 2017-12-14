#!/bin/bash

IPSEC=${IPSEC:-ipsec}

if [ $# -ne 2 ]; then
    echo usage: $0 dir server
    exit 1
fi

# __DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

dir=$1
server=$2

mkdir -p $dir/servers
cd $dir/servers
mkdir -p $server

t=$(date +%F)
svrKey=$server/$server-$t-key.pem
svrCrt=$server/$server-$t-cert.pem
if [ ! -e $svrKey ]; then
    $IPSEC pki --gen --type rsa --size 2048 --outform pem >$svrKey
    chmod 600 $svrKey
    $IPSEC pki --pub --in $svrKey --type rsa | \
        $IPSEC pki --issue --lifetime 730 --outform pem \
              --cacert $dir/ca/ca-cert.pem \
              --cakey $dir/ca/ca-key.pem \
              --dn "C=CH, O=strongSwan, CN=$server" \
              --san $server \
              --flag serverAuth --flag ikeIntermediate \
              > $svrCrt
    echo "---------------- Server Certificate ----------------"
    $IPSEC pki --print --in $svrCrt
else
    echo "There is already a key for $server, with today's timestamp"
fi
