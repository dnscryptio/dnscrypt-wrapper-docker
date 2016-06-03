A minimal docker image with dnscryptwrapper.
Work in progress, currently fails.
Egon Kidmose, kidmose@gmail.com

To build the image, start a container, start a bash shell and interact with it:

    docker build -t dnscryptwrapper . && docker run -it dnscryptwrapper bash
