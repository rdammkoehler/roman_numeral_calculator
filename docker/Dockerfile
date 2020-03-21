FROM ubuntu:14.04
RUN apt-get update
RUN apt-get install -y build-essential git vim emacs24-nox automake autoconf libtool pkg-config texinfo gcc make splint valgrind vim
RUN echo 'building check-0.10.0 from source' && mkdir check-0.10.0
COPY check-0.10.0 check-0.10.0/
RUN cd check-0.10.0 && autoreconf --install && ./configure && make && make install
RUN useradd rich
