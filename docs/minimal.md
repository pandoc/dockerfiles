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

Supported stacks
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
docs/sections/other-images.md
```
