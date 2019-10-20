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

################################################################################
# HACK:
# LaTeX 2019 need to bypass: https://github.com/jgm/pandoc/issues/5801
# We will re-release 2.6 ... 2.7.3 to add pandoc-crossref, this code will not
# be needed forever.
#
# Crude version detection: always make sure to check != $pandoc_commit!
major="$(echo "$pandoc_commit" | sed 's/^\([0-9]\)\..*$/\1/')"
minor="$(echo "$pandoc_commit" | sed 's/^[0-9]\.\([0-9]\).*$/\1/')"
patch="$(echo "$pandoc_commit" | sed 's/^[0-9]\.[0-9]\.\([0-9]\)$/\1/')"
do_patch=0
if ! [ "$major" = "$pandoc_commit" ]; then
    if [ "$major" = "2" ]; then
        if ! [ "$minor" = "$pandoc_commit" ]; then
            if [ "$minor" -le 7 ]; then
                if [ "$patch" = "$pandoc_commit" ]; then
                    do_patch=1
                elif [ "$patch" -le 3 ]; then
                    do_patch=1
                fi
            fi
        fi
    fi
fi
# https://github.com/jgm/pandoc/commit/d9db76dcf40d1930ad15317d76fd2c90d9114801
# Patch does not apply cleanly to all versions needing patching, just manually
# patch the relevant section of the writer.
if [ "$do_patch" = "1" ]; then
    cd /usr/src/pandoc
    src='\\\\begin{center}\\\\rule{0\.5\\\\linewidth}{\\\\linethickness}\\\\end{center}'
    dst='\\begin{center}\\rule{0.5\\linewidth}{0.5pt}\\end{center}'
    sed "s/$src/$dst/g" < src/Text/Pandoc/Writers/LaTeX.hs > tmp.hs
    mv tmp.hs src/Text/Pandoc/Writers/LaTeX.hs
    # Display patched changes.
    git --no-pager diff --color=always
    # Make sure to exit if no patching was done!
    if git diff --quiet; then
        echo 'NO PATCH PERFORMED BUT PATCH EXPECTED!'
        exit 1
    fi
    cd "$old_pwd"
fi

# /HACK
################################################################################

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
