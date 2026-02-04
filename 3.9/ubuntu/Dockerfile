
# Minimal ###############################################################
FROM ubuntu:noble AS minimal
LABEL maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.author="John MacFarlane"
LABEL org.pandoc.version="3.9"

# Set user data directory
ENV XDG_DATA_HOME=/usr/local/share

# Set default working directory
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]

COPY --from=docker.io/pandoc/core:3.9-debian \
  /usr/local/bin/pandoc \
  /usr/local/bin/

# Add pandoc symlinks
RUN ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-lua \
  && ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-server \
# Install runtime dependencies
  && apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
       ca-certificates=\* \
       liblua5.4-0=\* \
       libatomic1=\* \
       libgmp10=\* \
       libpcre3=\* \
       libyaml-0-2=\* \
       zlib1g=\* \
  && rm -rf /var/lib/apt/lists/* \
# Create user data directory
  && mkdir -p "$XDG_DATA_HOME"/pandoc
