FROM registry.k8s.pwagner.net/library/debian-bullseye:latest@sha256:0c0b5926a0150ad17028a45cb07ac2c574778cbefbde671d67597a21ed0c3f8d AS builder

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
