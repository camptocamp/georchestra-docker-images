#!/bin/bash

if [ -n "$SFTP_UID" ]; then
  usermod --non-unique --uid $SFTP_UID sftp
  chown -R sftp /home/sftp
fi
