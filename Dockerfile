FROM registry.k8s.pwagner.net/library/debian-bullseye:latest@sha256:1d0b6f81868d364ebb9cc3f8596552cd6acb2c9018deca459348dfd524b8e1fb AS builder

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
