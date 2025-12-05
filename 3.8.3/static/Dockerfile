# Builder
FROM alpine:3.23.0 AS builder-base

RUN apk --no-cache add \
        alpine-sdk \
        bash \
        ca-certificates \
        cabal \
        fakeroot \
        ghc \
        git \
        gmp-dev \
        gmp-static \
        libffi-dev \
        zlib-dev \
        zlib-static

# Setup and configure cabal
ENV CABAL_CONFIG=/root/.config/cabal/config

RUN cabal user-config init \
  && cabal update

# Builder ###############################################################
FROM builder-base AS builder
RUN git clone --branch=3.8.3 --depth=1 --quiet \
  https://github.com/jgm/pandoc /usr/src/pandoc

# Install Haskell dependencies
WORKDIR /usr/src/pandoc
RUN cabal build \
        --jobs \
        --disable-tests \
        --disable-bench \
        --enable-split-sections \
        --enable-executable-static \
        --enable-executable-stripping \
        --upgrade-dependencies \
        --allow-newer='lib:pandoc' \
        --ghc-options='-O1 -optc-Os -optl=-pthread -fPIC -j' \
        --ghc-options='+RTS -M4G -A128m -n2m -RTS' \
        --constraint='any.Cabal ==3.10.3.0' \
        --constraint='any.Cabal-syntax ==3.10.3.0' \
        --constraint='any.Glob ==0.10.2' \
        --constraint='any.HUnit ==1.6.2.0' \
        --constraint='any.JuicyPixels ==3.3.9' \
        --constraint='JuicyPixels -mmap' \
        --constraint='any.OneTuple ==0.4.2' \
        --constraint='any.Only ==0.1' \
        --constraint='any.QuickCheck ==2.16.0.0' \
        --constraint='QuickCheck -old-random +templatehaskell' \
        --constraint='any.StateVar ==1.2.2' \
        --constraint='any.aeson ==2.2.3.0' \
        --constraint='aeson +ordered-keymap' \
        --constraint='any.aeson-pretty ==0.8.10' \
        --constraint='aeson-pretty +lib-only' \
        --constraint='any.alex ==3.5.4.0' \
        --constraint='any.ansi-terminal ==1.1.3' \
        --constraint='ansi-terminal -example' \
        --constraint='any.ansi-terminal-types ==1.1.3' \
        --constraint='any.appar ==0.1.8' \
        --constraint='any.array ==0.5.6.0' \
        --constraint='any.asciidoc ==0.1' \
        --constraint='any.asn1-encoding ==0.9.6' \
        --constraint='any.asn1-parse ==0.9.5' \
        --constraint='any.asn1-types ==0.3.4' \
        --constraint='any.assoc ==1.1.1' \
        --constraint='assoc -tagged' \
        --constraint='any.async ==2.2.5' \
        --constraint='async -bench' \
        --constraint='any.attoparsec ==0.14.4' \
        --constraint='attoparsec -developer' \
        --constraint='any.auto-update ==0.2.6' \
        --constraint='any.base ==4.19.1.0' \
        --constraint='any.base-compat ==0.14.1' \
        --constraint='any.base-orphans ==0.9.3' \
        --constraint='any.base-unicode-symbols ==0.2.4.2' \
        --constraint='base-unicode-symbols +base-4-8 -old-base' \
        --constraint='any.base16-bytestring ==1.0.2.0' \
        --constraint='any.base64-bytestring ==1.2.1.0' \
        --constraint='any.basement ==0.0.16' \
        --constraint='any.bifunctors ==5.6.2' \
        --constraint='bifunctors +tagged' \
        --constraint='any.binary ==0.8.9.1' \
        --constraint='any.bitvec ==1.1.5.0' \
        --constraint='bitvec +simd' \
        --constraint='any.blaze-builder ==0.4.4.1' \
        --constraint='any.blaze-html ==0.9.2.0' \
        --constraint='any.blaze-markup ==0.8.3.0' \
        --constraint='any.boring ==0.2.2' \
        --constraint='boring +tagged' \
        --constraint='any.bsb-http-chunked ==0.0.0.4' \
        --constraint='any.byteorder ==1.0.4' \
        --constraint='any.bytestring ==0.12.1.0' \
        --constraint='any.cabal-doctest ==1.0.12' \
        --constraint='any.call-stack ==0.4.0' \
        --constraint='any.case-insensitive ==1.2.1.0' \
        --constraint='any.cassava ==0.5.4.1' \
        --constraint='any.cborg ==0.2.10.0' \
        --constraint='cborg +optimize-gmp' \
        --constraint='any.cereal ==0.5.8.3' \
        --constraint='cereal -bytestring-builder' \
        --constraint='any.character-ps ==0.1' \
        --constraint='any.citeproc ==0.12' \
        --constraint='citeproc -executable -icu' \
        --constraint='any.colour ==2.3.6' \
        --constraint='any.commonmark ==0.2.6.1' \
        --constraint='any.commonmark-extensions ==0.2.6' \
        --constraint='any.commonmark-pandoc ==0.2.3' \
        --constraint='any.comonad ==5.0.9' \
        --constraint='comonad +containers +distributive +indexed-traversable' \
        --constraint='any.conduit ==1.3.6.1' \
        --constraint='any.conduit-extra ==1.3.8' \
        --constraint='any.constraints ==0.14.2' \
        --constraint='any.containers ==0.6.8' \
        --constraint='any.contravariant ==1.5.5' \
        --constraint='contravariant +semigroups +statevar +tagged' \
        --constraint='any.cookie ==0.5.1' \
        --constraint='any.crypton ==1.0.4' \
        --constraint='crypton -check_alignment +integer-gmp -old_toolchain_inliner +support_aesni +support_deepseq +support_pclmuldq +support_rdrand -support_sse +use_target_attributes' \
        --constraint='any.crypton-connection ==0.4.5' \
        --constraint='any.crypton-socks ==0.6.2' \
        --constraint='crypton-socks -example +network-3-0-0-0' \
        --constraint='any.crypton-x509 ==1.7.7' \
        --constraint='any.crypton-x509-store ==1.6.12' \
        --constraint='any.crypton-x509-system ==1.6.7' \
        --constraint='any.crypton-x509-validation ==1.6.14' \
        --constraint='any.data-default ==0.8.0.1' \
        --constraint='any.data-default-class ==0.2.0.0' \
        --constraint='any.data-fix ==0.3.4' \
        --constraint='any.dec ==0.0.6' \
        --constraint='any.deepseq ==1.5.0.0' \
        --constraint='any.digest ==0.0.2.1' \
        --constraint='digest -have_arm64_crc32c -have_builtin_prefetch -have_mm_prefetch -have_sse42 -have_strong_getauxval -have_weak_getauxval +pkg-config' \
        --constraint='any.directory ==1.3.9.0' \
        --constraint='directory +os-string' \
        --constraint='any.distributive ==0.6.2.1' \
        --constraint='distributive +semigroups +tagged' \
        --constraint='any.djot ==0.1.2.4' \
        --constraint='any.dlist ==1.0' \
        --constraint='dlist -werror' \
        --constraint='any.doclayout ==0.5.0.1' \
        --constraint='any.doctemplates ==0.11.0.1' \
        --constraint='any.easy-file ==0.2.5' \
        --constraint='any.ech-config ==0.0.1' \
        --constraint='ech-config -devel' \
        --constraint='any.emojis ==0.1.4.1' \
        --constraint='any.exceptions ==0.10.11' \
        --constraint='any.fast-logger ==3.2.6' \
        --constraint='any.file-embed ==0.0.16.0' \
        --constraint='any.file-io ==0.1.5' \
        --constraint='file-io +os-string' \
        --constraint='any.filepath ==1.5.4.0' \
        --constraint='filepath -cpphs' \
        --constraint='any.generically ==0.1.1' \
        --constraint='any.generics-sop ==0.5.1.4' \
        --constraint='any.ghc-bignum ==1.3' \
        --constraint='any.ghc-boot-th ==9.8.2' \
        --constraint='any.ghc-prim ==0.11.0' \
        --constraint='any.gitrev ==1.3.1' \
        --constraint='any.gridtables ==0.1.1.0' \
        --constraint='any.haddock-library ==1.11.0' \
        --constraint='any.half ==0.3.3' \
        --constraint='any.happy ==2.1.7' \
        --constraint='any.happy-lib ==2.1.7' \
        --constraint='any.hashable ==1.5.0.0' \
        --constraint='hashable -arch-native -random-initial-seed' \
        --constraint='any.haskell-lexer ==1.2.1' \
        --constraint='any.hourglass ==0.2.12' \
        --constraint='any.hpke ==0.0.0' \
        --constraint='any.hsc2hs ==0.68.10' \
        --constraint='hsc2hs -in-ghc-tree' \
        --constraint='any.hslua ==2.4.0' \
        --constraint='hslua -executable' \
        --constraint='any.hslua-aeson ==2.3.1.1' \
        --constraint='any.hslua-classes ==2.3.1' \
        --constraint='any.hslua-cli ==1.4.3' \
        --constraint='hslua-cli -executable' \
        --constraint='any.hslua-core ==2.3.2' \
        --constraint='any.hslua-list ==1.1.4' \
        --constraint='any.hslua-marshalling ==2.3.1' \
        --constraint='any.hslua-module-doclayout ==1.2.0.1' \
        --constraint='any.hslua-module-path ==1.1.1' \
        --constraint='any.hslua-module-system ==1.2.3' \
        --constraint='any.hslua-module-text ==1.1.1' \
        --constraint='any.hslua-module-version ==1.1.1' \
        --constraint='any.hslua-module-zip ==1.1.4' \
        --constraint='any.hslua-objectorientation ==2.4.0' \
        --constraint='any.hslua-packaging ==2.3.2' \
        --constraint='any.hslua-repl ==0.1.2' \
        --constraint='hslua-repl -executable' \
        --constraint='any.hslua-typing ==0.1.1' \
        --constraint='any.http-api-data ==0.6.2' \
        --constraint='http-api-data -use-text-show' \
        --constraint='any.http-client ==0.7.19' \
        --constraint='http-client +network-uri' \
        --constraint='any.http-client-tls ==0.3.6.4' \
        --constraint='any.http-date ==0.0.11' \
        --constraint='any.http-media ==0.8.1.1' \
        --constraint='any.http-semantics ==0.4.0' \
        --constraint='any.http-types ==0.12.4' \
        --constraint='any.http2 ==5.4.0' \
        --constraint='http2 -devel -h2spec' \
        --constraint='any.indexed-traversable ==0.1.4' \
        --constraint='any.indexed-traversable-instances ==0.1.2' \
        --constraint='any.integer-conversion ==0.1.1' \
        --constraint='any.integer-gmp ==1.1' \
        --constraint='any.integer-logarithms ==1.0.4' \
        --constraint='integer-logarithms -check-bounds +integer-gmp' \
        --constraint='any.iproute ==1.7.15' \
        --constraint='any.ipynb ==0.2' \
        --constraint='any.isocline ==1.0.9' \
        --constraint='any.jira-wiki-markup ==1.5.1' \
        --constraint='any.libyaml ==0.1.4' \
        --constraint='libyaml -no-unicode -system-libyaml' \
        --constraint='any.libyaml-clib ==0.2.5' \
        --constraint='any.lpeg ==1.1.0' \
        --constraint='lpeg -rely-on-shared-lpeg-library' \
        --constraint='any.lua ==2.3.4' \
        --constraint='lua +allow-unsafe-gc -apicheck -cross-compile -export-dynamic -lua_32bits -pkg-config -system-lua' \
        --constraint='any.memory ==0.18.0' \
        --constraint='memory +support_bytestring +support_deepseq' \
        --constraint='any.microlens ==0.4.14.0' \
        --constraint='any.microlens-ghc ==0.4.15.1' \
        --constraint='any.microlens-mtl ==0.2.1.0' \
        --constraint='any.microlens-th ==0.4.3.17' \
        --constraint='any.mime-types ==0.1.2.0' \
        --constraint='any.mmorph ==1.2.1' \
        --constraint='any.monad-control ==1.0.3.1' \
        --constraint='any.mono-traversable ==1.0.21.0' \
        --constraint='any.mtl ==2.3.1' \
        --constraint='any.network ==3.2.8.0' \
        --constraint='network -devel' \
        --constraint='any.network-byte-order ==0.1.7' \
        --constraint='any.network-control ==0.1.7' \
        --constraint='any.network-uri ==2.6.4.2' \
        --constraint='any.old-locale ==1.0.0.7' \
        --constraint='any.old-time ==1.1.0.4' \
        --constraint='any.open-browser ==0.3.0.1' \
        --constraint='open-browser -example' \
        --constraint='any.optparse-applicative ==0.19.0.0' \
        --constraint='optparse-applicative +process' \
        --constraint='any.ordered-containers ==0.2.4' \
        --constraint='any.os-string ==2.0.8' \
        --constraint='any.pandoc ==3.8.3' \
        --constraint='pandoc +embed_data_files' \
        --constraint='pandoc-cli +lua -nightly +server' \
        --constraint='any.pandoc-crossref ==0.3.22' \
        --constraint='pandoc-crossref -enable_flaky_tests' \
        --constraint='any.pandoc-lua-engine ==0.5.0.2' \
        --constraint='any.pandoc-lua-marshal ==0.3.1' \
        --constraint='any.pandoc-server ==0.1.1' \
        --constraint='any.pandoc-types ==1.23.1' \
        --constraint='any.parsec ==3.1.17.0' \
        --constraint='any.pem ==0.2.4' \
        --constraint='any.pretty ==1.1.3.6' \
        --constraint='any.pretty-show ==1.10' \
        --constraint='any.prettyprinter ==1.7.1' \
        --constraint='prettyprinter -buildreadme +text' \
        --constraint='any.prettyprinter-ansi-terminal ==1.1.3' \
        --constraint='any.primitive ==0.9.1.0' \
        --constraint='any.process ==1.6.26.1' \
        --constraint='process +os-string' \
        --constraint='any.psqueues ==0.2.8.2' \
        --constraint='any.random ==1.3.1' \
        --constraint='any.recv ==0.1.1' \
        --constraint='any.regex-base ==0.94.0.3' \
        --constraint='any.regex-tdfa ==1.3.2.5' \
        --constraint='regex-tdfa +doctest -force-o2' \
        --constraint='any.resourcet ==1.3.0' \
        --constraint='any.rts ==1.0.2' \
        --constraint='any.safe ==0.3.21' \
        --constraint='any.scientific ==0.3.8.0' \
        --constraint='scientific -integer-simple' \
        --constraint='any.semialign ==1.3.1' \
        --constraint='semialign +semigroupoids' \
        --constraint='any.semigroupoids ==6.0.1' \
        --constraint='semigroupoids +comonad +containers +contravariant +distributive +tagged +unordered-containers' \
        --constraint='any.serialise ==0.2.6.1' \
        --constraint='serialise +newtime15' \
        --constraint='any.servant ==0.20.3.0' \
        --constraint='any.servant-server ==0.20.3.0' \
        --constraint='any.simple-sendfile ==0.2.32' \
        --constraint='simple-sendfile +allow-bsd -fallback' \
        --constraint='any.singleton-bool ==0.1.8' \
        --constraint='any.skylighting ==0.14.7' \
        --constraint='skylighting -executable' \
        --constraint='any.skylighting-core ==0.14.7' \
        --constraint='skylighting-core -executable' \
        --constraint='any.skylighting-format-ansi ==0.1' \
        --constraint='any.skylighting-format-blaze-html ==0.1.1.3' \
        --constraint='any.skylighting-format-context ==0.1.0.2' \
        --constraint='any.skylighting-format-latex ==0.1' \
        --constraint='any.skylighting-format-typst ==0.1' \
        --constraint='any.some ==1.0.6' \
        --constraint='some +newtype-unsafe' \
        --constraint='any.sop-core ==0.5.0.2' \
        --constraint='any.split ==0.2.5' \
        --constraint='any.splitmix ==0.1.3.1' \
        --constraint='splitmix -optimised-mixer' \
        --constraint='any.stm ==2.5.3.1' \
        --constraint='any.streaming-commons ==0.2.3.1' \
        --constraint='streaming-commons -use-bytestring-builder' \
        --constraint='any.strict ==0.5.1' \
        --constraint='any.syb ==0.7.3' \
        --constraint='any.tagged ==0.8.9' \
        --constraint='tagged +deepseq +transformers' \
        --constraint='any.tagsoup ==0.14.8' \
        --constraint='any.tasty ==1.5.3' \
        --constraint='tasty +unix' \
        --constraint='any.template-haskell ==2.21.0.0' \
        --constraint='any.temporary ==1.3' \
        --constraint='any.texmath ==0.13.0.2' \
        --constraint='texmath -executable -server' \
        --constraint='any.text ==2.1.1' \
        --constraint='any.text-conversions ==0.3.1.1' \
        --constraint='any.text-iso8601 ==0.1.1' \
        --constraint='any.text-short ==0.1.6' \
        --constraint='text-short -asserts' \
        --constraint='any.th-abstraction ==0.7.1.0' \
        --constraint='any.th-compat ==0.1.6' \
        --constraint='any.th-lift ==0.8.6' \
        --constraint='any.th-lift-instances ==0.1.20' \
        --constraint='any.these ==1.2.1' \
        --constraint='any.time ==1.12.2' \
        --constraint='any.time-compat ==1.9.8' \
        --constraint='any.time-manager ==0.2.4' \
        --constraint='any.tls ==2.1.13' \
        --constraint='tls -devel' \
        --constraint='any.toml-parser ==2.0.1.2' \
        --constraint='any.transformers ==0.6.1.0' \
        --constraint='any.transformers-base ==0.4.6' \
        --constraint='transformers-base +orphaninstances' \
        --constraint='any.transformers-compat ==0.7.2' \
        --constraint='transformers-compat -five +five-three -four +generic-deriving +mtl -three -two' \
        --constraint='any.typed-process ==0.2.13.0' \
        --constraint='any.typst ==0.8.1' \
        --constraint='typst -executable' \
        --constraint='any.typst-symbols ==0.1.9.1' \
        --constraint='any.unicode-collation ==0.1.3.6' \
        --constraint='unicode-collation -doctests -executable' \
        --constraint='any.unicode-data ==0.8.0' \
        --constraint='unicode-data -dev-has-icu' \
        --constraint='any.unicode-transforms ==0.4.0.1' \
        --constraint='unicode-transforms -bench-show -dev -has-icu -has-llvm -use-gauge' \
        --constraint='any.uniplate ==1.6.13' \
        --constraint='any.unix ==2.8.8.0' \
        --constraint='unix -non-portable-tests +os-string' \
        --constraint='any.unix-compat ==0.7.4.1' \
        --constraint='any.unix-time ==0.4.17' \
        --constraint='any.unliftio-core ==0.2.1.0' \
        --constraint='any.unordered-containers ==0.2.20.1' \
        --constraint='unordered-containers -debug' \
        --constraint='any.utf8-string ==1.0.2' \
        --constraint='any.utility-ht ==0.0.17.2' \
        --constraint='any.uuid-types ==1.0.6' \
        --constraint='any.vault ==0.3.1.5' \
        --constraint='vault +useghc' \
        --constraint='any.vector ==0.13.2.0' \
        --constraint='vector +boundschecks -internalchecks -unsafechecks -wall' \
        --constraint='any.vector-algorithms ==0.9.1.0' \
        --constraint='vector-algorithms +bench +boundschecks -internalchecks -llvm -unsafechecks' \
        --constraint='any.vector-stream ==0.1.0.1' \
        --constraint='any.wai ==3.2.4' \
        --constraint='any.wai-app-static ==3.1.9' \
        --constraint='wai-app-static +crypton -print' \
        --constraint='any.wai-cors ==0.2.7' \
        --constraint='any.wai-extra ==3.1.18' \
        --constraint='wai-extra -build-example' \
        --constraint='any.wai-logger ==2.5.0' \
        --constraint='any.warp ==3.4.10' \
        --constraint='warp +allow-sendfilefd +include-warp-version -network-bytestring -warp-debug +x509' \
        --constraint='any.witherable ==0.5' \
        --constraint='any.word8 ==0.1.3' \
        --constraint='any.xml ==1.3.14' \
        --constraint='any.xml-conduit ==1.10.1.0' \
        --constraint='any.xml-types ==0.3.8' \
        --constraint='any.yaml ==0.11.11.2' \
        --constraint='yaml +no-examples +no-exe' \
        --constraint='any.zip-archive ==0.4.3.2' \
        --constraint='zip-archive -executable' \
        --constraint='any.zlib ==0.7.1.1' \
        --constraint='zlib -bundled-c-zlib +non-blocking-ffi +pkg-config' \
        . pandoc-cli

# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
RUN find dist-newstyle \
        -name 'pandoc*' -type f -perm -u+x \
        -exec strip '{}' ';' \
        -exec cp '{}' /usr/local/bin/ ';'

# Minimal ###############################################################
FROM scratch AS minimal
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.author="John MacFarlane"
LABEL org.pandoc.version="3.8.3"

# Create basic folders, including a /tmp folder with the correct
# permissions and the folders /usr/local/bin and /usr/local/share/pandoc
ADD static/tmp.tar /

# Copy the pandoc binary
COPY --from=builder \
    /usr/local/bin/pandoc \
    /usr/local/bin/pandoc

# Set user data directory
ENV XDG_DATA_HOME=/usr/local/share

# Set PATH
ENV PATH=/usr/local/bin

# Set the executable
ENTRYPOINT ["/usr/local/bin/pandoc"]

# Set default working directory
WORKDIR /data
