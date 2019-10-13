#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 pandoc_commit_or_branch" >&2
    exit 1
fi

set -eux

# Define cabal project to build.
mkdir -p /usr/src
echo "packages:" > /usr/src/cabal.project

# 1. Clone pandoc.
pandoc_commit="$1"
git clone --branch="$pandoc_commit" \
          --depth=1 \
          https://github.com/jgm/pandoc \
          /usr/src/pandoc
# >>>>>>>>>>>>> v slash required to tell cabal to use the folder!
echo "    pandoc/" >> /usr/src/cabal.project

# 3. Clone specific branch of pandoc-crossref if `master` build.  Otherwise, use
#    hackage to obtain for stable releases.  (Thanks @lierdakil <3)
if [ "$pandoc_commit" = "master" ]; then
    git clone --branch=pandoc_master \
              --depth=1 \
              https://github.com/lierdakil/pandoc-crossref \
              /usr/src/pandoc-crossref
    # >>>>>>>>>>>>>>>>>>>>>> v slash required to tell cabal to use this folder!
    echo "    pandoc-crossref/" >> /usr/src/cabal.project
fi

# 3. Gather specific pandoc-citeproc information from cloned pandoc.
echo "" >> /usr/src/cabal.project
# We are grabbing `source-repository-package` from pandoc:
#     https://github.com/jgm/pandoc/blob/master/cabal.project
# This awk call assumes pandoc-citeproc is the first "source-repository-package"
# and exits after it sees the next source-repository-package declaration.
awk '/source-repository-package/,/^$/{c += $0 == "source-repository-package"; if (c > 1) exit; print}' \
    /usr/src/pandoc/cabal.project >> /usr/src/cabal.project

# Dump to console (for debugging purposes via CI).
set +x
echo "Cabal project:"
echo "========================================================================="
cat /usr/src/cabal.project
echo "========================================================================="
