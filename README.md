# Usage

First, choose a secure location to store pki, e.g. "~/.verysecure/strongswan"

```bash
PKIDIR=~/.verysecure/strongswan
```

Certificates (and keys) can expire. For the ease of future renewal, each certificate and key is suffixed with today's timestamp.

Each of the three scripts, if run with no arguments, prints its usage and exits.

## Create CA

Currently a `$PKIDIR` has only one ca.

```bash
$CANAME=only used as an identifier
```

```bash
./ca-key.sh $PKIDIR caname
```

CA certificates can expire. A symlink, representing currently used certificate and key, points to the most recently created ones with a timestamp.

## Generate Server Key

```bash
./server-key.sh $PKIDIR server
```

## Generate Client Key

```bash
./client-key.sh $PKIDIR client email
```
