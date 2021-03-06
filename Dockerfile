FROM ubuntu:20.04 as builder

ARG VERSION=master

# dependenciess
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    golang-go \
    git \
    unzip \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    make \
    qemu-kvm

RUN GOPATH=~/go &&\
    GOCACHE=/tmp/cache &&\
    go get github.com/linuxkit/linuxkit/src/cmd/linuxkit &&\
    cd $GOPATH/src/github.com/linuxkit/linuxkit &&\
    git checkout ${VERSION} &&\
    make local-build

FROM ubuntu:20.04

RUN apt-get update && apt-get install -y qemu-kvm

COPY --from=builder /root/go/src/github.com/linuxkit/linuxkit/bin/linuxkit /usr/local/bin/
RUN chmod +x /usr/local/bin/linuxkit

ENTRYPOINT ["/usr/local/bin/linuxkit"]
