Run the pandoc Docker container
------------------------------------------------------------------

A common use of the image looks like this (linebreaks for
readability):

``` sh
docker run --rm \
       --volume "$(pwd):/data" \
       --user $(id -u):$(id -g) \
       pandoc/latex README.md -o outfile.pdf
```

This will convert the file `README.md` in the current working
directory into `outfile.pdf`. Note that Docker options go *before*
the image name, here `pandoc/latex`, while pandoc options come
*after* it.

The `--volume` flag maps some local directory (lefthand side of
the colons) to a directory in the container (righthand side), so
that you have your source files available for pandoc to convert.
`$(pwd)` is quoted to protect against spaces in filenames.

Ownership of the output file is determined by the user executing
pandoc *in the container*. This will generally be a user different
from the local user. It is hence a good idea to specify for docker
the user and group IDs to use via the `--user` flag.

For frequent command line use, we suggest the following shell
alias:

``` sh
alias pandock=\
'docker run --rm -v "$(pwd):/data" -u $(id -u):$(id -g) pandoc/latex'
```
