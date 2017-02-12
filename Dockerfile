FROM library/rakudo-star:2017.01
MAINTAINER Carsten Hartenfels

RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main'     >> /etc/apt/sources.list.d/java-8-debian.list \
 && echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list.d/java-8-debian.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
 && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
 && echo debconf shared/accepted-oracle-license-v1-1 seen   true | debconf-set-selections \
 && apt-get -y update \
 && apt-get -y install build-essential unzip oracle-java8-installer oracle-java8-set-default \
 && mkdir -p /usr/lib/jvm/java-8-oracle/jre/lib/management \
 && echo 'com.oracle.usagetracker.logToUDP = 127.0.0.1:54321' > /usr/lib/jvm/java-8-oracle/jre/lib/management/usagetracker.properties

COPY .  /usr/src/semantics
WORKDIR /usr/src/semantics

RUN ./configure && make && rm -rf KBCACHE

ENTRYPOINT ["/usr/src/semantics/semantics"]
