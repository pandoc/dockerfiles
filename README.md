pandoc Dockerfiles
================================================================================

[![CircleCI](https://circleci.com/gh/pandoc/dockerfiles/tree/master.svg?style=svg)](https://circleci.com/gh/pandoc/dockerfiles/tree/master)

This repo contains a collection of Dockerfiles to build various
[pandoc](https://pandoc.org/) container images.

**Contents**

- [Available Images](#available-images)
    - [Current `latest` Tag](#current-latest-tag)
    - [Alpine Linux](#alpine-linux)
- [Usage](#usage)
    - [Basic Usage](#basic-usage)
    - [Pandoc Scripts](#pandoc-scripts)
    - [GitHub Action](#github-action)
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

From there, the tagging scheme is either `X.Y`, `X.Y.Z`, `latest`, or `edge`.

- `X.Y` or `X.Y.Z`: an official `pandoc` release (e.g., `2.6`).  Once an `X.Y`
  tag is pushed, it will not be re-built (unless there is a problem).  Pandoc
  releases versions such as `2.7` or `2.7.1` (there is no `2.7.0`), which is
  where the optional `.Z` comes from.
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

The current `latest` tag for all images points to `pandoc` version `2.9`.

Alpine Linux
--------------------------------------------------------------------------------

- Core image: [`pandoc/core`](https://hub.docker.com/r/pandoc/core/)
    - To build locally: `make alpine`
- Latex image: [`pandoc/latex`](https://hub.docker.com/r/pandoc/latex/)
    - To build locally: `make alpine-latex`

Usage
================================================================================

> **Note**: this section describes how to use the docker images.  Please refer
> to the [`pandoc` manual](https://pandoc.org/MANUAL.html) for usage information
> about `pandoc`.

Docker images are pre-provisioned computing environments, similar to virtual
machines, but smaller and cleverer. You can use these images to convert document
wherever you can run docker images, without having to worry about pandoc or its
dependencies. The images bring along everything they need to get the job done.

Basic Usage
--------------------------------------------------------------------------------

1. Install [Docker](https://www.docker.com) if you don't have it already.

2. Start up Docker. Usually you will have an application called "Docker" on your
   computer with a rudimentary graphical user interface (GUI). You can also run
   this command in the command-line interface (CLI):

   ```sh
   open -a Docker
   ```

3. Open a shell and navigate to wherever the files are that you want to convert.

   ```sh
   cd path/to/source/dir
   ```

   You can always run `pwd` to check whether you're in the right place.

4. [Run docker](https://docs.docker.com/engine/reference/run/) by entering the
   below commands in your favorite shell.

   Let's say you have a `README.md` in your working directory that you'd like to
   convert to HTML.

   ```sh
   docker run --volume "`pwd`:/data" --user `id -u`:`id -g` pandoc/latex:2.6 README.md
   ```

   The `--volume` flag maps some directory on *your machine* (lefthand side of
   the colons) to some directory *in the container* (righthand side), so that
   you have your source files available for pandoc to convert. `pwd` is quoted
   to protect against spaces in filenames.

   Ownership of the output file is determined by the user executing pandoc *in
   the container*. This will generally be a user different from the local user.
   It is hence a good idea to specify for docker the user and group IDs to use
   via the `--user` flag.

   `pandoc/latex:2.6` declares the image that you're going to run. It's always a
   good idea to hardcode the version, lest future releases break your code.

   It may look weird to you that you can just add `README.md` at the end of this
   line, but that's just because the `pandoc/latex:2.6` will simply prepend
   `pandoc` in front of anything you write after `pandoc/latex:2.6` (this is
   known as the `ENTRYPOINT` field of the Dockerfile). So what you're really
   running here is `pandoc README.md`, which is a valid pandoc command.

   If you don't have the current docker image on your computer yet, the
   downloading and unpacking is going to take a while. It'll be (much) faster
   the next time. You don't have to worry about where/how Docker keeps these
   images.

Pandoc Scripts
--------------------------------------------------------------------------------

Pandoc commands have a way of getting pretty long, and so typing them into the
command line can get a little unwieldy. To get a better handle of long pandoc
commands, you can store them in a script file, a simple text file with an `*.sh`
extension such as

```sh
#!/bin/sh
pandoc README.md
```

The first line, known as the [*shebang*](https://stackoverflow.com/q/7366775)
tells the container that the following commands are to be executed as shell
commands. In our case, we really don't use a lot of shell magic, we just call
pandoc in the second line (though you can get fancier, if you like). Notice that
the `#!/bin/sh` will *not* get you a full bash shell, but only the more basic
ash shell that comes with Alpine linux on which the pandoc containers are based.
This won't matter for most uses, but if you want to write writing more
complicated scripts you may want to refer to the [`ash`
manual](https://linux.die.net/man/1/ash).

Once you have stored this script, you must make it executable by running the
following command on it (this may apply only to UNIX-type systems):

```sh
chmod +x script.sh
```

You only have to do this once for each script file.

You can then run the completed script file in a pandoc docker container like so:

```sh
docker run --volume "`pwd`:/data" --entrypoint "`pwd`/script.sh" pandoc/latex:2.6
```

Notice that the above `script.sh` *did* specify `pandoc`, and you can't just
omit it as in the simpler command above. This is because the `--entrypoint` flag
*overrides* the `ENTRYPOINT` field in the docker file (`pandoc`, in our case),
so you must include the command.

GitHub Actions
--------------------------------------------------------------------------------

GitHub Actions is an Infrastructure as a Service (IaaS) from GitHub, that allows
you to automatically run code on GitHub's servers on every push (or a bunch of
other GitHub events). For example, you can use GitHub Actions to convert some
`file.md` in your git source to `file.pdf` (via LaTeX) using pandoc and upload
 the results to a web host.

To use pandoc on GitHub Actions, you can leverage the docker images of this
project.

To learn more how to use the docker pandoc images in your GitHub Actions
workflow, see
[these examples](http://github.com/maxheld83/pandoc-action-example).


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
6. Add testing targets `test-ubuntu` and `test-ubuntu-latex`.  You should be
   able to copy-paste the existing `test-alpine` and `test-alpine-latex` targets
   and rename the [target-specific variable value][tsvv] for `IMAGE`:

   ```make
   # update default ---> |-----------------------------|
   test-ubuntu: IMAGE ?= pandoc/ubuntu:$(PANDOC_VERSION)
   test-ubuntu: # vvv invokation line is the same as alpine tests
   	IMAGE=$(IMAGE) make -C test test-core
   ```

   This means that `make test-ubuntu` will invoke the `test-core` target in the
   [`test/Makefile`](test/Makefile), using the image `pandoc/ubuntu:edge`.
   The target specific value is helpful for developers to be able to run the
   tests against an alternative image, e.g.,
   `IMAGE=test/ubuntu:edge make test-ubuntu`.  **Note that the testing targets
   must be the `core` and `latex` targets with `test-` preprended**.  The CI
   tests run `make test-<< parameters.core_target >>` and
   `make test-<< parameters.latex_target >>` (see next item).
7. Now that your image stack has been defined (and tested!), update the CircleCI
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
8. Update this file (README.md) to include a listing of this new image stack.
   Create a new h2 heading (`Ubuntu Linux` in this example) underneath
   `All Image Stacks` heading.  Please keep this alphabetical.  Please also make
   sure to create a hyperlink under the `**Contents**` listing at the top of
   this file for browsing convenience.
9. Open a Pull Request for review!

[tsvv]: https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html

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

   The important part is the commit message.  The
   [`.circleci/version_for_commit_message.sh`][vfcm] script will check the
   commit message for `release=X.Y` / `release=X.Y.Z`, and if found performs the
   additional tagging to `:latest`.  So the diff does not really matter, just
   the message.

   Create a pull request first to make sure all image stacks build as expected.
2. Assuming the pull request build succeeds, merge to `master` branch.  The only
   time that `docker push` is performed is when a commit hits the `master`
   branch of this repository.

[vfcm]: .circleci/version_for_commit_message.sh

License
================================================================================

Code in this repository is licensed under the
[GNU General Public License Version 2](LICENSE).
