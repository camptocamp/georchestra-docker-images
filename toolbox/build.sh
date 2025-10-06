#!/bin/ash

set -e

# Update package index
apk update

# Install required packages
# mitmproxy and tcpdump
apk add --no-cache \
    mitmproxy \
    tcpdump \
    bash \
    curl \
    wget \
    ioping \
    coreutils \
    openssl \
    gawk \
    bind-tools

# Clean up
rm -rf /var/cache/apk/*
