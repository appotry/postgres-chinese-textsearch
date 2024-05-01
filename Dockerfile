FROM postgres:16-alpine

RUN set -ex \
    && apk add --no-cache --virtual .build-deps gcc libc-dev make pkgconf clang llvm cmake g++\
    && wget -q -O - http://www.xunsearch.com/scws/down/scws-1.2.3.tar.bz2 | tar jxf - \
    && wget -q -O - "https://github.com/amutu/zhparser/archive/master.tar.gz" | tar zxf - \
    && wget -q -O - "https://github.com/jaiminpan/pg_jieba/archive/master.tar.gz" | tar zxf - \
    && wget -q -O - "https://github.com/yanyiwu/cppjieba/archive/refs/tags/v5.1.0.tar.gz" | tar zxf - \
    && cd /scws-1.2.3 \
    && ./configure \
    && make install \
    && cd /zhparser-master \
    && make \
    && make install \
    && mv /cppjieba-5.1.0/* /pg_jieba-master/libjieba \
    && mkdir /pg_jieba-master/build \
    && cd /pg_jieba-master/build \
    && cmake .. \
    && make \
    && make install \
    && echo "echo \"shared_preload_libraries = 'pg_jieba.so'\" >> /var/lib/postgresql/data/postgresql.conf" > /docker-entrypoint-initdb.d/load-lib.sh \
    && apk del .build-deps \
    && rm -rf /zhparser-master /scws-1.2.3 /cppjieba-* /pg_jieba-master
COPY install_extension.sql /docker-entrypoint-initdb.d/
