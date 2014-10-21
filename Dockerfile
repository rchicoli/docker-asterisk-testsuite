## Image to build from sources

FROM debian:latest
MAINTAINER Sylvain Boily "sboily@avencall.com"

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# Add dependencies
RUN apt-get -qq update
RUN apt-get -qq -y install \
    wget \
    apt-utils \
    git \
    subversion \
    python-yaml \
    python-twisted \
    libncurses-dev \
    uuid-dev \
    libjansson-dev \
    libxml2-dev \
    libsqlite3-dev \
    libpcap-dev \
    bzip2 \
    cython \
    build-essential \
    curl \
    liblua5.1-dev \
    lua5.1 \
    python-setuptools \
    libssl-dev \
    python-dev

# Install Asterisk
WORKDIR /usr/src
RUN svn checkout http://svn.asterisk.org/svn/asterisk/trunk asterisk
WORKDIR /usr/src/asterisk
RUN ./configure
RUN make
RUN make install
RUN make samples
RUN make config

# Install SIPp
WORKDIR /usr/src
RUN wget http://sipp.sourceforge.net/snapshots/sipp.2009-07-29.tar.gz
RUN tar xfvz sipp.2009-07-29.tar.gz
WORKDIR /usr/src/sipp.svn
RUN make pcapplay_ossl
RUN cp sipp /usr/local/bin

# Install testsuite
WORKDIR /usr/src
RUN svn checkout http://svn.asterisk.org/svn/testsuite/asterisk/trunk testsuite
WORKDIR /usr/src/testsuite

# Install asttest
WORKDIR /usr/src/testsuite/asttest
RUN make
RUN make install

# Install starpy
WORKDIR /usr/src/testsuite/addons
RUN make update
WORKDIR starpy
RUN python setup.py install

# Install pjsua
WORKDIR /usr/src
RUN wget http://www.pjsip.org/release/1.16/pjproject-1.16.tar.bz2
RUN tar xfvj pjproject-1.16.tar.bz2
WORKDIR /usr/src/pjproject-1.16
RUN ./configure CFLAGS=-fPIC
RUN echo "#define PJ_HAS_IPV6 1" > pjlib/include/pj/config_site.h
RUN make dep
RUN make
RUN cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/local/bin/pjsua
WORKDIR pjsip-apps/src/python
RUN python ./setup.py install

# Install yappcap
WORKDIR /usr/src
RUN git clone https://github.com/otherwiseguy/yappcap.git 
WORKDIR /usr/src/yappcap
RUN make
RUN make install

# Clean
RUN apt-get clean

WORKDIR /usr/src/testsuite
