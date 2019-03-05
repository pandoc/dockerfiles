# Usage

Docker images are pre-provisioned computing environments, similar to virtual machines, but smaller and cleverer.
You can use these images to convert document wherever you can run docker images, without having to worry about pandoc or its dependencies.
The images bring along everything they need to get the job done.

**Contents**

- [Basic Usage](#basic-usage)
- [Pandoc Scripts](#pandoc-scripts)
- [GitHub Action](#github-action)


## Basic Usage

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

  Let's say you have a `README.md` in your workding directory that you'd like to convert to HTML.
  
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


## Pandoc Scripts

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


## GitHub actions

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
