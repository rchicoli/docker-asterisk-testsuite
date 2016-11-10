## Image to build from sources

FROM debian:latest
MAINTAINER Sylvain Boily "sboily@proformatique.com"
MAINTAINER XiVO dev team "dev+docker@proformatique.com"

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# Add dependencies
RUN apt-get -qq update && \
    apt-get -qq -y install \
    aptitude \
    build-essential \
    git \
    libasound2-dev \
    libncurses-dev \
    libpcap-dev \
    python-dev \
    python-setuptools \
    python-twisted \
    python-pip \
    python-yaml \
    wget

# Install pjproject & PJSUA
WORKDIR /usr/src
RUN wget --quiet http://pjsip.org/release/2.5.5/pjproject-2.5.5.tar.bz2 && \
    tar xf pjproject-2.5.5.tar.bz2 && \
    cd pjproject-2.5.5 && \
    ./configure --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG -fPIC' && \
    cp pjlib/include/pj/config_site_sample.h pjlib/include/pj/config_site.h && \
    echo "#define PJ_HAS_IPV6 1" >> pjlib/include/pj/config_site.h && \
    make dep && \
    make && \
    make install && \
    cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/local/bin/pjsua && \
    make -C pjsip-apps/src/python install && \
    cd /usr/src && \
    rm -rf pjproject-2.5.5.tar.bz2 pjproject-2.5.5

# Install Asterisk
WORKDIR /usr/src
RUN git clone --depth 1 https://gerrit.asterisk.org/asterisk && \
    cd /usr/src/asterisk/contrib/scripts && \
    ./install_prereq install && \
    cd /usr/src/asterisk && \
    ./configure --enable-dev-mode && \
    make menuselect && \
    menuselect/menuselect --enable TEST_FRAMEWORK menuselect.makeopts && \
    make && \
    make install && \
    # make samples creates asterisk.conf, musiconhold.conf, etc.
    make samples && \
    cd /usr/src && \
    rm -rf asterisk

# Install SIPp
WORKDIR /usr/src
RUN wget --quiet https://github.com/SIPp/sipp/archive/v3.4.1.tar.gz && \
    tar -zxvf v3.4.1.tar.gz && \
    cd /usr/src/sipp-3.4.1 && \
    ./configure --with-pcap --with-openssl && \
    make install && \
    cd /usr/src && \
    rm -rf sipp-3.4.1 sipp-3.4.1.tar.gz

# Install autobahn
RUN pip install autobahn

# Install testsuite
WORKDIR /usr/src
RUN git clone --depth 1 https://gerrit.asterisk.org/testsuite && \
    cd /usr/src/testsuite/asttest && \
    make && \
    make install && \
    cd /usr/src/testsuite/addons && \
    make update && \
    cd starpy && \
    python setup.py install

WORKDIR /usr/src/testsuite
CMD ./runtests.py
