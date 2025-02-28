ARG distro
FROM ${distro}

USER root

# install the required packages
RUN apt-get update ;\
    apt-get install -y --no-install-recommends lsb-release wget make gnupg ca-certificates; \
    DISTRO=$(lsb_release -sc) && \
    if [ "$DISTRO" != "trixie" ]; then \
        apt-get install -y --no-install-recommends software-properties-common; \
    fi

# copy all the scripts
COPY tmp/ /build/

# define which llvm version to use
ARG llvm_version
ENV llvm_version ${llvm_version}

# install llvm
RUN /build/llvm.sh ${llvm_version}

# run the newly installed clang compiler on the sample project
CMD /build/test_installation.sh ${llvm_version}

