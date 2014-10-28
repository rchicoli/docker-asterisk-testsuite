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
    procps \
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
    python-requests \
    libcurl4-gnutls-dev \
    libsrtp0-dev \
    libtiff-dev \
    libspandsp-dev \
    python-dev

# Install pjproject
WORKDIR /usr/src
RUN wget http://www.pjsip.org/release/2.2.1/pjproject-2.2.1.tar.bz2
RUN tar -xjvf pjproject-2.2.1.tar.bz2
WORKDIR /usr/src/pjproject-2.2.1
ENV CFLAGS -DPJ_HAS_IPV6=1
RUN ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr
RUN make dep
RUN make
RUN make install
RUN ldconfig

# Install Asterisk
WORKDIR /usr/src
RUN svn checkout http://svn.asterisk.org/svn/asterisk/trunk asterisk
WORKDIR /usr/src/asterisk
RUN ./configure --enable-dev-mode
RUN make menuselect
RUN menuselect/menuselect --enable TEST_FRAMEWORK menuselect.makeopts
RUN make
RUN make install
RUN make samples
RUN make config

# Install SIPp
WORKDIR /usr/src
RUN git clone https://github.com/SIPp/sipp.git
WORKDIR /usr/src/sipp
RUN git submodule update --init
RUN ./configure --with-pcap --with-openssl 
RUN make sipp_unittest
RUN make
RUN cp sipp /usr/local/bin

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


# Install testsuite
WORKDIR /usr/src
RUN svn checkout http://svn.asterisk.org/svn/testsuite/asterisk/trunk testsuite

# Install asttest
WORKDIR /usr/src/testsuite/asttest
RUN make
RUN make install

# Install starpy
WORKDIR /usr/src/testsuite/addons
RUN make update
WORKDIR starpy
RUN python setup.py install

# Install yappcap
WORKDIR /usr/src
RUN git clone https://github.com/otherwiseguy/yappcap.git 
WORKDIR /usr/src/yappcap
RUN make
RUN make install

# Install Autobahn
WORKDIR /usr/src 
RUN git clone https://github.com/tavendo/AutobahnPython.git
WORKDIR /usr/src/AutobahnPython/autobahn
RUN python ./setup.py install

# Install pyXB
WORKDIR /usr/src 
RUN git clone https://github.com/pabigot/pyxb.git
WORKDIR /usr/src/pyxb
RUN python ./setup.py install

# Install construct
WORKDIR /usr/src 
RUN git clone https://github.com/construct/construct.git
WORKDIR /usr/src/construct
RUN python ./setup.py install

# Clean
RUN apt-get clean
WORKDIR /usr/src 
RUN rm -rf AutobahnPython \
           construct \
           pjproject-1.16.tar.bz2 \
           pjproject-2.2.1.tar.bz2  \
           sipp \
           yappcap \
           asterisk \
           pjproject-1.16 \
           pjproject-2.2.1 \
           pyxb

WORKDIR /usr/src/testsuite
CMD ./runtests.py
