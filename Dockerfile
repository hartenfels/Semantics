FROM library/rakudo-star:2017.04
MAINTAINER Carsten Hartenfels

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list \
 && apt-get -y update \
 && apt-get -yt jessie-backports install openjdk-8-jdk-headless \
 && apt-get -y install make psmisc

COPY .  /usr/src/semantics
WORKDIR /usr/src/semantics

RUN cd /usr/src/semantics/semserv; \
    java -jar semserv.jar >/dev/null & \
    cd /usr/src/semantics; \
    make; \
    killall java; \
    echo '#!/bin/bash'                         >servsemantics; \
    echo 'cd /usr/src/semantics/semserv'      >>servsemantics; \
    echo 'java -jar semserv.jar >/dev/null &' >>servsemantics; \
    echo 'cd /usr/src/semantics'              >>servsemantics; \
    echo './semantics "$@"'                   >>servsemantics; \
    echo 'ret="$?"'                           >>servsemantics; \
    echo 'killall java'                       >>servsemantics; \
    echo 'exit "$ret"'                        >>servsemantics; \
    chmod +x servsemantics

ENTRYPOINT ["/usr/src/semantics/servsemantics"]
