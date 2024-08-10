#!/bin/sh
## Helper script to create cabal freeze files. These files pin all
## Haskell dependencies to specific version, improving our ability
## to do reproducible builds.
##
## Files created by this script should be put under version control.
set -e

usage ()
{
    printf "Generate a cabal freeze file for a given pandoc version\n\n"
    printf 'Usage: %s %s\n\n' \
           "$0" \
           '[-v] [-c pandoc_commit] [-s stack] [-u user] [-o outfile]'
    printf 'Parameters:\n'
    printf '  -v: increase verbosity\n'
    printf '  -c pandoc_commit: targeted pandoc commit, e.g. 2.9.2.1\n'
    printf '  -s stack: the stack for which the freeze file is built\n'
    printf '  -u user: owner of the new freeze file, e.g. 1000:1000\n'
    printf '  -o outfile: target file name\n\n'
    printf 'NOTE: This script is designed to run in a Docker container.\n'
}

if ! args=$(getopt 's:c:o:u:v' "$@"); then
    usage && exit 1
fi
# The variable is intentionally left unquoted.
# shellcheck disable=SC2086
set -- $args

stack=unknown
pandoc_commit=main
user=$(id -u):$(id -g)
outfile=cabal.project.freeze
verbosity=0

while true; do
    case "$1" in
        (-c)
            pandoc_commit="${2}";
            shift 2
            ;;
        (-o)
            outfile="${2}";
            shift 2
            ;;
        (-s)
            stack="${2}"
            shift 2
            ;;
        (-u)
            user="${2}"
            shift 2
            ;;
        (-v)
            verbosity=$((verbosity + 1));
            shift 1
            ;;
        (--) shift; break;;
        (*) usage; exit 1;;
    esac
done

if [ "$verbosity" -gt 0 ]; then
    printf 'stack: %s\n' "${stack}"
    printf 'pandoc_commit: %s\n' "${pandoc_commit}"
    printf 'user: %s\n' "${user}"
    printf 'outfile: %s\n' "${outfile}"
fi

tmpdir=$(mktemp -p /tmp -d pandoc-freeze.XXXXXX)
cd "${tmpdir}"

#
# Constraints
#
if [ "${stack}" = "static" ]; then
    lua_constraints=" -system-lua -pkg-config +hardcode-reg-keys -export-dynamic"
    lpeg_constraints=" -rely-on-shared-lpeg-library"
else
    lua_constraints=" +system-lua +pkg-config +hardcode-reg-keys -export-dynamic"
    lpeg_constraints=" -rely-on-shared-lpeg-library"
fi
aeson_pretty_constraints=" +lib-only"
pandoc_constraints=" +embed_data_files"
pandoc_cli_constraints=" +lua -nightly +server"

print_constraints_only ()
{
    printf "constraints: %s %s,\n" "lua" "${lua_constraints}"
    printf "             lpeg %s,\n" "${lpeg_constraints}"
    printf '             aeson-pretty %s,\n' "${aeson_pretty_constraints}"
    printf "             pandoc %s\n" "${pandoc_constraints}"
    printf "             pandoc-cli %s\n" "${pandoc_cli_constraints}"
}

# Just write the constraints to the target file when targeting main
if [ "$pandoc_commit" = "main" ]; then
    printf "Writing freeze file for builds from main...\n"
    print_constraints_only > "${outfile}"
    printf "Changing freeze file owner to %s\n" "${user}"
    chown "${user}" "${outfile}"
    exit 0
fi

pandoc_cli_version=$pandoc_commit
minor=$(printf "%s" "$pandoc_commit" | \
            awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }')
if test "${minor}" -le "003001010"; then
    # pandoc versions before 3.1.11 used pandoc-cli-0.1
   pandoc_cli_version=0.1
fi

# Download latest cabal database
cabal update

# get pandoc source code from Hackage
cabal get pandoc-cli-${pandoc_cli_version}

sourcedir=$PWD/pandoc-cli-${pandoc_cli_version}
printf "Switching directory to %s\n" "${sourcedir}"
cd "${sourcedir}"

# Add pandoc-crossref to the project
if [ -z "${WITHOUT_CROSSREF}" ]; then
    printf "Writing cabal.project.local\n"
    printf "\nextra-packages: pandoc-crossref\n" > cabal.project.local
fi

# create freeze file with all desired constraints
printf "Creating freeze file...\n"
cabal v2-freeze \
      --disable-tests \
      --constraint="pandoc == ${pandoc_commit}" \
      --constraint="pandoc ${pandoc_constraints}" \
      --constraint="pandoc-cli ${pandoc_cli_constraints}" \
      --constraint="lpeg ${lpeg_constraints}" \
      --constraint="aeson-pretty ${aeson_pretty_constraints}" \
      --constraint="lua ${lua_constraints}" \
      --allow-newer='pandoc'

printf "Copying freeze file to %s\n" "${outfile}"
target_dir="$(dirname "${outfile}")"
if [ ! -d "${target_dir}" ]; then
    mkdir -p "${target_dir}"
    chmod 775 "${target_dir}"
    chown "${user}" "${target_dir}"
fi
cp cabal.project.freeze "${outfile}"
printf "Changing freeze file owner to %s\n" "${user}"
chmod 664 "${outfile}"
chown "${user}" "${outfile}"

printf "DONE\n"
