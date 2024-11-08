#!/bin/bash

set -e

DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
  /bin/run-parts -v --exit-on-error --regex '\.(sh|rb)$' "$DIR"
fi

exec "$@"

