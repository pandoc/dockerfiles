ARG base_image="arg required on cmdline"
ARG base_tag="arg required on cmdline"

FROM pandoc/${base_image}:${base_tag}

ARG archive_year="arg required on cmdline"
RUN tlmgr option repository ftp://tug.org/historic/systems/texlive/${archive_year}/tlnet-final
