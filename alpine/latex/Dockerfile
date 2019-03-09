ARG base_tag="edge"
FROM pandoc/core:${base_tag}

# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
# NOTE: to maintainers, please keep this listing alphabetical.
RUN apk --no-cache add \
        freetype \
        fontconfig \
        gnupg \
        gzip \
        librsvg \
        perl \
        tar \
        wget

# DANGER: this will vary for different distributions, particularly the
# `linuxmusl` suffix.  Alpine linux is a musl libc based distribution, for other
# "more common" distributions, you likely want just `-linux` suffix rather than
# `-linuxmusl` -----------------> vvvvvvvvvvvvvvvv
ENV PATH="/opt/texlive/texdir/bin/x86_64-linuxmusl:${PATH}"
WORKDIR /root

COPY latex-common/texlive.profile /root/texlive.profile
COPY latex-common/install-texlive.sh /root/install-texlive.sh
RUN /root/install-texlive.sh

COPY latex-common/install-tex-packages.sh /root/install-tex-packages.sh
RUN /root/install-tex-packages.sh

RUN rm -f /root/texlive.profile \
          /root/install-texlive.sh \
          /root/install-tex-packages.sh

################################################################################
# NOTE: this is only necessary for Alpine latex, right now `tlmgr install biber`
# does not work because the musl c binaries are not available.  This will change
# in the future thanks to @krumeich.  We also cannot `apk add biber` because the
# hosted version is incompatible with the LaTeX we install.  See
# https://github.com/plk/biber/issues/255
RUN \
  wget --quiet https://downloads.sourceforge.net/project/biblatex-biber/biblatex-biber/development/binaries/Linux-musl/biber-linux_x86_64-musl.tar.gz \
  && tar -xf biber-linux_x86_64-musl.tar.gz \
  && mv biber-linux_x86_64-musl /opt/texlive/texdir/bin/x86_64-linuxmusl/biber \
  && rm -f biber-linux_x86_64-musl.tar.gz \
  # biblatex and biber versions are tightly coupled, in the future we will be able
  # to just `tlmgr install biber biblatex` as done in install-tex-packages.sh, but
  # for now we are going to just manually overwrite them.  The idea being that in
  # the future when this all hits public facing archives, we can just delete this
  # block of code entirely without modifying install-tex-packages.sh :)
  && tlmgr uninstall --no-depends biblatex \
  # tlmgr backs up uninstall, no need to keep it around
  && rm -rf /opt/texlive/texdir/tlpkg/backups/* \
  && wget --quiet https://downloads.sourceforge.net/project/biblatex/development/biblatex-3.13.tgz \
  && tar -xf biblatex-3.13.tgz \
  && rm biblatex-3.13.tgz \
  && cd /root/biblatex \
  # Inlined from README, MANUAL installation method.
  # 3. Copy all files and subdirectories in the 'latex' directory to:
  #    <texmflocal>/tex/latex/biblatex/
  && mv latex /opt/texlive/texmf-local/tex/latex/biblatex \
  # 4. Copy all files in the 'bibtex/bst' subdirectory to:
  #    <texmflocal>/bibtex/bst/biblatex/
  && mv bibtex/bst /opt/texlive/texmf-local/bibtex/bst/biblatex \
  # 5. Copy all files in the 'bibtex/bib' subdirectory to:
  #    <texmflocal>/bibtex/bib/biblatex/
  && mv bibtex/bib /opt/texlive/texmf-local/bibtex/bib/biblatex \
  # 6. If you are using bibtex8, copy all files in the 'bibtex/csf'
  #    subdirectory to:
  #    <texmflocal>/bibtex/csf/biblatex/
  # ---> bibtex/csf directory does not exist.
  # 7. The manual and example files in 'doc' subdirectory go to
  #    <texmflocal>/doc/latex/biblatex/
  # --> we skip this to reduce image size
  # 8. Update the file hash tables (also known as the file name database).
  #    On teTeX and TeX Live systems, run texhash as root ('sudo texhash').
  && texhash \
  # Delete remaining components of biblatex extract
  && cd /root \
  && rm -rf biblatex*
################################################################################

WORKDIR /data
