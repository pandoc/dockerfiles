#  _____                _
# |_   _|   _ _ __  ___| |_
#   | || | | | '_ \/ __| __|
#   | || |_| | |_) \__ \ |_
#   |_| \__, | .__/|___/\__|
#       |___/|_|

FROM pandoc/core:3.8.2.1-ubuntu

RUN set -eux; \
    apt-get -q --no-allow-insecure-repositories update; \
    apt-get install --assume-yes --no-install-recommends --mark-auto \
        curl dpkg-dev tar; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    TYPST_GITHUB="https://github.com/typst/typst/releases/download/"; \
    TYPST_BUILD="typst-${ARCH}-unknown-linux-musl"; \
    TYPST_VERSION="v0.13.1"; \
    TYPST_URL="$TYPST_GITHUB/$TYPST_VERSION/$TYPST_BUILD.tar.xz"; \
    case "$ARCH" in \
        ('aarch64') \
            TYPST_SHA256='4f5b7ee6e57fb639019ee0f6bffcf940edad228ede6ff5269a9f05a1544ceed4'; \
            ;; \
        ('x86_64') \
            TYPST_SHA256='7d214bfeffc2e585dc422d1a09d2b144969421281e8c7f5d784b65fc69b5673f'; \
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
