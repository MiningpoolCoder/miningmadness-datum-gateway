#!/bin/sh
# Builds a fully static datum_gateway inside an Alpine container.
# Usage (from repo root): docker run --rm -v "$PWD:/src" -w /src alpine:3.20 sh packaging/build-static.sh
set -eux
apk add --no-cache build-base cmake pkgconf git argp-standalone linux-headers \
	curl-dev curl-static openssl-libs-static nghttp2-static zlib-static brotli-static zstd-static \
	libidn2-static libunistring-static libpsl-static c-ares-static \
	jansson-dev jansson-static libsodium-dev libsodium-static \
	curl
# libmicrohttpd without TLS (the dashboard is plain HTTP), so no gnutls is needed.
MHD=libmicrohttpd-1.0.1
MHD_SHA256=a89e09fc9b4de34dde19f4fcb4faaa1ce10299b9908db1132bbfa1de47882b94
curl -fsSL -o /tmp/$MHD.tar.gz https://ftpmirror.gnu.org/libmicrohttpd/$MHD.tar.gz
echo "$MHD_SHA256  /tmp/$MHD.tar.gz" | sha256sum -c -
tar -C /tmp -xzf /tmp/$MHD.tar.gz
(cd /tmp/$MHD && ./configure --prefix=/usr/local --enable-static --disable-shared --disable-https \
	--disable-doc --disable-examples --disable-tools --disable-curl && make -j"$(nproc)" && make install)
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
git config --global --add safe.directory /src
rm -rf build-static
cmake -S . -B build-static -DCMAKE_BUILD_TYPE=Release -DSTATIC_BUILD=ON -DENABLE_API=${ENABLE_API:-ON}
cmake --build build-static --parallel
strip build-static/datum_gateway
file build-static/datum_gateway || true
./build-static/datum_gateway --help >/dev/null
./build-static/datum_gateway --test
