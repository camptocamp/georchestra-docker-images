FROM alpine:3.22

COPY build.sh /tmp/build.sh

# Install and configure everything needed
RUN /tmp/build.sh

# Default command
CMD ["tail", "-f", "/dev/null"]
