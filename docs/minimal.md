Minimal pandoc images
==================================================================

These images contain [pandoc][], the universal document converter.
Containers are stripped down to a bare minimum as far as sensible:
The "static" images contain only a statically compiled pandoc
binary, whereas the other images also contain a minimal operating
system.

[pandoc]: https://pandoc.org/

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

- *static*: statically compiled binary, wrapped in a `scratch`
  image.
- *alpine*: [Alpine] Linux.
- *ubuntu*: [Ubuntu] Linux.

The default for `pandoc/minimal` is `static`.

[Alpine]: https://alpinelinux.org/
[Ubuntu]: https://ubuntu.org/

``` include
docs/sections/run.md
```

Other images
-----------------------------------------------------------------

If the images here do not fit your use-case, then checkout these
alternatives:

-   [**pandoc/core**][]: based on minimal images, but ships with
    additional programs commonly used during conversions.
-   [**pandoc/latex**][]: suitable for conversions to PDF via [LaTeX].

[LaTeX]: https://latex-project.org/

[**pandoc/core**]: https://hub.docker.com/r/pandoc/core
[**pandoc/latex**]: https://hub.docker.com/r/pandoc/latex
