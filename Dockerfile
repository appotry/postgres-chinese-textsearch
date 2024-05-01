FROM postgres:16-alpine

RUN set -ex \
    && apk add --no-cache --virtual .build-deps gcc libc-dev make pkgconf clang llvm cmake g++\
    && apk add --no-cache git build-base linux-headers make postgresql-dev automake libtool autoconf m4 \
    && wget -q -O - "https://github.com/hightman/scws/archive/master.tar.gz" | tar zxf - \
    && wget -q -O - "https://github.com/amutu/zhparser/archive/master.tar.gz" | tar zxf - \
    && wget -q -O - "https://github.com/jaiminpan/pg_jieba/archive/master.tar.gz" | tar zxf - \
    && git clone --depth=1 --branch=master https://github.com/yanyiwu/cppjieba.git \
    && cd cppjieba \
    && git submodule init && git submodule update \
    && cd /scws-master \
    && touch README;aclocal;autoconf;autoheader;libtoolize;automake --add-missing \
    && ./configure \
    && make install \
    && cd /zhparser-master \
    && make \
    && make install \
    && mv /cppjieba/* /pg_jieba-master/libjieba \
    && mkdir /pg_jieba-master/build \
    && cd /pg_jieba-master/build \
    && cmake .. \
    && make \
    && make install \
    && echo "echo \"shared_preload_libraries = 'pg_jieba.so'\" >> /var/lib/postgresql/data/postgresql.conf" > /docker-entrypoint-initdb.d/load-lib.sh \
    && apk del .build-deps \
    && rm -rf /zhparser-master /scws-master /cppjieba /pg_jieba-master
COPY install_extension.sql /docker-entrypoint-initdb.d/
