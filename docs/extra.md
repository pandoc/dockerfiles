Pandoc extra images
==================================================================

These images contain [pandoc][], the universal document converter
and a curated selection of components:

* Templates: [Eisvogel][]
* Pandoc filters: [pandoc-latex-environment][]
* Open Source Fonts: Font Awesome, Source Code Pro, Source Sans Pro


[Eisvogel]: https://github.com/Wandmalfarbe/pandoc-latex-template
[pandoc-latex-environment]: https://github.com/chdemko/pandoc-latex-environment

[pandoc]: https://pandoc.org/
[LaTeX]: https://latex-project.org/
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

The default for `pandoc/extra` is `alpine`.

[Alpine]: https://alpinelinux.org/
[Ubuntu]: https://ubuntu.org/


``` include
docs/sections/run.md
```

Other images
------------------------------------------------------------------

If the images here do not fit your use-case, then checkout these
alternatives:

-   [**pandoc/minimal**][]: small images with the pandoc executable.
-   [**pandoc/core**][]: based on minimal images, but ships with
    additional programs commonly used during conversions.
-   [**pandoc/latex**][]: based on core images, but ships with a basic
    [LaTeX] installation.

[**pandoc/minimal**]: https://hub.docker.com/r/pandoc/minimal
[**pandoc/core**]: https://hub.docker.com/r/pandoc/core
[**pandoc/latex**]: https://hub.docker.com/r/pandoc/latex
