ARG base_image="arg required on cmdline"
ARG base_tag="arg required on cmdline"

FROM pandoc/${base_image}:${base_tag}

ARG archive_year="arg required on cmdline"
RUN tlmgr option repository ftp://tug.org/historic/systems/texlive/${archive_year}/tlnet-final

# Create a synthetic "alias" for tlmgr that just forwards.
# Cannot create a shell alias (non-interactive executions).
RUN tlmgr --verify-repo=none update --self && \
    tlmgr_orig="$(which tlmgr)" && \
    mv "$tlmgr_orig" "$tlmgr_orig-actual" && \
    echo '#!/bin/sh' > "$tlmgr_orig" && \
    echo "$tlmgr_orig-actual"' --verify-repo=none $@' >> "$tlmgr_orig" && \
    chmod a+x "$tlmgr_orig"
