#!/bin/sh

usage ()
{
    printf 'Generate parameters for GitHub Actions\n\n'
    printf 'Usage:\n\t%s <pandoc_version> <build_stack> <image_names>\n' "$0"
}

if [ "$#" -ne 3 ]; then
    usage
    exit 1
fi

version="${1:-main}"
build_stack="${2:-alpine}"
images="${3}"

versions_file=versions.md
row="$(grep "^| $version " "$versions_file")"

if [ -z "$row" ]; then
    printf 'Unknown or unsupported version "%s"\n' "$version"
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
        base_image_version="$(field 3)"
        ;;
    (ubuntu)
        base_image='ubuntu'
        base_image_version="$(field 4)"
        ;;
    (*)
        printf 'Unsupported base image: "%s"\n' "$base_image"
        ;;
esac

version_tags="$(field 2)"
tags=
for name in $(printf '%s\n' "$images" | tr ',' ' '); do
    image_tags_base="$( \
        printf '%s\n' "$version_tags" | sed -e "s#\([^,]*\)#${name}:\1#g" \
    )"
    image_tags="$(printf '%s' "$image_tags_base" | \
                    sed -e 's#\([^,]*\)#\1-'${base_image}'#g')"
    image_name=$(printf '%s\n' "$name" | sed -e 's#.*\([^/]\+/[^/]\+\)$#\1#')
    if { [ "$image_name" != 'pandoc/minimal' ] && \
         [ "$build_stack" = 'alpine' ]; } ||
       { [ "$image_name"  = 'pandoc/minimal' ] && \
         [ "$build_stack" = 'static' ]; };
    then
        tags="${tags},${image_tags_base},${image_tags}"
    else
        tags="${tags},${image_tags}"
    fi
done
tags=$(printf '%s\n' "$tags" | sed -e 's/^,//')

printf 'tags="%s"\n' "$tags"
printf 'base_image="%s"\n' "$base_image"
printf 'base_image_version="%s"\n' "$base_image_version"
printf 'texlive_version="%s"\n' "$(field 5)"
