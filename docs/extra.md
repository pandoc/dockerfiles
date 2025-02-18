Pandoc extra images
==================================================================

These images contain [pandoc][], the universal document converter
and a curated selection of components:

* Templates: [Eisvogel][]
* Beamer Themes: [beamer-metropolis][]
* Pandoc filters: [pandoc-latex-environment][] + [Lua filters][], [pandoc-include][]
* Open Source Fonts: Font Awesome, Source Code Pro, Source Sans Pro
* PDF engines: [Tectonic][]

[Eisvogel]: https://github.com/Wandmalfarbe/pandoc-latex-template
[beamer-metropolis]: https://github.com/matze/mtheme
[pandoc-latex-environment]: https://github.com/chdemko/pandoc-latex-environment
[Lua filters]: https://github.com/pandoc/lua-filters
[pandoc-include]: https://github.com/DCsunset/pandoc-include
[Tectonic]: https://tectonic-typesetting.github.io

[pandoc]: https://pandoc.org/
[LaTeX]: https://latex-project.org/
[TeX Live]: https://www.tug.org/texlive/

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

The default for `pandoc/extra` is `alpine`.

[Alpine]: https://alpinelinux.org/
[Ubuntu]: https://ubuntu.org/


``` include
docs/sections/run.md
docs/sections/other-images.md
```
