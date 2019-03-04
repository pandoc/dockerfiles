pandoc Dockerfiles
================================================================================

This repo contains a collection of Dockerfiles to build various
pandoc container images.

**Contents**

- [Available Images](#available-images)
    - [Current `latest` Tag](#current-latest-tag)
    - [Alpine Linux](#alpine-linux)
- [Maintenance Notes](#maintenance-notes)
    - [Adding a new Image Stack](#adding-a-new-image-stack)
    - [Managing new Pandoc Releases](#managing-new-pandoc-releases)
- [License](#license)

Available Images
================================================================================

Docker images hosted here have a "core" version and a "latex" version:

- core: `pandoc` and `pandoc-citeproc`, as well as the appropriate backend for
  the full lua filtering backend (lua filters can call external modules).
- latex: builds on top of the core image, and provides an as-minimal-as-possible
  latex installation in addition.  This includes all packages that `pandoc`
  _might_ use, and any libraries needed by these packages (such as image
  libraries needed by the latex graphics packages).

From there, the tagging scheme is either `X.Y`, `latest`, or `edge`.

- `X.Y`: an official `pandoc` release (e.g., `2.6`).  Once an `X.Y` tag is
  pushed, it will not be re-built (unless there is a problem).
- `latest`: the `latest` tag points to the most recent `X.Y` release.  For
  example, if tags `2.5` and `2.6` were available online, `latest` would be the
  same image as `2.6`.
- `edge`: the "bleeding edge" tag clones the `master` branch of `pandoc` and
  `pandoc-citeproc`.  This tag is a moving target, and will be re-built
  _at least_ once a month.  The CI scripts have a cron job to build each image
  stack on the first of the month.  However, changes to the `master` branch of
  this repository may also result in the `edge` tag being updated sooner.

Current `latest` Tag
--------------------------------------------------------------------------------

The current `latest` tag for all images points to `pandoc` version `2.6`.

Alpine Linux
--------------------------------------------------------------------------------

- Core image: [`pandoc/core`](https://hub.docker.com/r/pandoc/core/)
    - To build locally: `make alpine`
- Latex image: [`pandoc/latex`](https://hub.docker.com/r/pandoc/latex/)
    - To build locally: `make alpine-latex`

Maintenance Notes
================================================================================

Adding a new Image Stack
--------------------------------------------------------------------------------

Suppose users desire a new image stack using a different base image.  To make
the requirements clearer, assume the desire is to have a new image stack based
off `ubuntu`.

1. Create a top-level directory named `ubuntu`.  The name of this directory
   should be exactly the same as whatever the `FROM` clause will be, for
   consistency and clarity.
2. Create `ubuntu/Dockerfile`.  This `Dockerfile` will be the "core" `ubuntu`
   image, it should only contain `pandoc` and `pandoc-citeproc`.  Refer to the
   [`alpine/Dockerfile`](alpine/Dockerfile) for assistance in how to create
   multiple layers.  The idea is to create a base image, install all build
   dependencies and `pandoc` / `pandoc-citeproc`.  Then create a new layer from
   the original base image and copy from the intermediate build layer.  This way
   the `pandoc` / `pandoc-citeproc` are effectively the only additional items
   on top of the original base image.
3. Add an `ubuntu` target to the `Makefile`.
4. Create `ubuntu/latex/Dockerfile` and install the latex dependencies.  Use the
   [`alpine/latex/Dockerfile`](alpine/latex/Dockerfile) as a reference for what
   dependencies should be installed in addition to latex.
5. Add an `ubuntu-latex` target to the `Makefile`.
6. Now that your image stack has been defined (and tested!), update the CircleCI
   [`.circleci/config.yml`](.circleci/config.yml) file to add a new build stack.
   Specifically, search for `alpine_stack: &alpine_stack`.  An example `diff`
   for this `ubuntu` stack could look like this:

   ```diff
   @@ -58,6 +58,9 @@ jobs:
    alpine_stack: &alpine_stack
      core_target: alpine
      latex_target: alpine-latex
   +ubuntu_stack: &ubuntu_stack
   +  core_target: ubuntu
   +  latex_target: ubuntu-latex

    # Setup builds for each commit, as well as monthly cron job.
    workflows:
   @@ -66,12 +69,17 @@ workflows:
          - lint
          - build_stack:
              <<: *alpine_stack
   +      - build_stack:
   +          <<: *ubuntu_stack
      monthly:
        # NOTE: make sure all `build_stack` calls here *also* set `cron_job: true`!
        jobs:
          - build_stack:
              <<: *alpine_stack
              cron_job: true
   +      - build_stack:
   +          <<: *ubuntu_stack
   +          cron_job: true
   ```

   **You should not need to edit anything else in this file!**
7. Update this file (README.md) to include a listing of this new image stack.
   Create a new h2 heading (`Ubuntu Linux` in this example) underneath
   `All Image Stacks` heading.  Please keep this alphabetical.  Please also make
   sure to create a hyperlink under the `**Contents**` listing at the top of
   this file for browsing convenience.
8. Open a Pull Request for review!

Managing new Pandoc Releases
--------------------------------------------------------------------------------

When `pandoc` has a new official release, the following steps must be performed
in this exact order:

1. Create a pull request from a branch.  Edit the ``Current `latest` Tag``
   section to include the new `pandoc` release number.  Suppose
   we are releasing image stacks for `pandoc` version 9.8:

   ```console
   $ git checkout -b release/9.8
   # ... edit current :latest ...
   $ git add README.md
   $ git commit -m 'release=9.8'
   $ git push -u origin release/9.8
   ```

   The important part is the commit message.  The build script looks for exactly
   `release=[0-9]\.[0-9]` in the message, and if found performs the additional
   tagging to `:latest`.  So the diff does not really matter, just the message.

   Create a pull request first to make sure all image stacks build as expected.
2. Assuming the pull request build succeeds, merge to `master` branch.  The only
   time that `docker push` is performed is when a commit hits the `master`
   branch of this repository.

GitHub Actions
================================================================================
You can use the `pandoc/latex` image directly on GitHub actions to convert
documents on every commit using the
[pandoc GitHub action](https://github.com/maxheld83/pandoc).


License
================================================================================

Code in this repository is licensed under the
[GNU General Public License Version 2](LICENSE).
