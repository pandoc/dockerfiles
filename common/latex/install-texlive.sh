#!/bin/sh

# NOTE TO MAINTAINERS: this must be updated each time a new texlive is
# released!
default_version=2021
tlversion=${1:-"$default_version"}
installer_archive=install-tl-unx.tar.gz

# Do normal install for the default version.
if [ "$tlversion" = "$default_version" ]; then
    installer_url="http://mirror.ctan.org/systems/texlive/tlnet"
    repository=
else
    installer_url="\
ftp://tug.org/historic/systems/texlive/$tlversion/tlnet-final"
    repository="\
ftp://tug.org/historic/systems/texlive/$tlversion/tlnet-final"
fi

# Download the install-tl perl script.
wget "$installer_url/$installer_archive" \
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
