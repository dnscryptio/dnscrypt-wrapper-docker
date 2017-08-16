#!/bin/bash

HKEYDIR="hkeyvolume"
CKEYDIR=/opt/dnscrypt-wrapper/etc/keys

echo "-> Build dnscrypt-wrapper"
docker build -t dnscryptio/dnscrypt-wrapper .

echo "-> Run bind"
docker run -d --name bind dnscryptio/bind
BINDIP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' bind)
echo "-> BIND is running on $BINDIP"

echo "-> Run dnscrypt-wrapper --version"
docker run --interactive --tty --rm dnscryptio/dnscrypt-wrapper --version

echo "-> Generate and get provider keypair"
docker run --interactive --tty --rm --volume $HKEYDIR:$CKEYDIR -w $CKEYDIR dnscryptio/dnscrypt-wrapper --gen-provider-keypair | tee /tmp/gen-provider-keypair.log
cat /tmp/gen-provider-keypair.log
PUBLIC_KEYPAIR_FINGERPRINT=$(egrep 'Provider public key: ' /tmp/gen-provider-keypair.log | sed 's/Provider public key: //')

echo "-> Generate service keypair"
docker run --interactive --tty --rm --volume $HKEYDIR:$CKEYDIR -w $CKEYDIR dnscryptio/dnscrypt-wrapper --gen-crypt-keypair

echo "-> Generate cert"
docker run --interactive --tty --rm --volume $HKEYDIR:$CKEYDIR -w $CKEYDIR dnscryptio/dnscrypt-wrapper --gen-cert-file

echo "-> Run and detach dnscrypt-wrapper"
docker run --volume $HKEYDIR:$CKEYDIR -w $CKEYDIR --expose=4443 --name=wrapper --detach dnscryptio/dnscrypt-wrapper --listen-address=0.0.0.0:4443 --resolver-address=$BINDIP:53 --provider-name=2.dnscrypt-cert.test.dnscrypt.io --provider-cert-file=$CKEYDIR/dnscrypt.cert --crypt-secretkey-file=$CKEYDIR/crypt_secret.key

echo "-> Test for running dnscrypt-wrapper and show logs"
sleep 10; docker ps | grep dnscrypt-wrapper
docker logs --details -t wrapper

WRAPPERIP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' wrapper)
echo "-> dnscrypt-wrapper is running on IP $WRAPPERIP"
echo "-> Provider key: $PUBLIC_KEYPAIR_FINGERPRINT"
echo "-> Run and detach dnscrypt-proxy, show logs"
docker run --detach --name=proxy -e RESOLVER_ADDR=$WRAPPERIP:4443 -e PROVIDER_NAME=2.dnscrypt-cert.test.dnscrypt.io -e PROVIDER_KEY=$PUBLIC_KEYPAIR_FINGERPRINT -e LOGLEVEL=7 -p 127.0.0.1:53:53/udp dnscryptio/dnscrypt-proxy
docker logs -t --details proxy

echo "-> Test for working DNS lookups via dnscrypt-proxy"
dig @127.0.0.1 www.google.com

rm /tmp/gen-provider-keypair.log
rm /tmp/fingerprint
docker stop proxy; docker stop wrapper; docker stop bind; docker rm proxy; docker rm wrapper; docker rm bind
docker volume rm $HKEYDIR
