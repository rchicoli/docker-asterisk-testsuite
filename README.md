# Dockerfile for Asterisk testsuite

More info to run the test here :

    https://wiki.asterisk.org/wiki/display/AST/Running+the+Asterisk+Test+Suite

## Install Docker

To install docker on Linux :

    curl -sL https://get.docker.io /| sh

 or

     wget -qO- https://get.docker.io/ | sh

## Build

To build the image, simply invoke

    docker build -t asterisk-testsuite github.com/sboily/asterisk-testsuite.git

Or directly in the sources

    docker build -t asterisk-testsuite .

If you don't want to build go directly to the section from docker hub.

## Usage

To run the container, do the following:

    docker run -d -P asterisk-testsuite

On interactive mode:

    docker run -i -t asterisk-testsuite /bin/bash

From docker hub:

    docker run -i -t quintana/asterisk-testsuite /bin/bash

After launch runtest.

    ./runtests.py

## Infos

- If you want to using a simple webi to administrate docker use : https://github.com/crosbymichael/dockerui
