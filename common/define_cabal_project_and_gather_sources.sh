#!/bin/sh

# Clone specified pandoc ref (commit, tag, branch) into /usr/src/pandoc,
# generate /usr/src/cabal.project, and potentially clone pandoc-crossref
# depending on pandoc ref specified in $1.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 pandoc_commit_or_branch" >&2
    exit 1
fi

set -eux

# Define cabal project to build.
mkdir -p /usr/src
echo "packages:" > /usr/src/cabal.project

# 1. Clone pandoc.  Want to be able to clone specific branches, tags, and
#    commits (helpful for bisecting build problems).
pandoc_commit="$1"
git clone https://github.com/jgm/pandoc /usr/src/pandoc
old_pwd="$PWD"  # pushd / popd not available on alpine
cd /usr/src/pandoc
git checkout "$pandoc_commit"  # cannot clone specific commit, only branch / tag
cd "$old_pwd"
# >>>>>>>>>>>>> v slash required for cabal to use the folder!
echo "    pandoc/" >> /usr/src/cabal.project

# 3. Clone specific branch of pandoc-crossref if non-release-tag build.
#    Otherwise, use hackage to obtain for stable releases.  Does not work for
#    branches with `.` in them, `pandoc` has few of these though.
#    (Thanks @lierdakil for `pandoc_master` branch <3)
# NOTE: commits older than latest `pandoc` release will break.  `pandoc_master`
#       branch tracks changes to `pandoc-crossref` that will land after next
#       `pandoc` released.  If older commit needed, comment below / set `tag=1`.
tag="$(echo "$pandoc_commit" | awk '{c=0} /^[0-9\.]+$/ {c++} END {print c}')"
if [ "$tag" = "0" ]; then
    git clone --branch=pandoc_master \
              --depth=1 \
              https://github.com/lierdakil/pandoc-crossref \
              /usr/src/pandoc-crossref
    # >>>>>>>>>>>>>>>>>>>>>> v slash required for cabal to use the folder!
    echo "    pandoc-crossref/" >> /usr/src/cabal.project
fi

# 3. Gather specific pandoc-citeproc information from cloned pandoc.
echo "" >> /usr/src/cabal.project
# Acquire `source-repository-package` definitions from pandoc:
#     https://github.com/jgm/pandoc/blob/master/cabal.project
awk '/^\S/{P=0}/^source-repository-package$/{P=1}(P){print}' \
    /usr/src/pandoc/cabal.project >> /usr/src/cabal.project

# Dump to console (for debugging purposes via CI).
set +x
echo "Cabal project:"
echo "========================================================================="
cat /usr/src/cabal.project
echo "========================================================================="
