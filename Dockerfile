FROM alpine:latest
MAINTAINER Wu Ping <ncwuping@hotmail.com>

# Add keepalived default script user to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
RUN addgroup -S keepalived_script && adduser -D -S -G keepalived_script keepalived_script

ENV KEEPALIVED_VERSION 2.0.20

# 1. install required libraries and tools
# 2. compile and install keepalived
# 3. remove keepalived sources and unnecessary libraries and tools
RUN apk --no-cache add \
       gcc \
       ipset \
       ipset-dev \
       iptables \
       iptables-dev \
       libnfnetlink \
       libnfnetlink-dev \
       libnl3 \
       libnl3-dev \
       make \
       musl-dev \
       openssl \
       openssl-dev \
       autoconf \
 \
 && wget -q "https://www.keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz" \
 && tar zxf keepalived-${KEEPALIVED_VERSION}.tar.gz \
 && cd keepalived-${KEEPALIVED_VERSION} \
 && ./configure --disable-dynamic-linking \
 && make && make install \
 && cd - \
 \
 && rm -rf keepalived-${KEEPALIVED_VERSION} keepalived-${KEEPALIVED_VERSION}.tar.gz \
 && apk --no-cache del \
       gcc \
       ipset-dev \
       iptables-dev \
       libnfnetlink-dev \
       libnl3-dev \
       make \
       musl-dev \
       openssl-dev \
       autoconf

# set keepalived as image entrypoint with --dont-fork and --log-console (to make it docker friendly)
# define /usr/local/etc/keepalived/keepalived.conf as the configuration file to use
ENTRYPOINT ["/usr/local/sbin/keepalived","--dont-fork","--log-console", "-f","/usr/local/etc/keepalived/keepalived.conf"]

# example command to customise keepalived daemon:
# CMD ["--log-detail","--dump-conf"]
