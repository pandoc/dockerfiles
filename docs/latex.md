Pandoc LaTeX images
==================================================================

These images contain [pandoc][], the universal document converter,
and a basic [LaTeX] installation for conversions to PDF.

Using pandoc together with [LaTeX] is a popular option to create
PDF files from other formats. This image provides a [TeX Live]
installation and contains all packages required to produce a PDF
with pandoc's default options.

[pandoc]: https://pandoc.org/
[TeX Live]: https://www.tug.org/texlive/

``` include
docs/sections/quick-reference.md
```

``` include
docs/sections/supported-tags.md
```

Supported stacks <a name="supported-stacks"></a>
------------------------------------------------------------------

All tags can be suffixed with a stack-identifier, e.g.,
`latest-ubuntu`. This allows to chose a specific operation system.
Available stacks are

- *alpine*: [Alpine] Linux.
- *ubuntu*: [Ubuntu] Linux.

The default for `pandoc/latex` is `alpine`.

[Alpine]: https://alpinelinux.org/
[Ubuntu]: https://ubuntu.org/


``` include
docs/sections/run.md
```

TeXLive Version
------------------------------------------------------------------

The TeXLive version for each tag is fixed. See the table below
for the version associated with a given tag / pandoc version.

``` texlive-versions
```

Other images
------------------------------------------------------------------

If the images here do not fit your use-case, then checkout these
alternatives:

-   pandoc/minimal: small images with the pandoc executable.
-   pandoc/core: based on minimal images, but ships with
    additional programs commonly used during conversions.

[LaTeX]: https://latex-project.org/
