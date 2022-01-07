Quick Reference
===============

  - **Where to get help**: [pandoc-discuss mailing
    list][pandoc-discuss]

  - **Where to report issues**:
    https://github.com/pandoc/dockerfiles/issues

  - **Source repository**: [pandoc/dockerfiles] on Github

  - **Maintained by**: [Albert Krewinkel], [Stephen McDowell], and [Caleb
    Maclennan].

[pandoc-discuss]: https://groups.google.com/forum/#!forum/pandoc-discuss
[pandoc/dockerfiles]: https://github.com/pandoc/dockerfiles
[Albert Krewinkel]: https://github.com/tarleb
[Stephen McDowell]: https://github.com/svenevs
[Caleb Maclennan]: https://github.com/alerque

Supported Tags
==============

* *edge*: this is a development version.

* *latest*: most recently released version.

* Numeric version names, following official pandoc releases.

  Note that pandoc is not only an executable but also a Haskell
  *library*, which is why it is versioned using the [Haskell
  Package Versioning Policy][PVP]. Even minor
  versions can introduce new behavior if the API does not change.

New pandoc versions should be made available within a short time,
generally within a few days.

[PVP]: https://pvp.haskell.org

Images
======

All images contain [pandoc](https://pandoc.org), the universal
document converter.

The following flavors are available for Alpine and Ubuntu based
images, unless noted otherwise.

minimal
-------

Core images only contain the operating system, if any, and the
pandoc binary. This is as small as it gets.

core
----

Core images are based on minimal images, but ship with additional
programs commonly used during conversions. E.g., the images also
contain a program to convert SVG graphics (svg-convert), as well
as the [pandoc-crossref] filter, often used to number figures,
equations, tables and to cross-reference them.

[pandoc-crossref]: https://lierdakil.github.io/pandoc-crossref/

latex
-----

Using pandoc together with [LaTeX] is a popular option to create
PDF files from other formats. The *latex* image builds on top of
the *core* image and provides a [TeX Live] installation,
providing all packages required to produce a PDF with pandoc's
default options.

[LaTeX]: https://latex-project.org/
[TeX Live]: https://www.tug.org/texlive/
