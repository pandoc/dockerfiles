pandoc Dockerfiles
================================================================================

This repo contains a collection of Dockerfiles to build various
pandoc container images.

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

Usage
================================================================================

Docker images are pre-provisioned computing environments, similar to virtual machines, but smaller and cleverer.
You can use these images to convert document wherever you can run docker images, without having to worry about pandoc or its dependencies.
The images bring along everything they need to get the job done.

Basic Usage
--------------------------------------------------------------------------------

1. Install [Docker](https://www.docker.com) if you don't have it already.

2. Start up Docker.
  Usually you will have an application called "Docker" on your computer with a rudimentary graphical user interface (GUI).
  You can also run this command in the command-line interface (CLI):
  
  ```
  open -a Docker
  ```

3. Open a shell and navigate to wherever the files are that you want to convert.
  
  ```
  cd path/to/source/dir
  ```
  
  You can always run `pwd` to check whether you're in the right place.

4. [Run docker](https://docs.docker.com/engine/reference/run/) by entering the below commands in your favorite shell.

  Let's say you have a `README.md` in your working directory that you'd like to convert to HTML.
  
  ```
  docker run --volume "`pwd`":"`pwd`" --workdir "`pwd`" pandoc/latex:2.6 README.md
  ```
  
  The `--volume` flag maps some directory on *your machine* (lefthand side of the colons) to some directory *in the container* (righthand side), so that you have your source files available for pandoc to convert.
  `pwd` is quoted to protect against spaces in filenames.
  
  `--workdir`, just to keep things easy, sets the working directory *inside* your container to the directory you just mapped to.
    If `pwd` doesn't work for you, you can also specify absolute paths either side of the colons.
  
  `pandoc/latex:2.6` declares the image that you're going to run.
  It's always a good idea to hardcode the version, lest future releases break your code.
  
  It may look weird to you that you can just add `README.md` at the end of this line, but that's just because the `pandoc/latex:2.6` will simply prepend `pandoc` in front of anything you write after `pandoc/latex:2.6` (this is known as the `ENTRYPOINT` field of the Dockerfile).
  So what you're really running here is `pandoc README.md`, which is a valid pandoc command.
  
  If you don't have the current docker image on your computer yet, the downloading and unpacking is going to take a while.
  It'll be (much) faster the next time.
  You don't have to worry about where/how Docker keeps these images.


Pandoc Scripts
--------------------------------------------------------------------------------

Pandoc commands have a way of getting pretty long, and so typing them into the command line can get a little unwieldy.
To get a better handle of long pandoc commands, you can store them in a script file, a simple text file with an `*.sh` extension such as

```
#!/bin/sh
pandoc README.md
```

The first line, known as the [*shebang*](https://stackoverflow.com/questions/7366775/what-does-the-line-bin-sh-mean-in-a-unix-shell-script) tells the container that the following commands are to be executed as shell commands.
In our case, we really don't use a lot of shell magic, we just call pandoc in the second line (though you can get fancier, if you like).
Notice that the `#!/bin/sh` will *not* get you a full bash shell, but only the more basic ash shell that comes with Alpine linux on which the pandoc containers are based. 
This won't matter for most uses, but if you want to write writing more complicated scripts you may want to refer to the [`ash` manual](https://linux.die.net/man/1/ash).

Once you have stored this script, you must make it executable by running the following command on it (this may apply only to UNIX-type systems):

```
chmod +x script.sh 
```

You only have to do this once for each script file.

You can then run the completed script file in a pandoc docker container like so:

```
docker run --volume "`pwd`":"`pwd`" --workdir "`pwd`" --entrypoint "`pwd`"/script.sh pandoc/latex:2.6
```

Notice that the above `script.sh` *did* specify `pandoc`, and you can't just omit it as in the simpler command above.
This is because the `--entrypoint` flag *overrides* the `ENTRYPOINT` field in the docker file (`pandoc`, in our case), so you must include the command.


GitHub actions
--------------------------------------------------------------------------------

By encapsulating the compute environment, Docker can make it easier to run dependency-heavy software on your local machine, but it was designed to run in the cloud.

Continuous integration and delivery (CI/CD) is a cloud service that may be useful for many pandoc users.
Perhaps, you're using pandoc convert some markdown source document into HTML and deploy the results to a webserver.
If the source document is under version control (such as git), you might want pandoc to convert and deploy *on every commit*.
That is what CI/CD does.

You can use the above docker images on any number of CI/CD services; many will accept arbitrary docker container.

GitHub actions is a relatively new workflow automation feature from the popular git host GitHub.
Docker containers are especially easy to use on GitHub actions.

GitHub actions can also be packaged, published and reused as "plug-and-play" workflows.
There is already a [pandoc GitHub action](https://github.com/maxheld83/pandoc) that lets you use the pandoc docker images inside of GitHub actions.


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

License
================================================================================

Code in this repository is licensed under the
[GNU General Public License Version 2](LICENSE).
