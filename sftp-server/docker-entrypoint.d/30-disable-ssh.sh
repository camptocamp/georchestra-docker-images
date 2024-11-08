#!/bin/bash
set -e

if [ "${DISABLE_SSH,,}" = "true" ]; then
    cp /etc/ssh/sshd_config.client /etc/ssh/sshd_config
fi

