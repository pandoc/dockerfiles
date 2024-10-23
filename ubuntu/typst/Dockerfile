#  _____                _
# |_   _|   _ _ __  ___| |_
#   | || | | | '_ \/ __| __|
#   | || |_| | |_) \__ \ |_
#   |_| \__, | .__/|___/\__|
#       |___/|_|

ARG pandoc_version=edge
FROM pandoc/core:${pandoc_version}-ubuntu

RUN set -eux; \
    apt-get -q --no-allow-insecure-repositories update; \
    apt-get install --assume-yes --no-install-recommends --mark-auto \
        curl dpkg-dev tar; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    TYPST_GITHUB="https://github.com/typst/typst/releases/download/"; \
    TYPST_VERSION="v0.11.1"; \
    TYPST_BUILD="typst-${ARCH}-unknown-linux-musl"; \
    TYPST_URL="$TYPST_GITHUB/$TYPST_VERSION/$TYPST_BUILD.tar.xz"; \
    case "$ARCH" in \
        ('aarch64') \
            TYPST_SHA256='7f14f7fb37b26febffd13e683f90cdacddfde420d5fdc7f809228a78545c4b26'; \
            ;; \
        ('x86_64') \
            TYPST_SHA256='bb637d1d65634b2ee4b4e101d0b2d541bf3f1e03ac5f51f9619941e48dd28bd0'; \
            ;; \
        (*) echo >&2 "error: unsupported architecture '$ARCH'"; \
            exit 1 \
            ;; \
    esac; \
    curl -sSL "$TYPST_URL" -o typst.tar.xz; \
    echo "$TYPST_SHA256 typst.tar.xz" | sha256sum --strict --check; \
    tar -xf typst.tar.xz \
        -C /usr/local/bin \
        --strip-components=1 \
        "$TYPST_BUILD/typst"; \
    apt-get autoremove --purge --assume-yes; \
    rm typst.tar.xz; \
    rm -rf /var/lib/apt/lists/*;
