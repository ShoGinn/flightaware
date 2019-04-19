ARG BASE=debian:stretch-slim
# base ########################################################################
FROM $BASE as base

ARG arch=none
ENV ARCH=$arch

COPY qemu/qemu-$ARCH-static* /usr/bin/

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl ca-certificates \
        net-tools iproute2 \
        tclx8.4 tcl8.6 tcllib tcl-tls itcl3 \
        python3 \
        procps && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# builder ########################################################################
FROM base as builder

ARG PIAWARE_VERSION=3.7.0.1
ARG PIAWARE_HASH=4af91aefaafa5ae32132e3198bd0b59ec87de170cf2b142fe1203f3762d1b78b

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
  DEBIAN_FRONTEND=noninteractive apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN curl -L --output 'piaware_builder.tar.gz' "https://github.com/flightaware/piaware_builder/archive/v${PIAWARE_VERSION}.tar.gz" && \
  sha256sum piaware_builder.tar.gz && echo "${PIAWARE_HASH} piaware_builder.tar.gz" | sha256sum -c

RUN mkdir piaware_builder && cd piaware_builder && \
  tar -xvf ../piaware_builder.tar.gz --strip-components=1

RUN ./sensible-build.sh stretch && \
  cd package-stretch

RUN dpkg-buildpackage -b

RUN dpkg -i ../piaware*.deb

# final image #################################################################
FROM base

COPY --from=builder /usr/lib/Tcllauncher1.8 /usr/lib/Tcllauncher1.8

COPY --from=builder /usr/bin/piaware /usr/bin/piaware
COPY --from=builder /usr/lib/piaware /usr/lib/piaware

COPY --from=builder /usr/bin/piaware-config /usr/bin/piaware-config
COPY --from=builder /usr/lib/piaware-config /usr/lib/piaware-config

COPY --from=builder /usr/bin/piaware-status /usr/bin/piaware-status
COPY --from=builder /usr/lib/piaware-status /usr/lib/piaware-status

COPY --from=builder /usr/lib/piaware_packages /usr/lib/piaware_packages
COPY --from=builder /usr/lib/fa_adept_codec /usr/lib/fa_adept_codec

COPY piaware.conf /etc/piaware.conf
COPY piaware-runner.sh /usr/bin/piaware-runner

EXPOSE 30105/tcp

ENTRYPOINT ["piaware-runner"]

# Metadata
ARG VCS_REF="Unknown"
LABEL maintainer="ginnserv@gmail.com" \
      org.label-schema.name="Docker ADS-B - flightaware" \
      org.label-schema.description="Docker container for ADS-B - This is the flightaware.com component" \
      org.label-schema.url="https://github.com/ShoGinn/flightaware" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/ShoGinn/flightaware" \
      org.label-schema.schema-version="1.0"
