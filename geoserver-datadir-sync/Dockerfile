FROM debian:13.2-slim

LABEL maintainer="georchestra@camptocamp.com"
LABEL description="Modern GeoServer datadir synchronization with git-sync"

# Environment variables with defaults
ENV REMOTE_BRANCH=master \
    GIT_SYNC_INTERVAL=500

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        inotify-tools \
        curl \
        ca-certificates \
        openssh-client && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/*

# Download git-sync script from upstream
RUN curl -fsSL https://raw.githubusercontent.com/simonthum/git-sync/master/git-sync \
        -o /usr/local/bin/git-sync && \
    chmod +x /usr/local/bin/git-sync

# Create user and group for running the sync
RUN groupadd --gid 999 gitsync && \
    useradd -ms /bin/bash --home /home/gitsync --uid 999 --gid 999 gitsync

# Copy local scripts
COPY scripts/git-sync-on-inotify-webhook /usr/local/bin/git-sync-on-inotify-webhook
COPY scripts/entrypoint.sh /entrypoint.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/git-sync-on-inotify-webhook \
    /entrypoint.sh

# Create and set permissions for data directory
RUN mkdir -p /mnt/geoserver_datadir && \
    chown -R 999:999 /mnt/geoserver_datadir

VOLUME ["/mnt/geoserver_datadir"]
WORKDIR /mnt/geoserver_datadir

USER gitsync

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/git-sync-on-inotify-webhook"]
