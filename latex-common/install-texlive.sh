#!/bin/sh

################################################################################
# Download / extract the install-tl perl script.                               #
################################################################################
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz || exit 1
mkdir -p ./install-tl
tar --strip-components 1 -zvxf install-tl-unx.tar.gz -C "$PWD/install-tl" || exit 1

################################################################################
# Run the default installation with the specified profile.                     #
################################################################################
./install-tl/install-tl --profile=/root/texlive.profile

################################################################################
# Install pandoc latex pacakges: https://pandoc.org/MANUAL.html#creating-a-pdf #
################################################################################
# NOTE: graphicx, grffile, and longtable appear to be default packages?  tlmgr
#       cannot install them and will error out. That is why they are excluded.
tlmgr install amsfonts     \
              amsmath      \
              lm           \
              lm-math      \
              unicode-math \
              ifxetex      \
              ifluatex     \
              listings     \
              fancyvrb     \
              booktabs     \
              hyperref     \
              xcolor       \
              ulem         \
              geometry     \
              setspace     \
              babel

################################################################################
# Install extra packages for XeTex, LuaTex, and BibLaTex.                      #
################################################################################
tlmgr install xetex       \
              luatex      \
              fontspec    \
              polyglossia \
              xecjk       \
              bidi        \
              mathspec    \
              upquote     \
              microtype   \
              csquotes    \
              lualatex-math

# Make sure all reference backend options are installed
tlmgr install natbib   \
              biblatex \
              bibtex   \
              biber

################################################################################
# Trim down (possibly large amounts of) installed artifacts such as docs.      #
################################################################################
rm -rf ./install-tl                        \
       ./install-tl-unx.tar.gz             \
       /opt/texlive/texdir/texmf-dist/doc  \
       /opt/texlive/texdir/readme-html.dir \
       /opt/texlive/texdir/readme-txt.dir  \
       /opt/texlive/texdir/install-tl*
