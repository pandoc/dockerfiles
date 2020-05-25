ARG base_tag="edge"
FROM pandoc/ubuntu-crossref:${base_tag}

# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
# NOTE: to maintainers, please keep this listing alphabetical.
RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
        libfreetype6 \
        libfontconfig1 \
        fontconfig \
        gnupg \
        gzip \
        librsvg2-bin \
        perl \
        tar \
        wget \
        xzdec \
        && rm -rf /var/lib/apt/lists/*

# DANGER: this will vary for different distributions,
# particularly the `linux` suffix. Ubuntu linux is a glibc based
# distribution, adjust depending on the distro.
# `-linux` ---------------------------> vvvvvv
ENV PATH="/opt/texlive/texdir/bin/x86_64-linux:${PATH}"
WORKDIR /root

COPY common/latex/texlive.profile /root/texlive.profile
COPY common/latex/install-texlive.sh /root/install-texlive.sh
# Don't include linuxmusl, ubuntu is a glibc distro
RUN sed -i'' -e 's/^\(binary_x86_64-linuxmusl\) 1/\1 0/' \
        /root/texlive.profile

RUN /root/install-texlive.sh

COPY common/latex/install-tex-packages.sh /root/install-tex-packages.sh
RUN /root/install-tex-packages.sh

RUN rm -f /root/texlive.profile \
          /root/install-texlive.sh \
          /root/install-tex-packages.sh

WORKDIR /data
