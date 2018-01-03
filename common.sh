assert_ca() {
    local dir=$1
    local ca=$2
    if [ ! -d $dir/$ca ]; then
        echo "$dir/$ca not a directory"
        echo "Maybe you should call '$__DIR__/gen-ca.sh $dir $ca'"
        exit 1
    fi
}
