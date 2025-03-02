# helper script used in the test suite

build_run(){
  # helper function to create and docker containers for the different
  # distros

  DISTRO=$1
  LLVM_VERSION=$2
  IMAGE=clangtest/${DISTRO}_llvm-${LLVM_VERSION}

  # copy files to temp dir
  if [ -d tmp ] ; then
    rm -r tmp
  fi
  mkdir -p tmp
  cp ../llvm.sh test_installation.sh tmp
  cp -r sample_project tmp

  # build the docker image from the distro folder
  docker build -t $IMAGE --build-arg llvm_version=$LLVM_VERSION --build-arg distro=$DISTRO .

  # run a build in the image (non-detached to see output directly)
  docker run --rm $IMAGE

  # Clean up after each test instead of at the end
  docker image rm -f $IMAGE
  rm -rf tmp
  docker stop $(docker ps -q) || true
  docker rm $(docker ps -aq) || true
  docker system prune -af --volumes
}
