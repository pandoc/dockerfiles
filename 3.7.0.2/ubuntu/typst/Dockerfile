#  _____                _
# |_   _|   _ _ __  ___| |_
#   | || | | | '_ \/ __| __|
#   | || |_| | |_) \__ \ |_
#   |_| \__, | .__/|___/\__|
#       |___/|_|

FROM pandoc/core:3.7.0.2-ubuntu

RUN set -eux; \
    apt-get -q --no-allow-insecure-repositories update; \
    apt-get install --assume-yes --no-install-recommends --mark-auto \
        curl dpkg-dev tar; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    TYPST_GITHUB="https://github.com/typst/typst/releases/download/"; \
    TYPST_BUILD="typst-${ARCH}-unknown-linux-musl"; \
    TYPST_VERSION="v0.12.0"; \
    TYPST_URL="$TYPST_GITHUB/$TYPST_VERSION/$TYPST_BUILD.tar.xz"; \
    case "$ARCH" in \
        ('aarch64') \
            TYPST_SHA256='e81ae98e6b12db5a36c2276e5a9890da48f7a339b92476dd22daf90de3699e11'; \
            ;; \
        ('x86_64') \
            TYPST_SHA256='605130a770ebd59a4a579673079cb913a13e75985231657a71d6239a57539ec3'; \
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
