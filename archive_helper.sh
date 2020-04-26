#!/bin/sh

archive_year="2019"
for img in "latex"; do  # TODO: add ubuntu or others here
    # NOTE: in future, only one loop will be needed.
    # TODO TODO TODO
    # apaprently some are 2018 images, need to download all and find out :(
    for tag in \
            2.6 \
            2.7; do
        echo make archive BASE_IMAGE="$img" ARCHIVE_YEAR="$archive_year" PANDOC_VERSION="$tag"
    done
    for tag in \
            2.7.1 \
            2.7.2 \
            2.7.3 \
            2.8 \
            2.8.0.1 \
            2.8.1 \
            2.9 \
            2.9.0 \
            2.9.1 \
            2.8.0 \
            2.7.0 \
            2.9.1.1 \
            2.9.2 \
            2.9.2.1 \
            latest; do
        echo "$img -- $tag"
    done
done
