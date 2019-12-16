# flightaware
Docker container for ADS-B - This is the flightaware.com component

This is part of a suite of applications that can be used if you have a dump1090 compatible device including:
* Any RTLSDR USB device
* Any network AVR or BEAST device
* Any serial AVR or BEAST device

# Container Requirements

This is a multi architecture build that supports arm (armhf/arm64) and amd64

You must first have a running setup for before using this container as it will not help you on initial setup (but it might)

# Container Setup

Env variables must be passed to the container containing the flightaware required items

### Defaults
* DUMP1090_SERVER=dump1090 -- default dns name (configurable)
* DUMP1090_PORT=30005 -- default port (configurable)
* Port 30105/tcp is exposed in case you need external inputs (but not a requirement)


### User Configured
Go to https://flightaware.com/adsb/piaware/claim
* FLIGHTAWARE_FEEDER_ID

#### Example docker run

```
docker run -d \
--restart unless-stopped \
--name='flightaware' \
-e FLIGHTAWARE_FEEDER_ID="39248d8383" \
shoginn/flightaware:latest-amd64

```
# Status
| branch | Status |
|--------|--------|
| master | [![Build Status](https://travis-ci.org/ShoGinn/flightaware.svg?branch=master)](https://travis-ci.org/ShoGinn/flightaware) |

| Arch | Size/Layers | Commit |
|------|-------------|--------|
[![](https://images.microbadger.com/badges/version/shoginn/flightaware:latest-arm.svg)](https://microbadger.com/images/shoginn/flightaware:latest-arm "Get your own version badge on microbadger.com") | [![](https://images.microbadger.com/badges/image/shoginn/flightaware:latest-arm.svg)](https://microbadger.com/images/shoginn/flightaware:latest-arm "Get your own image badge on microbadger.com") | [![](https://images.microbadger.com/badges/commit/shoginn/flightaware:latest-arm.svg)](https://microbadger.com/images/shoginn/flightaware:latest-arm "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/shoginn/flightaware:latest-arm64.svg)](https://microbadger.com/images/shoginn/flightaware:latest-arm64 "Get your own version badge on microbadger.com") | [![](https://images.microbadger.com/badges/image/shoginn/flightaware:latest-arm64.svg)](https://microbadger.com/images/shoginn/flightaware:latest-arm64 "Get your own image badge on microbadger.com") | [![](https://images.microbadger.com/badges/commit/shoginn/flightaware:latest-arm64.svg)](https://microbadger.com/images/shoginn/flightaware:latest-arm64 "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/shoginn/flightaware:latest-amd64.svg)](https://microbadger.com/images/shoginn/flightaware:latest-amd64 "Get your own version badge on microbadger.com") | [![](https://images.microbadger.com/badges/image/shoginn/flightaware:latest-amd64.svg)](https://microbadger.com/images/shoginn/flightaware:latest-amd64 "Get your own image badge on microbadger.com") | [![](https://images.microbadger.com/badges/commit/shoginn/flightaware:latest-amd64.svg)](https://microbadger.com/images/shoginn/flightaware:latest-amd64 "Get your own commit badge on microbadger.com")

