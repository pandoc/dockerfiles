# Case: new pandoc release

- [ ] Add a new row for the release to `versions.md`. Make sure
  that no tag in the `tags` column is listed twice; adjust other
  rows if necessary. Use the "Alpine" and "Ubuntu" releases that
  are used for the dev (main) version.

- [ ] Set the PANDOC_VERSION environment variable. This will save
  a good bit of typing and prevent mistakes further down.

      ``` console
      $ export PANDOC_VERSION=2.13
      ```

- [ ] Create freeze files for each stack by running:

  ``` console
  $ make {static,alpine,ubuntu}-freeze-file
  ```

  It may make sense to also specify `WITHOUT_CROSSREF=true`, but
  the build should succeed either way.

- [ ] Commit the results.

  ``` console
  $ git add {static,alpine,ubuntu}/freeze/pandoc-$PANDOC_VERSION.project.freeze
  $ git commit -m "Create release=$PANDOC_VERSION"
  $ gh pr create --fill --draft
  ```

  or push it directly.

- [ ] Once the change is in the `main` branch, trigger the [Image
  Builder] action on GitHub for *all* supported stacks. This has
  to be done manually. Make sure to use the correct pandoc
  version. It seems that the build is more likely to hang if there
  are multiple parallel builds, so it might be necessary to wait
  for a build to finish before starting the next.

  *Please do this sparingly!* The *Image Builder* action uses the
  Docker Build Cloud, which grants only a limited amount of
  computing time each month. The pandoc org currently gets 400
  minutes per month through the Docker open source program;
  (re)building all images for a pandoc version consumes in the
  ballpark of 60 to 90 minutes of build time (or more if there are
  errors).

  Before anyone asks: no, just using GitHub Actions doesn't work,
  because the machines provided there are not powerful enough to
  compile arm64 binaries, neither natively on mac, nor via QEMU
  emulation.

- [ ] If there is a problem, e.g., because the tests fails as
  pandoc-crossref does not actually work with the new pandoc
  version, then raise an issue on GitHub. Either we can fix it, or
  we'll have to be patient and wait for an updated
  pandoc-crossref.

- [ ] Done.

[Image Builder]: https://github.com/pandoc/dockerfiles/actions/workflows/build.yaml

# Case: TeXLive was frozen

The `tlmgr` command in LaTeX images will start to behave badly
every time a new TeXLive version is released. All images with the
now frozen TeXLive version will have to be rebuilt.

- [ ] Change the variable `default_version` in file
  `common/latex/install-texlive.sh` to the current year.

- [ ] Rebuilt and push all images that come with the last, now
  frozen, TeXLive version. This will probably affect multiple
  versions. Put a line with all these version anywhere in the
  commit message. E.g.,

      release=2.17, 2.16.2

  The CI will then rebuild all specified versions.
