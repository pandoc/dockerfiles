#!/bin/sh

usage ()
{
    printf 'Generates all parameters for the docker image\n'
    printf 'Usage: %s ACTION [OPTIONS] [EXTRA BUILD ARGS]\n\n' "$0"
    printf 'Actions:\n'
    printf '\tbuild: build and tag the image\n'
    printf '\tpush: push the tags to Docker Hub\n'
    printf 'Options:\n'
    printf '  -c: targeted pandoc commit, e.g. 2.9.2.1\n'
    printf '  -d: directory\n'
    printf '  -r: targeted image repository/flavor, e.g. core or latex\n'
    printf '  -s: stack on which the image will be based\n'
    printf '  -t: docker build target\n'
    printf '  -v: increase verbosity\n'
}

if ! args=$(getopt 'c:d:pr:s:t:v' "$@"); then
    usage && exit 1
fi
# The variable is intentionally left unquoted.
# shellcheck disable=SC2086
set -- $args

directory=.
pandoc_commit=main
repo=core
stack=static
target=${stack}-${repo}
verbosity=0

while true; do
    case "$1" in
        (-c)
            pandoc_commit="${2}"
            shift 2
            ;;
        (-d)
            directory="${2}"
            shift 2
            ;;
        (-r)
            repo="${2}"
            shift 2
            ;;
        (-s)
            stack="${2}"
            shift 2
            ;;
        (-t)
            target="${2}"
            shift 2
            ;;
        (-v)
            verbosity=$((verbosity + 1))
            shift 1
            ;;
        (--)
            shift
            break
            ;;
        (*)
            printf 'Unknown option: %s\n' "$1"
            usage
            exit 1
            ;;
    esac
done

### Actions
action=${1}
shift

pandoc_version=${pandoc_commit}
if [ "$pandoc_commit" = "main" ]; then
    pandoc_version=edge
fi

# File containing the version table
version_table_file="${directory}/versions.md"
if [ ! -f "$version_table_file" ]; then
    printf 'Version table not found: %s\n' "$version_table_file" >&2
    exit 1
fi
# File containing the default stack config
stack_table_file="${directory}/default-stack.md"
if [ ! -f "$stack_table_file" ]; then
    printf 'Stack table not found: %s\n' "$stack_table_file" >&2
    exit 1
fi

pandoc_version_opts=$(grep "^| *${pandoc_commit} *|" "$version_table_file")
if [ -z "$pandoc_version_opts" ]; then
    printf 'Unsupported version: %s; aborting!\n' "$pandoc_commit" >&2
    exit 1
fi

version_table_field ()
{
    printf '%s\n' "$pandoc_version_opts" | \
        awk -F '|' "{ gsub(/^ *| *\$/,\"\",\$$1); print \$$1 }"
}

base_image_version=
case "$stack" in
    (alpine)
        base_image_version=$(version_table_field 4)
        ;;
    (static)
        # The static binary is built on alpine
        base_image_version=$(version_table_field 4)
        ;;
    (ubuntu)
        base_image_version=$(version_table_field 5)
        ;;
    (*)
        printf 'Unknown stack: %s\n' "$stack" >&2
        exit 1
        ;;
esac

tag_versions=$(version_table_field 3)
texlive_version=$(version_table_field 6)
lua_version=$(version_table_field 7)

# Crossref
extra_packages=pandoc-crossref
without_crossref=

# Do not build pandoc-crossref for static images
if [ "$stack" = "static" ]; then
    extra_packages=
    without_crossref=true
fi

## The pandoc-cli package did not exist pre pandoc 3.
## Do not try to build it if the commit starts with a 2.
if [ "${pandoc_commit#2}" = "${pandoc_commit}" ]; then
    extra_packages="pandoc-cli ${extra_packages}"
fi

# Debug output
if [ "$verbosity" -gt 0 ]; then
    printf 'Building with these parameters:\n'
    printf '\tpandoc_commit: %s\n' "$pandoc_commit"
    printf '\tstack: %s\n' "$stack"
    printf '\tbase_image_version: %s\n' "$base_image_version"
    printf '\ttag_versions: %s\n' "$tag_versions"
    printf '\ttexlive_version: %s\n' "$texlive_version"
    printf '\tlua_version: %s\n' "$lua_version"
    printf '\tverbosity: %s\n' "${verbosity}"
    printf '\textra_packages: %s\n' "$extra_packages"
    printf '\twithout_crossref: %s\n' "${without_crossref}"
    printf '\tversion_table_file: %s\n' "${version_table_file}"
fi

# Succeeds if the stack is the default for this repo, in which case the
# stack can be omitted from the tag.
is_default_stack_for_repo ()
{
    grep -q "^| *$repo *| *${stack} *|$" "$stack_table_file"
}

# ARG 1: pandoc version
# ARG 2: stack
image_name ()
{
    if [ -z "$2" ]; then
        printf 'pandoc/%s:%s' "$repo" "${1:-edge}"
    else
        printf 'pandoc/%s:%s-%s' "$repo" "${1:-edge}" "$2"
    fi
}

# List all tags for this image.
tags ()
{
    for tag_version in $tag_versions; do
        printf '%s\n' "$(image_name "$tag_version" "$stack")"
    done
    if is_default_stack_for_repo; then
        for tag_version in $tag_versions; do
            printf '%s\n' "$(image_name "$tag_version")"
        done
    fi
}

# Produce the "tag" command line arguments for `docker build`
tag_arguments ()
{
    for tag in $(tags); do
        printf ' --tag=%s' "$tag"
    done
}

case "$action" in
    (push)
        for tag in $(tags); do
            printf 'Pushing %s...\n' "$tag"
            docker push "${tag}" ||
                exit 5
        done
        ;;
    (build)
        ## build images
        # The use of $(tag_arguments) is correct here
        # shellcheck disable=SC2046
        docker build "$@" \
               $(tag_arguments) \
               --build-arg pandoc_commit="${pandoc_commit}" \
               --build-arg pandoc_version="${pandoc_version}" \
               --build-arg without_crossref="${without_crossref}" \
               --build-arg extra_packages="${extra_packages}"\
               --build-arg base_image_version="${base_image_version}" \
               --build-arg texlive_version="${texlive_version}" \
               --build-arg texlive_mirror_url="${TEXLIVE_MIRROR_URL}" \
               --build-arg lua_version="${lua_version}" \
               --target "${target}"\
               -f "${directory}/${stack}/Dockerfile"\
               "${directory}"
        ;;
    (*)
        printf 'Unknown action: %s\n' "$action"
        exit 2
        ;;
esac
