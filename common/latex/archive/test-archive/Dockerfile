ARG base_image="arg required on cmdline"
ARG base_tag="arg required on cmdline"

FROM pandoc/${base_image}:${base_tag}

# Installing a handful of packages from tlmgr should be a sufficient test,
# if the archive url didn't work then tlmgr will fail saying so.
RUN tlmgr install adjustbox \
                  collectbox \
                  fontawesome5 \
                  framed \
                  ly1 \
                  minted \
                  mdframed \
                  mweights \
                  needspace \
                  pagecolor \
                  sourcecodepro \
                  sourcesanspro \
                  titling
