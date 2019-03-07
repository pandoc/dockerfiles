#!/usr/bin/env bash

# Make sure we can execute `make` directly.
if ! [[ -f Makefile ]]; then
    echo "This must be run from the root of the repository." >&2
    exit 1
fi

# CI builds specify the target to build.
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <make target>" >& 2
    exit 1
fi
target="$1"

# Bypass enabled, see .circleci/config.yml latex_target.
if [[ "$target" == "nonexistent" ]]; then
    echo "Target was 'nonexistent', exiting early without failure."
    exit 0
fi

# Get the version tag to build for this commit message.
this_file_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
version_script="$this_file_dir/version_for_commit_message.sh"
if ! [[ -x "$version_script" ]]; then
   echo "CRITICAL: $version_script was not found..." >&2
   exit 1
fi
version="$("$version_script")"

# Build the docker image.  Make script exit with valid code (stop CI if fail).
PANDOC_VERSION="$version" make "$target" || exit 1

# Display the docker images for being able to review CI logs.
echo 'docker images:'
docker images

# Only do `docker push` if this is a CI build from the master branch of the
# pandoc/dockerfiles repository.  Cannot just check git branch because users
# may open a Pull Request from a fork's master branch.
if [[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/master)" ]]; then
    # Setup the repository to upload to.  The alpine and alpine-latex targets
    # are special (the "core" images), and upload to a different repository.
    # All other repository names shadow the make target names.
    if [[ "$target" == "alpine" ]]; then
        repository="core"
    elif [[ "$target" == "alpine-latex" ]]; then
        repository="latex"
    else
        repository="$target"
    fi

    # Login and push docker image.
    (echo "$DOCKER_PASSWORD" | \
         docker login -u="$DOCKER_USERNAME" --password-stdin) || exit 1
    echo "Pushing docker image to 'pandoc/$repository:$version'"
    docker push "pandoc/$repository:$version" || exit 1

    # If this is a release=X.Y build, move the :latest tag.
    if [[ "$version" != "edge" ]]; then
        echo "Pushing docker image to 'pandoc/$repository:latest'"
        docker tag "pandoc/$repository:$version" "pandoc/$repository:latest" || exit 1
        docker push "pandoc/$repository:latest" || exit 1
    fi
fi
