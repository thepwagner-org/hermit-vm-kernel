FROM registry.k8s.pwagner.net/library/debian-bullseye:latest@sha256:1c5035cccb93409674494766f5c682558b89ae345a06b8417ac1c3f37c03cf18 AS builder

# Get build dependencies
RUN echo "deb-src http://debian.mirror.rafal.ca/debian bullseye main" >> /etc/apt/sources.list && \
  echo "deb-src http://debian.mirror.rafal.ca/debian-security bullseye-security main" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential fakeroot && \
  apt-get build-dep -y linux

# Drop privs
WORKDIR /build
RUN chown nobody /build
USER nobody

# Get and configure kernel sources
RUN apt-get source linux
WORKDIR /build/linux-5.10.70
COPY config .config
RUN make oldconfig

# Compile (grab a coffee)
RUN make -j$(nproc) vmlinux
USER root
RUN mv vmlinux /

FROM scratch
COPY --from=builder /vmlinux /