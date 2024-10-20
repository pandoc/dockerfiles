#!/bin/sh

usage ()
{
    printf 'Generate parameters for GitHub Actions\n\n'
    printf 'Usage:\n\t%s <pandoc_version> <build_stack> <image_name>\n' "$0"
}

if [ "$#" -ne 3 ]; then
    usage
    exit 1
fi

version="${1:-main}"
build_stack="${2:-alpine}"
image_name="${3:-pandoc/minimal}"

versions_file=versions.md
row="$(grep "^| $version " "$versions_file")"

if [ -z "$row" ]; then
    printf "Unknown or unsupported version '%s'\n" "$version"
    exit 1
fi

field ()
{
    col=$(($1 + 1))
    printf '%s\n' "$row" | \
        awk -F '|' "{ gsub(/^ *| *\$/,\"\",\$$col); print \$${col} }" | \
        sed -e 's/  */,/g'
}

case "${build_stack}" in
    (alpine|static)
        base_image='alpine'
        base_image_tag="$(field 3)"
        ;;
    (ubuntu)
        base_image='ubuntu'
        base_image_tag="$(field 4)"
        ;;
    (*)
        printf "Unsupported base image: '%s'\n" "$base_image"
        ;;
esac

printf '%s\n' "$(field 2)"

tagsbase="$(field 2 | sed -e "s#\([^,]*\)#${image_name}:\1#g")"
tags="$(printf '%s' "$tagsbase" | \
               sed -e 's#\([^,]*\)#\1-'${base_image}'#g')"
if ( [ "$image_name" != 'pandoc/minimal' ] && \
     [ "$build_stack" = 'alpine' ] ) ||
   ( [ "$image_name"  = 'pandoc/minimal' ] && \
     [ "$build_stack" = 'static' ] );
then
    tags="${tags},${tagsbase}"
fi

printf 'tags="%s"\n' "$tags"
printf 'base_image="%s"\n' "$base_image"
printf 'base_image_tag="%s"\n' "$base_image_tag"
printf 'texlive_version="%s"\n' "$(field 5)"
