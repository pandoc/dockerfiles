#  _____                _
# |_   _|   _ _ __  ___| |_
#   | || | | | '_ \/ __| __|
#   | || |_| | |_) \__ \ |_
#   |_| \__, | .__/|___/\__|
#       |___/|_|

FROM pandoc/core:3.11-debian

RUN set -eux; \
    apt-get -q --no-allow-insecure-repositories update; \
    apt-get install --assume-yes --no-install-recommends --mark-auto \
        curl dpkg-dev tar; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    TYPST_GITHUB="https://github.com/typst/typst/releases/download/"; \
    TYPST_BUILD="typst-${ARCH}-unknown-linux-musl"; \
    TYPST_VERSION="v0.15.1"; \
    TYPST_URL="$TYPST_GITHUB/$TYPST_VERSION/$TYPST_BUILD.tar.xz"; \
    case "$ARCH" in \
        ('aarch64') \
            TYPST_SHA256='5aa8d74a3d906e60ea12a66ac2f37f8eef1b14cbad7182a745e393a10c23dcee'; \
            ;; \
        ('x86_64') \
            TYPST_SHA256='a6d077d0a95eed5a2eba715b2dae06be954f624ccbf85758a03f389ded33118c'; \
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
