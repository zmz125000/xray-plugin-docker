FROM golang:alpine as builder
RUN set -xe \
    && apk add --no-cache git \
    && go get -insecure github.com/teddysun/xray-plugin
FROM shadowsocks/shadowsocks-libev:edge
USER root
RUN set -xe \
    && apk add --no-cache ca-certificates
COPY --from=builder /go/bin/xray-plugin /usr/local/bin

ENV PLUGIN_OPTS="server" \
    PLUGIN="xray-plugin"

USER nobody

CMD exec ss-server \
    -s $SERVER_ADDR \
    -p $SERVER_PORT \
    -k ${PASSWORD:-$(hostname)} \
    -m $METHOD \
    -t $TIMEOUT \
    -d $DNS_ADDRS \
    -u \
    --plugin $PLUGIN \
    --plugin-opts $PLUGIN_OPTS \
    $ARGS
