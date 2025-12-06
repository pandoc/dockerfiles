#   ____
#  / ___|___  _ __ ___
# | |   / _ \| '__/ _ \
# | |__| (_) | | |  __/
#  \____\___/|_|  \___|
#
FROM pandoc/minimal:3.8.3-alpine

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
        crossref_hash=a521900745f7c1621b4104119f92dd4a9b4cc527f50157ef544ae1cb8435f9c1
        ;;
    ('aarch64')
        arch="ARM64"
        crossref_hash=aaaeae858b73a4150cc91581b07e08fb6e383f476a04fd024bb03ef323b32c3e
        ;;
    (*)
        echo >&2 "error: unsupported architecture '$(uname -m)'"
        exit 1
        ;;
esac
version="v0.3.22b"
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
