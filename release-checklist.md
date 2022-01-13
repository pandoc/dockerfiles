# Case: new pandoc release

- [ ] Add a new row for the release to `versions.md`. Make sure
  that no tag in the `tags` column is listed twice; adjust other
  rows if necessary. Use the "Alpine" and "Ubuntu" releases that
  are used for the dev (master) version.

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

- [ ] GitHub Actions will take it from here: the new images will
  be built and pushed to Docker Hub as soon as the commit hits the
  master branch. Just check after 1h that everything worked.

- [ ] If there is a problem, e.g., because the tests fails as
  pandoc-crossref does not actually work with the new pandoc
  version, then raise an issue on GitHub. Either we can fix it, or
  we'll have to be patient and wait for an updated
  pandoc-crossref.

- [ ] Update the readme for each repository. This cannot be
  automated yet due to limitations of the Docker Hub API.

    - [ ] Go to
          https://hub.docker.com/repository/docker/pandoc/minimal
    - [ ] Click the edit button next to "Readme".
    - [ ] Select and delete the old contents.
    - [ ] Run `make docs-minimal | xclip` (or `| pbcopy` on mac)
    - [ ] Paste the result, then save.

  Repeat for `core` and `latex`.

- [ ] Done.


# Case: TeXLive was frozen

The `tlmgr` command in LaTeX images will start to behave badly
every time a new TeXLive version is released. All images with the
now frozen TeXLive version will have to be rebuilt.
