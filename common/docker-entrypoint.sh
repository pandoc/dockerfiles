#!/bin/sh
# Partially taken from the node image entrypoint script.
# See <https://github.com/nodejs/docker-node>

set -e

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- pandoc "$@"
fi

exec "$@"
