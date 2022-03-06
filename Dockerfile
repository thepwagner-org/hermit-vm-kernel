FROM registry.k8s.pwagner.net/library/debian-bullseye:latest@sha256:eb167b5a9b4bfeb37bb9fa5b09371c4513e67fe7e2818c5ba2adeb1f03949e75 AS sources

# Get build dependencies
RUN echo "deb-src http://debian.mirror.rafal.ca/debian bullseye main" >> /etc/apt/sources.list && \
  echo "deb-src http://debian.mirror.rafal.ca/debian-security bullseye-security main" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    build-essential \
    fakeroot \
    libncurses-dev \
    && \
  apt-get build-dep -y linux
# leave apt-list for the apt-get source step

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
FROM sources AS builder
RUN make -j"$(nproc)" vmlinux
USER root
RUN mv vmlinux /
USER nobody

FROM scratch
COPY --from=builder /vmlinux /
