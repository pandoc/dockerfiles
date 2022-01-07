#!/bin/sh

usage ()
{
    printf 'Generates all parameters for the docker image\n'
    printf 'Usage: %s ACTION [OPTIONS]\n\n' "$0"
    printf 'Actions:\n'
    printf '\tbuild: build and tag the image\n'
    printf '\tpush: push the tags to Docker Hub\n'
    printf 'Options:\n'
    printf '  -c: targeted pandoc commit, e.g. 2.9.2.1\n'
    printf '  -d: directory\n'
    printf '  -o: docker build options\n'
    printf '  -r: targeted image repository/flavor, e.g. core or latex\n'
    printf '  -s: stack on which the image will be based\n'
    printf '  -t: docker build target\n'
    printf '  -v: increase verbosity\n'
}

if ! args=$(getopt 'c:d:o:pr:s:t:v' "$@"); then
    usage && exit 1
fi
# The variable is intentionally left unquoted.
# shellcheck disable=SC2086
set -- $args

directory=.
pandoc_commit=master
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
        (-o)
            docker_build_options="${2}"
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
if [ "$pandoc_commit" = "master" ]; then
    pandoc_version=edge
fi

# File containing the version table
version_table_file="${directory}/versions.md"
if [ ! -f "$version_table_file" ]; then
    printf 'Version table not found: %s\n' "$version_table_file" >&2
    exit 1
fi

alpine_s_command="\
s#| *${pandoc_commit} |[^|]*| *\\([^ |]*\\) *|[^|]*|\$#\1#p\
"
ubuntu_s_command="\
s#| *${pandoc_commit} |[^|]*|[^|]*| *\\([^ |]*\\) *|\$#\1#p\
"

base_image_version=
case "$stack" in
    (alpine)
        base_image_version=$(sed -ne "$alpine_s_command" "$version_table_file")
        ;;
    (static)
        # The static binary is built on alpine
        base_image_version=$(sed -ne "$alpine_s_command" "$version_table_file")
        ;;
    (ubuntu)
        base_image_version=$(sed -ne "$ubuntu_s_command" "$version_table_file")
        ;;
    (*)
        printf 'Unknown stack: %s\n' "$stack" >&2
        exit 1
        ;;
esac

tag_versions=$(sed -ne "s#| *${pandoc_commit} | \\([^|]*\\) *|.*\$#\\1#p" \
                   "$version_table_file")

# Crossref
extra_packages=pandoc-crossref
without_crossref=

# Do not build pandoc-crossref for static images
if [ "$stack" == "static" ]; then
    extra_packages=
    without_crossref=true
fi

# Debug output
if [ "$verbosity" -gt 0 ]; then
    printf 'Building with these parameters:\n'
    printf '\tpandoc_commit: %s\n' "$pandoc_commit"
    printf '\tstack: %s\n' "$stack"
    printf '\tbase_image_version: %s\n' "$base_image_version"
    printf '\ttag_versions: %s\n' "$tag_versions"
    printf '\tverbosity: %s\n' "${verbosity}" >&2
    printf '\textra_packages: %s\n' "$extra_packages"
    printf '\twithout_crossref: %s\n' "${without_crossref}"
    printf '\tversion_table_file: %s\n' "${version_table_file}" >&2
fi

image_name ()
{
    local tag_version="${1:-edge}"
    printf 'pandoc/%s:%s-%s' "$repo" "$tag_version" "$stack"
}

tags ()
{
    for tag_version in $tag_versions; do
        printf ' --tag=%s' "$(image_name "$tag_version")"
    done
}

extra_options ()
{
    printf '%s' "$@"
}


case "$action" in
    (push)
        for tag_version in $tag_versions; do
            image=$(image_name "$tag_version")
            printf 'Pushing %s...\n' "$image"
            docker push "${image}" ||
                exit 5
        done
        ;;
    (build)
        ## build images
        docker build $(extra_options)\
               $(tags)\
               --build-arg pandoc_commit="${pandoc_commit}"\
               --build-arg pandoc_version="${pandoc_version}"\
               --build-arg without_crossref="${without_crossref}"\
               --build-arg extra_packages="${extra_packages}"\
               --build-arg base_image_version="${base_image_version}"\
               --target "${target}"\
               -f "${directory}/${stack}/Dockerfile"\
               "${directory}"
        ;;
    (*)
        printf 'Unknown action: %s\n' "$action"
        exit 2
        ;;
esac
