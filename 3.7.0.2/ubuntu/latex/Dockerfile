#  _         _____   __  __
# | |    __ |_   _|__\ \/ /
# | |   / _` || |/ _ \\  /
# | |__| (_| || |  __//  \
# |_____\__,_||_|\___/_/\_\
#
FROM pandoc/core:3.7.0.2-ubuntu

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
COPY common/latex/install-texlive.sh /root/install-texlive.sh
# Installer config
COPY <<EOF /root/texlive.profile
# NOTE: Setting the binary type is done shortly before the installation,
# because we need to know the architecture on which this is running.
# E.g., for amd64 on Alpine, `binary_x86_64-linuxmusl 1` is appended to
# this file.
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

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

# TeXLive mirror URL (leave empty to use the default mirror).
ARG texlive_mirror_url="ftp://tug.org/historic/"

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

RUN set -eux; \
# Setup and configure the installer
    cd /root; \
RUN <<EOF
set -eux
cd /root
TEXLIVE_ARCH="$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')"; \
mkdir -p ${texlive_bin}
ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default"
# Request musl precompiled binary access
echo "binary_${TEXLIVE_ARCH} 1" >> /root/texlive.profile

# Install TeXLive
mirror_url=""

if [ -z "${mirror_url}" ]; then
    # Get the mirror URL from the redirect. Otherwise, if we were to
    # always use the mirror URL, we'd run into problems whenever we get
    # installer and signatures from different mirrors that are not 100%
    # in sync.
    mirror_url=$(wget -4 --quiet --output-document=/dev/null \
                      --server-response \
                      http://mirror.ctan.org/ \
                      2>&1 | \
                      sed -ne 's/.*Location: \(.*\)$/\1/p' | head -n 1)
fi

# Trim trailing slash(es)
mirror_url=$(echo "$mirror_url" | sed -e 's/\/*$//')

installer_url="${mirror_url}/systems/texlive/2025/tlnet-final"

# Download the install-tl perl script. The archive integrity and signature is
# verified later, so it's ok if we use an insecure connection.
wget -4 --no-verbose --no-check-certificate \
    "$installer_url/install-tl-unx.tar.gz" \
    "$installer_url/install-tl-unx.tar.gz".sha512 \
    "$installer_url/install-tl-unx.tar.gz".sha512.asc \

## Verifiy installer integrity
# get current signing key
gpg --keyserver keyserver.ubuntu.com \
    --receive-key 0xC78B82D8C79512F79CC0D7C80D5E5D9106BAB6BC || exit 5
gpg --verify install-tl-unx.tar.gz.sha512.asc || exit 5
sha512sum install-tl-unx.tar.gz.sha512 || exit 5

## Proceed with installation
# Extract installer
mkdir -p ./install-tl
tar --strip-components 1 -zvxf install-tl-unx.tar.gz -C "$PWD/install-tl"

# Run the default installation with the specified profile.
./install-tl/install-tl \
    -repository "${installer_url}" \
    --profile=/root/texlive.profile

# Cleanup installation artifacts.
rm -rf \
    ./install-tl \
    install-tl-unx.tar.gz \
    install-tl-unx.tar.gz.sha512 \
    install-tl-unx.tar.gz.sha512.asc

# Install packages required by pandoc
tlmgr install \
    --verify-repo=all \
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
    xurl
# Reset to the default CTAN mirror, unless a specific mirror had been
# requested.
if [ -z "${texlive_mirror_url}" ]; then
    tlmgr option repository ctan
fi

rm -f /root/texlive.profile

# Update fonts
TERM=dumb luaotfload-tool --update && \
chmod -R o+w /opt/texlive/texdir/texmf-var
EOF

WORKDIR /data
