#!/bin/bash

IPSEC=${IPSEC:-ipsec}

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 1 ]; then
    echo usage: $0 dir
    exit 1
fi

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

. $__DIR__/common.sh

dir=$1

parties_txt=$dir/parties.txt

if [ ! -f $parties_txt ]; then
    echo "$parties_txt not found"
    exit 1
fi

gen_pem() {
    caDir=$dir/$caname
    caKey=$caDir/ca/$caname-key.pem
    caCert=$caDir/ca/$caname-cert.pem

    if [ ! -f $caKey ]; then
        echo "No ca key found at $caKey"
        exit 1
    fi

    if [ ! -f $caCert ]; then
        echo "No ca cert found at $caCert"
        exit 1
    fi

    partDir=$caDir/$name
    partKey=$partDir/$caname-$id-key.pem
    partCert=$partDir/$caname-$id-cert.pem
    partP12=$partDir/$caname-$id-cert.p12

    if [ ! -e $partKey ]; then
        mkdir -p $partDir
        $IPSEC pki --gen --type rsa --size 2048 --outform pem >$partKey
        chmod 600 $partKey
        $IPSEC pki --pub --in $partKey --type rsa | \
            $IPSEC pki --issue --lifetime 730 --outform pem \
                   --cacert $caCert \
                   --cakey $caKey \
                   --dn "C=CH, O=strongSwan, CN=$id" \
                   --san $id \
                   >$partCert
        echo "---------------- Party Certificate ----------------"
        $IPSEC pki --print --in $partCert
    else
        echo "There is already a key for $name at $partKey"
    fi
}

while read -u 3 -r line; do
    read -r caname name id <<<$line
    assert_ca $dir $caname
    gen_pem
done 3< <(grep -v '^\s*#' $parties_txt)
