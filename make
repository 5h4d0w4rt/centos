#!/bin/bash
set -eu

function usage(){ echo "Usage: $(basename $0) <build|build-no-cache|test|push> [tag = current branch] [message]" && exit 1; }
[ $# -lt 1 ] && usage;

repo=dodopizza/centos
current_branch=$( git branch | grep \* | cut -d ' ' -f2 )

action=${1:-'build'}
tag=${2:-${current_branch}}
message=${1:-"${tag}"}

echo "[~] Tag '${tag}'"

case "${action}" in
    build )
        DOCKER_BUILDKIT=1 docker build --rm \
          --progress=plain \
          --build-arg BUILDKIT_INLINE_CACHE=1 \
          --cache-from ${repo}:${tag} \
          --tag ${repo}:${tag} \
          .
        ;;
    build-no-cache )
        DOCKER_BUILDKIT=1 docker build --rm \
          --progress=plain \
          --no-cache \
          --tag ${repo}:${tag} \
          .
        ;;
    push )
        docker push ${repo}:${tag}
        ;;
    test )
        docker run -it --rm ${repo}:${tag}
        ;;
    * )
        usage
        ;;
esac

echo "[.] All Done"