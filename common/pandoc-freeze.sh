#!/bin/sh
## Helper script to create cabal freeze files. These files pin all
## Haskell dependencies to specific version, improving our ability
## to do reproducible builds.
##
## Expected inputs:
##   1. pandoc version, e.g. 2.9.2.1
##   2. owner of the new freeze file, e.g. `user:group` or
##      `1000:1000`.
##
## Files created by this script should be put under version control.
set -e

usage ()
{
    printf "Generate a cabal freeze file for a given pandoc version\n\n"
    printf "Usage: %s PANDOC_VERSION FILE_OWNER\n\n" "$0"
    printf "Parameters:\n"
    printf "  PANDOC_VERSION: targeted pandoc version, e.g. 2.9.2.1\n"
    printf "  FILE_OWNER: owner of the new freeze file, e.g. 1000:1000\n\n"
    printf "  TARGET_FILE: target file name\n"
    printf "NOTE: This script is designed to run in a Docker container. The\n"
    printf "freeze file will be created in the '/app' directory.\n"
}
# Bail unless the script is called with exactly two parameters
[ $# -eq 3 ] || ( usage 1>&2; exit 1 )

pandoc_version="$1"
file_owner="$2"
target_file="$3"

tmpdir=$(mktemp -p /tmp -d pandoc-freeze.XXXXXX)
cd "${tmpdir}"

#
# Constraints
#
pandoc_constraints="\
 +embed_data_files\
 -trypandoc"
lua_constraints="\
 +system-lua\
 +pkg-config\
 +hardcode-reg-keys"

uses_hslua_2 ()
{
    major=$(printf "%s" "$pandoc_version" | \
                awk -F. '{ printf("%03d%03d\n", $1,$2); }')
    test "${major}" -ge "002015"
    return $?
}

if uses_hslua_2; then
    lua_package=lua
else
    lua_package=hslua
fi

print_constraints_only ()
{
    printf "constraints: %s %s,\n" "${lua_package}" "${lua_constraints}"
    printf "             pandoc %s,\n" "${pandoc_constraints}"
}

# Just write the constraints to the target file when targeting master
if [ "$pandoc_version" = "master" ]; then
    printf "Writing freeze file for builds from master...\n"
    print_constraints_only > "${target_file}"
    printf "Changing freeze file owner to %s\n" "${file_owner}"
    chown "${file_owner}" "${target_file}"
    exit 0
fi

# Download latest cabal database
cabal update

# get pandoc source code from Hackage
cabal get pandoc-"${pandoc_version}"

sourcedir=$PWD/pandoc-"${pandoc_version}"
printf "Switching directory to %s\n" "${sourcedir}"
cd "${sourcedir}"

# Add pandoc-crossref to the project
if [ -z "${WITHOUT_CROSSREF}" ]; then
    printf "Writing cabal.project.local\n"
    printf "\nextra-packages: pandoc-crossref\n" > cabal.project.local
fi

# create freeze file with all desired constraints
printf "Creating freeze file...\n"
cabal new-freeze \
      --constraint="pandoc ${pandoc_constraints}" \
      --constraint="${lua_package} ${lua_constraints}"

printf "Copying freeze file to %s\n" "${target_file}"
target_dir="$(dirname "${target_file}")"
if [ ! -d "${target_dir}" ]; then
    mkdir -p "${target_dir}"
    chmod 775 "${target_dir}"
    chown "${file_owner}" "${target_dir}"
fi
cp cabal.project.freeze "${target_file}"
printf "Changing freeze file owner to %s\n" "${file_owner}"
chmod 664 "${target_file}"
chown "${file_owner}" "${target_file}"

printf "DONE\n"
