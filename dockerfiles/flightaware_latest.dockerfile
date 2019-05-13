# base ########################################################################
FROM --platform=$TARGETPLATFORM debian:stretch-slim as base

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl ca-certificates \
        net-tools iproute2 \
        tclx8.4 tcl8.6 tcllib tcl-tls itcl3 \
        python3 \
        procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# builder ########################################################################
FROM base as builder

ARG PIAWARE_VERSION=3.7.1
ARG PIAWARE_HASH=02057b0cfa07c133f3eae54bbeccf34125c941014bf2d17458e12a5fe27b0b69

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  libboost-system-dev \
  libboost-program-options-dev \
  libboost-regex-dev \
  libboost-filesystem-dev \
  git \
  wget \
  build-essential \
  debhelper \
  tcl8.6-dev \
  autoconf \
  python3-dev \
  python3-venv \
  dh-systemd \
  libz-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN curl -L --output 'piaware_builder.tar.gz' "https://github.com/flightaware/piaware_builder/archive/v${PIAWARE_VERSION}.tar.gz" && \
  sha256sum piaware_builder.tar.gz && echo "${PIAWARE_HASH} piaware_builder.tar.gz" | sha256sum -c

WORKDIR piaware_builder
RUN tar -xvf ../piaware_builder.tar.gz --strip-components=1

RUN ./sensible-build.sh stretch

RUN cd package-stretch && dpkg-buildpackage -b

RUN dpkg -i piaware*.deb

# final image #################################################################
FROM base

COPY rootfs /

COPY --from=builder /usr/lib/Tcllauncher1.8 /usr/lib/Tcllauncher1.8

COPY --from=builder /usr/bin/piaware /usr/bin/piaware
COPY --from=builder /usr/lib/piaware /usr/lib/piaware

COPY --from=builder /usr/bin/piaware-config /usr/bin/piaware-config
COPY --from=builder /usr/lib/piaware-config /usr/lib/piaware-config

COPY --from=builder /usr/bin/piaware-status /usr/bin/piaware-status
COPY --from=builder /usr/lib/piaware-status /usr/lib/piaware-status

COPY --from=builder /usr/lib/piaware_packages /usr/lib/piaware_packages
COPY --from=builder /usr/lib/fa_adept_codec /usr/lib/fa_adept_codec

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
