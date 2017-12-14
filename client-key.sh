#!/bin/bash

IPSEC=${IPSEC:-ipsec}

if [ $# -ne 3 ]; then
    echo usage: $0 dir client email
    exit 1
fi

# __DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

dir=$1
client=$2
email=$3

mkdir -p $dir/clients
cd $dir/clients
mkdir -p $client

t=$(date +%F)
cltKey=$client/$email-$t-key.pem
cltCrt=$client/$email-$t-cert.pem
if [ ! -e $cltKey ]; then
    $IPSEC pki --gen --type rsa --size 2048 --outform pem >$cltKey
    chmod 600 $cltKey
    $IPSEC pki --pub --in $cltKey --type rsa | \
        $IPSEC pki --issue --lifetime 730 --outform pem \
              --cacert $dir/ca/ca-cert.pem \
              --cakey $dir/ca/ca-key.pem \
              --dn "C=CH, O=strongSwan, CN=$email" \
              --san $email \
              > $cltCrt
    echo "---------------- Client Certificate ----------------"
    $IPSEC pki --print --in $cltCrt
else
    echo "There is already a key for $client, with today's timestamp"
fi
