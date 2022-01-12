Core pandoc images
==================================================================

These images contain [pandoc][], the universal document converter,
and a minimal operating system with all tools required for common
conversion tasks.

E.g., the images also contain a program to convert SVG graphics
(svg-convert), as well as the [pandoc-crossref] filter, often used
to number figures, equations, tables and to cross-reference them.

[pandoc]: https://pandoc.org/
[pandoc-crossref]: https://lierdakil.github.io/pandoc-crossref/

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

The default for `pandoc/core` is `alpine`.

[Alpine]: https://alpinelinux.org/
[Ubuntu]: https://ubuntu.org/

``` include
docs/sections/run.md
```

Other images
-----------------------------------------------------------------

If the images here do not fit your use-case, then checkout these
alternatives:

-   pandoc/minimal: small images with the pandoc executable.

-   pandoc/latex: suitable for conversions to PDF via [LaTeX].

[LaTeX]: https://latex-project.org/
