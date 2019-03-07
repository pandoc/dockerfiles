#!/usr/bin/env bash

# Determine PANDOC_VERSION for Makefile based on commit message.  We are looking
# for if the string `release=X.Y` exists, if so then that is what we are going
# to build.  Otherwise, build the `master` branch (which is the `edge` image).
# NOTE: cron jobs always build the :edge tag.
release_tag="$(git log --pretty="%s" -1 | grep -o 'release=[0-9]\.[0-9]')"
if [[ "$CIRCLE_CRON_JOB" == "true" ]] || [[ -z "$release_tag" ]]; then
    version="edge"
else
    version="$(echo "$release_tag" | cut -d = -f 2)"
fi

# Scripts calling this expect the output on stdout.
echo "$version"
