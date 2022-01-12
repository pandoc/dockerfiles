Supported tags
-----------------------------------------------------------------

``` supported-tags
```

The tags listed in a bullet point all refer to the same image.
Numerical tags are rolling, meaning that a version tag always
points to the newest image with the given version prefix. A
prefix-version like `a.b.` is an easy way to specify a range of
acceptable versions. Use a full, four part version like `a.b.c.d`
to fix the image to a specific version.

The *latest* tag refers to the most recently released version;
there may be a minor lag between the time a pandoc version is
released and a new image is released.

A recent development version is provided under the *edge* tag. 

All tags can be suffixed with a stack identifier (see [Supported
stacks](#supported-stacks)).

### A note on pandoc versioning

Pandoc is not only an executable but also a Haskell *library*,
which is why it is versioned using the [Haskell Package Versioning
Policy][PVP]. Even minor versions can sometimes introduce new
behavior if the API does not change, but this is a rare occasion.

[PVP]: https://pvp.haskell.org
