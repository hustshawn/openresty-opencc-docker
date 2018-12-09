FROM alpine:latest as builder
MAINTAINER Shawn Zhang <shawnzhang@lionfin.com.hk>

# Latest stable version
ARG OPENCC_VERSION="ver.1.0.5"
# RUN apk add --update alpine-sdk doxygen cmake \
RUN apk add cmake doxygen g++ make git python \
    && cd /tmp && git clone https://github.com/BYVoid/OpenCC.git && cd OpenCC \
    && git checkout -b ${OPENCC_VERSION} \
    && make \
    && make install \
    && mkdir -p /usr/lib64 \
    && cp /usr/lib/libopencc.so.2 /usr/lib64/libopencc.so.2 \
    && apk del make doxygen cmake

FROM openresty/openresty:1.13.6.2-alpine
MAINTAINER Shawn Zhang <shawnzhang@lionfin.com.hk>

# Set timezone
ENV TZ=Asia/Hong_Kong
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY --from=builder /usr/lib64 /usr/lib64
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/share/opencc /usr/share/opencc
COPY --from=builder /usr/bin/opencc* /usr/bin/
# # Copy OpendCC config and customized dictionary
# COPY ["lang-adapter/data/dictionary/", "lang-adapter/data/config/",  "/usr/share/opencc/"]
# # Copy lang-adapter lua scripts
# COPY lang-adapter/lang-adapter/lua/  /opt/lion-lang-adapter/lua/
# # Copy Nginx conf
# COPY lang-adapter/usr/local/openresty/nginx/conf/nginx-orig.conf /etc/nginx/conf.d/nginx.conf
