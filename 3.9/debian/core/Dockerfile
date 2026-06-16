#   ____
#  / ___|___  _ __ ___
# | |   / _ \| '__/ _ \
# | |__| (_) | | |  __/
#  \____\___/|_|  \___|
#
FROM pandoc/minimal:3.9-debian

# Additional packages frequently used during conversions
# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
       librsvg2-bin=2.* \
  && rm -rf /var/lib/apt/lists/*

# Install pandoc-crossref
RUN <<EOF
set -eux

# Install curl
apt-get -q --no-allow-insecure-repositories update
apt-get install --assume-yes --no-install-recommends --mark-auto curl xz-utils

url_base='https://github.com/lierdakil/pandoc-crossref/releases/download';
case "$(uname -m)" in
    ('x86_64')
        arch="X64"
        crossref_hash=fa77e4e271547a97f0e29fd305b6674958a540d79f2a14a3b0ce9d6a6dc9de84
        ;;
    ('aarch64')
        arch="ARM64"
        crossref_hash=f0898fd525327a65d42dcd027cff046626dd0c7e8fa529c8e961b3bec99a0c10
        ;;
    (*)
        echo >&2 "error: unsupported architecture '$(uname -m)'"
        exit 1
        ;;
esac
version="v0.3.23a"
filename="pandoc-crossref-Linux-${arch}.tar.xz"
curl --proto '=https' --tlsv1.3 -sSfL -o /tmp/pandoc-crossref.tar.xz \
    "${url_base}/${version}/pandoc-crossref-linux-${arch}.tar.xz"
echo "$crossref_hash /tmp/pandoc-crossref.tar.xz" | sha256sum -c
tar -xf /tmp/pandoc-crossref.tar.xz -C /usr/local/bin pandoc-crossref
# Remove archive
rm /tmp/pandoc-crossref.tar.xz
# Curl is no longer needed
apt-get autoremove --purge --assume-yes; \
rm -rf /var/lib/apt/lists/*;
EOF
