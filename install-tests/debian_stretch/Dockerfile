# using the latest recommended version
FROM debian:stretch
USER root

RUN apt-get update ;\
    apt-get install -y --no-install-recommends git cmake ninja-build \
            software-properties-common gpg-agent gnupg lsb-release wget

WORKDIR /build

COPY tmp/* /build/
RUN /build/llvm.sh
RUN /build/get_proj.sh

CMD /build/build.sh 8

