FROM php:8.3-apache

# set fixed UID and GID - see github.com/hexops/dockerfile
ARG UID=999
ARG GID=999

# change the www-data user and group ID
RUN groupmod --gid ${GID} www-data && \
    usermod --non-unique --uid ${UID} --gid ${GID} www-data

COPY build.sh /tmp/build.sh

# Install and configure everything needed
RUN /tmp/build.sh
