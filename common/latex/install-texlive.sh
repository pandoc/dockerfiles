#!/bin/sh

# Download / extract the install-tl perl script.
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz || exit 1
mkdir -p ./install-tl
tar --strip-components 1 -zvxf install-tl-unx.tar.gz -C "$PWD/install-tl" || exit 1

# Run the default installation with the specified profile.
./install-tl/install-tl --profile=/root/texlive.profile

# Cleanup installation artifacts.
rm -rf ./install-tl ./install-tl-unx.tar.gz
