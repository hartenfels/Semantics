FROM library/rakudo-star:2017.01
MAINTAINER Carsten Hartenfels

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
 && apt-get -y update \
 && apt-get -yt jessie-backports install openjdk-8-jdk-headless \
 && apt-get -y install gcc make unzip

COPY .  /usr/src/semantics
WORKDIR /usr/src/semantics

RUN ./configure && make && rm -rf KBCACHE

ENTRYPOINT ["/usr/src/semantics/semantics"]
