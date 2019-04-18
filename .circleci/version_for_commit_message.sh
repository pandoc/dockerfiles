#!/usr/bin/env bash

# Determine PANDOC_VERSION for Makefile based on commit message.  We are looking
# for if the string `release=X.Y` or `release=X.Y.Z` exists, if so then that is
# what we are going to build.  Otherwise, build the `master` branch (which is
# the `edge` image).
# DANGER: never use a commit message like "time to release=2.7.1." with a
#         trailing `.`.  `2.7.1.` will not be a valid tag on the pandoc repo.
# NOTE: cron jobs always build the :edge tag.
release_tag="$(git log --pretty="%s" -1 | grep -Eo 'release=[0-9\.]+')"
if [[ "$CIRCLE_CRON_JOB" == "true" ]] || [[ -z "$release_tag" ]]; then
    version="edge"
else
    version="$(echo "$release_tag" | cut -d = -f 2)"
fi

# Scripts calling this expect the output on stdout.
echo "$version"
