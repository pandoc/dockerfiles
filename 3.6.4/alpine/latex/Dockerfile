#  _         _____   __  __
# | |    __ |_   _|__\ \/ /
# | |   / _` || |/ _ \\  /
# | |__| (_| || |  __//  \
# |_____\__,_||_|\___/_/\_\
#
FROM pandoc/core:3.6.4-alpine

# NOTE: to maintainers, please keep this listing alphabetical.
RUN apk --no-cache add \
        curl \
        fontconfig \
        freetype \
        gnupg \
        gzip \
        perl \
        tar \
        wget \
        xz

# Installer config
COPY <<EOF /root/texlive.profile
# NOTE: Setting the binary type is done in the Dockerfile! E.g., in Alpine
# `binary_x86_64-linuxmusl 1` is appended to this file.
selected_scheme scheme-basic
TEXDIR         /opt/texlive/texdir
TEXMFLOCAL     /opt/texlive/texmf-local
TEXMFSYSVAR    /opt/texlive/texdir/texmf-var
TEXMFSYSCONFIG /opt/texlive/texdir/texmf-config
TEXMFVAR       ~/.texlive/texmf-var
TEXMFCONFIG    ~/.texlive/texmf-config
TEXMFHOME      ~/texmf
instopt_adjustpath 0
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 0
tlpdbopt_backupdir tlpkg/backups
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 1
tlpdbopt_file_assocs 1
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
tlpdbopt_post_code 1
tlpdbopt_sys_bin /usr/local/bin
tlpdbopt_sys_info /usr/local/share/info
tlpdbopt_sys_man /usr/local/share/man
tlpdbopt_w32_multi_user 1
EOF
# Installer script
COPY common/latex/install-texlive.sh /root/install-texlive.sh

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

# TeXLive mirror URL (leave empty to use the default mirror).
ARG texlive_mirror_url=

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

# Ideally, the image would always install "linuxmusl" binaries. However,
# those are not available for aarch64, so we install binaries that have
# been built against libc and hope that the compatibility layer works
# well enough.
RUN cd /root && \
    ARCH="$(uname -m)" && \
    case "$ARCH" in \
        ('x86_64') \
            TEXLIVE_ARCH="x86_64-linuxmusl"; \
            ;; \
        (*) echo >&2 "error: unsupported architecture '$ARCH'"; \
            exit 1 \
            ;; \
    esac && \
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
    chmod -R o+w /opt/texlive/texdir/texmf-var

WORKDIR /data
