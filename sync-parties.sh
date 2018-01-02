#!/bin/bash

trap '>&2 echo Error on line $LINENO' ERR

if [ $# -ne 1 ]; then
    echo usage: $0 dir
    exit 1
fi

__DIR__=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

. $__DIR__/common.sh

dir=$1

ssh_txt=$dir/ssh.txt
parties_txt=$dir/parties.txt

if [ ! -r $ssh_txt ]; then
    echo "$ssh_txt not found!"
    echo "Lines could be commented with a starting '#'"
    echo "Example content of the file:"
    echo "name /etc/swanctl local"
    echo "name /etc/swanctl ssh@ssh.host"
    echo "name pkcs12"
    exit 1
fi

declare -A HOSTS
declare -A SWANCTL_DIR

while read -r line; do
    read -r host swanctl_dir ssh_opts <<<$line
    HOSTS[$host]=$ssh_opts
    SWANCTL_DIR[$host]=$swanctl_dir
done < <(grep -v '^\s*#' $ssh_txt)

sync_conf() {
    swanctl_dir=${SWANCTL_DIR[$name]}
    ssh_opts=${HOSTS[$name]}

    caDir=$dir/$caname
    caCert=$caDir/ca/$caname-cert.pem
    partDir=$caDir/$name
    partKey=$partDir/$id-key.pem
    partCert=$partDir/$id-cert.pem
    partP12=$partDir/$id-cert.p12

    if [ z"$swanctl_dir" == zpkcs12 ]; then
        echo "Generating PKCS12 for $name in $caname"
        openssl pkcs12 -in $partCert -inkey $partKey -certfile $caCert -export -out $partP12
        echo "Generated"
    elif [ z"$ssh_opts" == zlocalhost ]; then
        echo "Copying for $name in $caname"
        sudo cp $caCert $swanctl_dir/x509ca/
        sudo cp $partCert $swanctl_dir/x509/
        sudo cp $partKey $swanctl_dir/rsa/
        echo "Copied"
    else
        echo "Uploading for $name in $caname"
        gzip -c $caCert | ssh $ssh_opts "sudo bash -c 'gzip -d >$swanctl_dir/x509ca/$caname-cert.pem'"
        gzip -c $partCert | ssh $ssh_opts "sudo bash -c 'gzip -d >$swanctl_dir/x509/$id-cert.pem'"
        gzip -c $partKey | ssh $ssh_opts "sudo bash -c 'gzip -d >$swanctl_dir/rsa/$id-key.pem'"
        echo "Uploaded"
    fi
}


while read -u 3 -r line; do
    read -r caname name id <<<$line
    assert_ca $dir $caname
    sync_conf
done 3< <(grep -v '^\s*#' $parties_txt)
