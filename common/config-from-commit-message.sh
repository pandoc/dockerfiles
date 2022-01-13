#!/bin/sh

# Determine PANDOC_VERSION for Makefile based on commit message. We
# are looking for if the string `release=X.Y` or `release=X.Y.Z`
# exists, if so then that is what we are going to build. Otherwise,
# build the `master` branch (which is # the `edge` image).
version=$(git log --pretty='%B' -1 | \
           sed -ne 's#.*\brelease=\(.*\)$#\1#p' | \
           sed -e  's# *, *#\n#g' | \
           sed -ne 's#^\([0-9]*\(\.[0-9]*\)*\)*$#"\1"#p' | \
           tr '\n' ',')

# |
#.*\?#\1#p')"

if [ -z "$version" ]; then
    version="edge"
fi

printf "pandoc_versions='%s'\n" "[$version]"
