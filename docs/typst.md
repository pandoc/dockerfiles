Pandoc Typst images
==================================================================

These images contain [pandoc][], the universal document converter,
and [Typst][], a fast and modern typesetting system that can be
used to produce PDFs.

[pandoc]: https://pandoc.org/
[Typst]: https://typst.app

``` include
docs/sections/quick-reference.md
```

``` include
docs/sections/supported-tags.md
```

Supported stacks
------------------------------------------------------------------

All tags can be suffixed with a stack-identifier, e.g.,
`latest-ubuntu`. This allows to chose a specific operation system.
Available stacks are

- *alpine*: [Alpine] Linux.
- *ubuntu*: [Ubuntu] Linux.

The default for `pandoc/typst` is `alpine`.

[Alpine]: https://alpinelinux.org/
[Ubuntu]: https://ubuntu.org/


``` include
docs/sections/run.md
```

Use the `--pdf-engine=typst` pandoc option to generate a PDF via
Typst.

``` include
docs/sections/other-images.md
```
