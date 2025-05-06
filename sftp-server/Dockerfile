FROM debian:12.10

COPY build.sh /tmp/build.sh

# Install and configure everything needed
RUN /tmp/build.sh

# Define VOLUMES
VOLUME ["/etc/ssh/ssh_host_keys", "/home/sftp"]

# Configure entrypoint and command
COPY docker-entrypoint.sh /
COPY docker-entrypoint.d /docker-entrypoint.d

EXPOSE 22
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
