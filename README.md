# A minimal docker image with dnscryptwrapper.

Work in progress, currently builds dnscrypt-wrapper

Maintainer: Egon Kidmose, kidmose@gmail.com

Copyright: dnscrypt.io

# Requirements

Docker

# Usage

To build the image and run bash in an instance:

  docker build -t dnscryptwrapper . && docker run -it dnscryptwrapper bash

# Todo

 [ ] Read certificate files from outside container
 [ ] Listen on ports from outside container
 [ ] Connect to DNS server outside container
 [ ] Enable starting through CMD/ENTRYPOINT
 [ ] Automate testing
