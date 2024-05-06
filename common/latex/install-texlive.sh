#!/bin/sh

# NOTE TO MAINTAINERS: this must be updated each time a new texlive is
# released!
default_version=2024
tlversion=${1:-"$default_version"}
installer_archive=install-tl-unx.tar.gz

usage ()
{
    printf 'Install TeXLive\n'
    printf 'Usage: %s [OPTIONS]\n\n' "$0"
    printf 'Options:\n'
    printf '  -t: TeXLive version (default %s)\n' "$default_version"
    printf '  -m: mirror URL\n'
}

if ! args=$(getopt 't:m:' "$@"); then
    usage && exit 1
fi
# The variable is intentionally left unquoted.
# shellcheck disable=SC2086
set -- $args

tlversion=
mirror_url=

while true; do
    case "$1" in
        (-t)
            tlversion="${2}"
            shift 2
            ;;
        (-m)
            mirror_url="${2}"
            shift 2
            ;;
        (--)
            shift
            break
            ;;
        (*)
            printf 'Unknown option: %s\n' "$1"
            usage
            exit 1
            ;;
    esac
done

[ -n "$tlversion" ] || tlversion="$default_version"

if [ -z "$mirror_url" -a "$tlversion" != "$default_version" ]; then
    # Default mirror for historic releases
    mirror_url="ftp://tug.org/historic/"
fi

if [ -z "$mirror_url" ]; then
    # Get the mirror URL from the redirect. Otherwise, if we were to
    # always use the mirror URL, we'd run into problems whenever we get
    # installer and signatures from different mirrors that are not 100%
    # in sync.
    mirror_url=$(wget -4 --quiet --output-document=/dev/null \
                      --server-response \
                      http://mirror.ctan.org/ \
                      2>&1 | \
                      sed -ne 's/.*Location: \(.*\)$/\1/p' | head -n 1)
fi

# Trim trailing slash(es)
mirror_url=$(echo $mirror_url | sed -e 's/\/*$//')

if [ "$tlversion" = "$default_version" ]; then
    installer_url="$mirror_url/systems/texlive/tlnet/"
    repository=
else
    installer_url="$mirror_url/systems/texlive/$tlversion/tlnet-final/"
    repository=$installer_url
fi

# Log the installer and repository url
printf 'installer URL: %s\n' "${installer_url}"
printf 'repository: %s\n' "${repository}"

# Download the install-tl perl script. The archive integrity and signature is
# verified later, so it's ok if we use an insecure connection.
wget -4 --no-verbose --no-check-certificate \
     "$installer_url/$installer_archive" \
     "$installer_url/$installer_archive".sha512 \
     "$installer_url/$installer_archive".sha512.asc \
    || exit 1

## Verifiy installer integrity
# get current signing key
gpg --keyserver keyserver.ubuntu.com \
    --receive-key 0xC78B82D8C79512F79CC0D7C80D5E5D9106BAB6BC || exit 5
gpg --verify "$installer_archive".sha512.asc || exit 5
sha512sum "$installer_archive".sha512 || exit 5

## Proceed with installation
# Extract installer
mkdir -p ./install-tl
tar --strip-components 1 -zvxf "$installer_archive" -C "$PWD/install-tl" \
    || exit 1

# Run the default installation with the specified profile.
./install-tl/install-tl ${repository:+-repository "$repository"} \
                        --profile=/root/texlive.profile

# Cleanup installation artifacts.
rm -rf ./install-tl \
   "$installer_archive" \
   "$installer_archive.sha512" \
   "$installer_archive.sha512.asc"
