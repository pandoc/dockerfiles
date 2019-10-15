#!/bin/sh

# Enforce that define_cabal_project_and_gather_sources.sh has been run and in
# expected working directory.
if ! [ "$PWD" = "/usr/src" ]; then
    echo "PWD should be '/usr/src' but was '$PWD'" >&2
    exit 1
fi
if ! [ -f cabal.project ]; then
    echo "File cabal.project does not exist but should have been generated." >&2
    exit 1
fi

# Need cabal v3 or later, docker file should have already done cabal update /
# cabal install cabal-install.  The --installdir is required in v3+, but not
# available in prior versions.  Extract major version number and make sure it
# is at least three.
cabal_version="$(cabal --numeric-version)"
cabal_major="$(printf "%c" "$cabal_version")"
if [ "$cabal_major" -lt 3 ]; then
    echo "Cabal version '$cabal_version' insufficient: 3.0 or later needed." >&2
    exit 1
fi

set -eux

cabal --version
ghc --version
cabal update
cabal install pandoc pandoc-citeproc pandoc-crossref \
              --installdir=/root/.cabal/bin \
              --install-method=copy \
              --flag embed_data_files \
              --flag bibutils \
              --constraint 'hslua +system-lua +pkg-config'
