#!/bin/sh
################################################################################
# Install pandoc latex packages: https://pandoc.org/MANUAL.html#creating-a-pdf #
################################################################################
# NOTE: search left hand side on CTAN to see for yourself:
#       graphicx  -> graphics
#       grffile   -> oberdiek
#       longtable -> tools

# Included in `scheme-basic`, but let's be explicit about this:
tlmgr install \
      amsfonts \
      amsmath \
      geometry \
      graphics \
      hyperref \
      iftex \
      lm \
      luatex \
      oberdiek \
      pdftexcmds \
      tools \
    || exit 1
tlmgr install \
      # Other basic packages
      booktabs \
      fancyvrb \
      listings \
      lm-math \
      logreq \
      memoir \
      parskip \
      pgf \        # for TikZ
      setspace \
      ulem \
      unicode-math \
      xcolor \
    || exit 1

# Needed for when --highlight-style used with something other than pygments.
tlmgr install framed || exit 1

################################################################################
# Install extra packages for XeTex, LuaTex, and BibLaTex.                      #
################################################################################
tlmgr install \
      fontspec \
      lualatex-math \
      mathspec \
      microtype \
      polyglossia \
      selnolig \
      upquote \
      xetex \
    || exit 1

# I18n and languages; the choice of selected languages is historic,
# those were the ones installed by texlive by default for a long time.
tlmgr install \
      bidi \
      csquotes \
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
    || exit 1

# Make sure all reference backend options are installed
tlmgr install biber \
              biblatex \
              bibtex \
              natbib \
              || exit 1

# These packages were identified by the tests, they are likely dependencies of
# dependencies that are not encoded well.
tlmgr install footnotehyper \
              xurl \
              || exit 1

################################################################################
# Trim down (possibly large amounts of) installed artifacts such as docs.      #
################################################################################
rm -rf /opt/texlive/texdir/texmf-dist/doc  \
       /opt/texlive/texdir/readme-html.dir \
       /opt/texlive/texdir/readme-txt.dir  \
       /opt/texlive/texdir/install-tl*
