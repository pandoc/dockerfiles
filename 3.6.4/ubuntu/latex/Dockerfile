#  _         _____   __  __
# | |    __ |_   _|__\ \/ /
# | |   / _` || |/ _ \\  /
# | |__| (_| || |  __//  \
# |_____\__,_||_|\___/_/\_\
#
FROM pandoc/core:3.6.4-ubuntu

# NOTE: to maintainers, please keep this listing alphabetical.
RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
        fontconfig \
        gnupg \
        gzip \
        libfontconfig1 \
        libfreetype6 \
        perl \
        tar \
        wget \
        xzdec \
  && rm -rf /var/lib/apt/lists/*

# Installer scripts and config
COPY common/latex/texlive.profile    /root/texlive.profile
COPY common/latex/install-texlive.sh /root/install-texlive.sh

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

# TeXLive mirror URL (leave empty to use the default mirror).
ARG texlive_mirror_url=

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

RUN cd /root && \
    TEXLIVE_ARCH="$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')" && \
    mkdir -p ${texlive_bin} && \
    ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default" && \
# Request musl precompiled binary access
    echo "binary_${TEXLIVE_ARCH} 1" >> /root/texlive.profile && \
    ( \
     printf '-t\n%s\n"' "2024"; \
     [ -z "$texlive_mirror_url" ] || printf '-m\n%s\n' "$texlive_mirror_url" \
    ) | xargs /root/install-texlive.sh && \
    tlmgr install \
        amsfonts \
        amsmath \
        babel \
        babel-basque \
        babel-czech \
        babel-danish \
        babel-dutch \
        babel-english \
        babel-finnish \
        babel-french \
        babel-german \
        babel-hungarian \
        babel-italian \
        babel-norsk \
        babel-polish \
        babel-portuges \
        babel-spanish \
        babel-swedish \
        beamer \
        biber \
        biblatex \
        bibtex \
        bidi \
        bidi \
        bookmark \
        booktabs \
        caption \
        cleveref \
        csquotes \
        euler \
        eurosym \
        fancyvrb \
        float \
        fontspec \
        footnotehyper \
        framed \
        geometry \
        graphics \
        hyperref \
        hyphen-basque \
        hyphen-czech \
        hyphen-danish \
        hyphen-dutch \
        hyphen-english \
        hyphen-finnish \
        hyphen-french \
        hyphen-german \
        hyphen-hungarian \
        hyphen-italian \
        hyphen-norwegian \
        hyphen-polish \
        hyphen-portuguese \
        hyphen-spanish \
        hyphen-swedish \
        ifmtarg \
        iftex \
        latexmk \
        listings \
        lm \
        lm-math \
        lua-ul \
        luacode \
        luacolor \
        lualatex-math \
        luatexbase \
        mathspec \
        memoir \
        microtype \
        multirow \
        natbib \
        parskip \
        pgf \
        selnolig \
        setspace \
        soul \
        subfig \
        tools \
        ulem \
        unicode-math \
        upquote \
        xcolor \
        xetex \
        xurl \
    && \
    rm -f /root/texlive.profile \
          /root/install-texlive.sh \
          /root/packages.txt && \
    TERM=dumb luaotfload-tool --update && \
    chmod -R o+w /opt/texlive/texdir/texmf-var && \
    mkdir -p ${texlive_bin} && \
    ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default"

WORKDIR /data
