FROM alpine:latest as builder
LABEL MAINTAINER="Shawn Zhang <hustshawn@gmail.com>"

# Latest stable version
ARG OPENCC_VERSION="ver.1.0.5"

RUN apk add cmake doxygen g++ make git python \
    && cd /tmp && git clone https://github.com/BYVoid/OpenCC.git && cd OpenCC \
    && git checkout -b ${OPENCC_VERSION} \
    && make \
    && make install \
    && mkdir -p /usr/lib64 \
    && cp /usr/lib/libopencc.so.2 /usr/lib64/libopencc.so.2 \
    && apk del make doxygen cmake

FROM openresty/openresty:1.13.6.2-alpine

# COPY opencc binary
COPY --from=builder /usr/lib64 /usr/lib64
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/share/opencc /usr/share/opencc
COPY --from=builder /usr/bin/opencc* /usr/bin/

# Set timezone
ENV TZ=Asia/Hong_Kong
RUN apk add tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    apk del tzdata
