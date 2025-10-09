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
    openjdk11-jre-headless \
    openssl \
    gawk \
    hdparm \
    bind-tools

# Clean up
rm -rf /var/cache/apk/*

wget https://github.com/jiaqi/jmxterm/releases/download/v1.0.4/jmxterm-1.0.4-uber.jar -O /opt/jmxterm.jar
