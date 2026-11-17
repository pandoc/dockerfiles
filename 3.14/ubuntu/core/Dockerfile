#   ____
#  / ___|___  _ __ ___
# | |   / _ \| '__/ _ \
# | |__| (_) | | |  __/
#  \____\___/|_|  \___|
#
FROM pandoc/minimal:3.14-ubuntu

# Additional packages frequently used during conversions
# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
       xz-utils=5.* \
       librsvg2-bin=2.* \
  && rm -rf /var/lib/apt/lists/*

# Install pandoc-crossref
RUN <<EOF
set -eux

# Install curl
apt-get -q --no-allow-insecure-repositories update
apt-get install --assume-yes --no-install-recommends --mark-auto curl

url_base='https://github.com/lierdakil/pandoc-crossref/releases/download';
case "$(uname -m)" in
    ('x86_64')
        arch="X64"
        crossref_hash=4ba5c4b2e265a72f6f7eff490d7e4f17dbffd0e24be8fad45121b060f91aa8c9
        ;;
    ('aarch64')
        arch="ARM64"
        crossref_hash=0ab52294a4e06b65cb7a0bd8b3d25c12a7ca778807cc3b696cdaffda20148c78
        ;;
    (*)
        echo >&2 "error: unsupported architecture '$(uname -m)'"
        exit 1
        ;;
esac
version="v0.3.26b"
filename="pandoc-crossref-Linux-${arch}.tar.xz"
curl --proto '=https' --tlsv1.3 -sSfL -o /tmp/pandoc-crossref.tar.xz \
    "${url_base}/${version}/pandoc-crossref-linux-${arch}.tar.xz"
echo "$crossref_hash /tmp/pandoc-crossref.tar.xz" | sha256sum -c
tar -xf /tmp/pandoc-crossref.tar.xz -C /usr/local/bin pandoc-crossref
# Remove archive
rm /tmp/pandoc-crossref.tar.xz

### verstat ###
curl --proto '=https' --tlsv1.3 -sSfL -o /tmp/verstat.tar.xz \
    "https://codeberg.org/pandoc/verstat/archive/main.tar.gz"
tar -xf /tmp/verstat.tar.xz -C /tmp
mv /tmp/verstat/verstat.lua /usr/local/bin/verstat
# Install the package database in the right location
verstat update /tmp/verstat/packages.json
# Remove dir and archive
rm -rf /tmp/verstat.tar.xz /tmp/verstat

# Curl is no longer needed
apt-get autoremove --purge --assume-yes; \
rm -rf /var/lib/apt/lists/*;
EOF
