# A minimal docker image with dnscryptwrapper.

Work in progress, currently builds dnscrypt-wrapper

Maintainer: Egon Kidmose, kidmose@gmail.com

Copyright: dnscrypt.io

# Requirements

Docker

# Usage

To build the image:

    docker build -t dnscrypt-wrapper .

To run a container in interactive mode:

    KEYDIR=<WHERE-KEYS-RESIDE-ON-HOST>
    docker run -it -v $KEYDIR:/opt/dnscrypt-wrapper/etc/keys -p 127.0.0.1:4443:4443/udp dnscrypt-wrapper \
    --listen-address=0.0.0.0:4443 \
    --resolver-address=8.8.8.8:53 \
    --provider-name=2.dnscrypt-cert.example.com \
    --provider-cert-file=/opt/dnscrypt-wrapper/etc/keys/dnscrypt.cert \
    --crypt-secretkey-file=/opt/dnscrypt-wrapper/etc/keys/dnscrypt.key

To test (requires dnscrypt-proxy):

    sudo /opt/dnscrypt-proxy/sbin/dnscrypt-proxy \
    --provider-key=2DE4:CBAF:D282:6AD0:1DD6:7633:2D83:50E0:B3F6:3699:943E:4D15:42B8:9430:3F1E:1E3F \
    --resolver-address=127.0.0.1:4443 \
    --provider-name=2.dnscrypt-cert.example.com

# Todo

 * Run as daemon
 * Understand why provider name apparently have to start with 2.dnscrypt-cert
 * Automate testing
