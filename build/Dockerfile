#
# Builder image
FROM registry.suse.com/bci/golang:1.22 AS builder

ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Build controller
COPY . /src
WORKDIR /src
RUN make

#
# base image
FROM registry.suse.com/bci/bci-micro:15.6 AS micro
FROM registry.suse.com/bci/bci-base:15.6 AS base

ARG TARGETOS
ARG TARGETARCH

COPY --from=micro / /chroot/

# Runtime dependencies
RUN zypper --non-interactive --installroot /chroot --gpg-auto-import-keys install --no-recommends \
    ca-certificates && \
    zypper --non-interactive --installroot /chroot clean -a && \
    rm -rf /chroot/var/log/

RUN cd /chroot/usr/bin/ && rm -rf basename chcon chgrp chmod chown chroot cksum dd df dircolors dirname du install install-info join locale localedef mkdir mkfifo mknod mktemp paste pathchk readlink realpath sync smidiff smidump smilink smiquery smistrip smixlate tee tiemout tload top truncate unlink watch

FROM micro
ARG VERSION
ARG COMMIT
WORKDIR /
COPY --from=base /chroot/ /
COPY --from=builder /src/stage /

LABEL "name"="registry-adapter" \
      "vendor"="SUSE Security" \
      "neuvector.image"="neuvector/registry-adapter" \
      "neuvector.role"="registry-adapater" \
      "neuvector.rev"="${COMMIT}" \
      "io.artifacthub.package.logo-url"=https://avatars2.githubusercontent.com/u/19367275 \
      "io.artifacthub.package.readme-url"="https://raw.githubusercontent.com/neuvector/neuvector/${VERSION}/README.md" \
      "org.opencontainers.image.description"="SUSE Security Registry Adapter" \
      "org.opencontainers.image.title"="SUSE Security Registry Adapter" \
      "org.opencontainers.image.source"="https://github.com/neuvector/registry-adapter/" \
      "org.opencontainers.image.version"="${VERSION}" \
      "org.opensuse.reference"="neuvector/registry-adapter:${VERSION}"
      

ENTRYPOINT ["/usr/local/bin/adapter"]
