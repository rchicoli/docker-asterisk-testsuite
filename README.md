Dockerfile for Asterisk testsuite (or PaulSuite)

## Install Docker

To install docker on Linux :

    curl -sL https://get.docker.io/ | sh
 
 or
 
     wget -qO- https://get.docker.io/ | sh

## Build

To build the image, simply invoke

    docker build -t asterisk-testsuite github.com/sboily/asterisk-testsuite.git

Or directly in the sources

    docker build -t asterisk-testsuite .
  
## Usage

To run the container, do the following:

    docker run -d -P asterisk-testsuite

On interactive mode :

    docker run -i -t asterisk-testsuite /bin/bash

After launch runtest.

    ./runtests.py

## Infos

- Using docker version 1.3.0 (from get.docker.io) on ubuntu 14.04.
- If you want to using a simple webi to administrate docker use : https://github.com/crosbymichael/dockerui
