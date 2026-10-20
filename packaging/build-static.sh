#!/bin/sh
# Builds a fully static datum_gateway inside an Alpine container.
# Usage (from repo root): docker run --rm -v "$PWD:/src" -w /src alpine:3.20 sh packaging/build-static.sh
set -eux
apk add --no-cache build-base cmake pkgconf git argp-standalone linux-headers \
	curl-dev curl-static openssl-libs-static nghttp2-static zlib-static brotli-static zstd-static \
	libidn2-static libunistring-static libpsl-static c-ares-static \
	jansson-dev jansson-static libsodium-dev libsodium-static \
	libmicrohttpd-dev libmicrohttpd-static
git config --global --add safe.directory /src
rm -rf build-static
cmake -S . -B build-static -DCMAKE_BUILD_TYPE=Release -DSTATIC_BUILD=ON -DENABLE_API=${ENABLE_API:-ON}
cmake --build build-static --parallel
strip build-static/datum_gateway
file build-static/datum_gateway || true
./build-static/datum_gateway --help >/dev/null
./build-static/datum_gateway --test
