#   ____
#  / ___|___  _ __ ___
# | |   / _ \| '__/ _ \
# | |__| (_) | | |  __/
#  \____\___/|_|  \___|
#
FROM pandoc/minimal:edge-alpine

# Additional packages frequently used during conversions
# hadolint ignore=DL3018
RUN apk --no-cache add rsvg-convert

# Install pandoc-crossref
RUN <<EOF
set -eux
apk --no-cache add curl
url_base='https://github.com/lierdakil/pandoc-crossref/releases/download';
case "$(uname -m)" in
    ('x86_64')
        arch="X64"
        crossref_hash=7f8b7c5c91233db2dcb1145fa580a9ee8343695589bdb0ece8661490bc12a644
        ;;
    ('aarch64')
        arch="ARM64"
        crossref_hash=a5e06fe32cce7f8bccc182ff9d88cfe0c0fc5ff2ac784422388157714ccaaff7
        ;;
    (*)
        echo >&2 "error: unsupported architecture '$(uname -m)'"
        exit 1
        ;;
esac
version="v0.3.25a"
filename="pandoc-crossref-Linux-${arch}.tar.xz"
curl --proto '=https' --tlsv1.3 -sSfL -o /tmp/pandoc-crossref.tar.xz \
    "${url_base}/${version}/pandoc-crossref-linux-${arch}.tar.xz"
echo "$crossref_hash /tmp/pandoc-crossref.tar.xz" | sha256sum -c
tar -xf /tmp/pandoc-crossref.tar.xz -C /usr/local/bin pandoc-crossref
# Remove archive
rm /tmp/pandoc-crossref.tar.xz
# Curl is no longer needed
apk del curl
EOF

# Install verstat
RUN <<EOF
set -eux
apk --no-cache add curl
curl --proto '=https' --tlsv1.3 -sSfL -o /tmp/verstat.tar.xz \
    "https://codeberg.org/pandoc/verstat/archive/main.tar.gz"
tar -xf /tmp/verstat.tar.xz -C /tmp
mv /tmp/verstat/verstat.lua /usr/local/bin/verstat
verstat update /tmp/verstat/packages.json
# Remove dir and archive
rm -rf /tmp/verstat.tar.xz /tmp/verstat
# Curl is no longer needed
apk del curl
EOF
