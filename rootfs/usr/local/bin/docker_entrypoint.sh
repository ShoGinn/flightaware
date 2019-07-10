#!/bin/sh

set -o errexit          # Exit on most errors (see the manual)
#set -o errtrace         # Make sure any error trap is inherited
#set -o nounset          # Disallow expansion of unset variables
#set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)


echo "Waiting for dump1090 to start up"
sleep 5s

echo
echo "FLIGHTAWARE_FEEDER_ID=${FLIGHTAWARE_FEEDER_ID}"
echo "FLIGHTAWARE_GPS_HOST=${FLIGHTAWARE_GPS_HOST}"
echo

touch /etc/piaware.conf
piaware-config "receiver-type" "other"
piaware-config "receiver-host" "dump1090"
piaware-config "receiver-port" "30005"
piaware-config "allow-auto-updates" "no"
piaware-config "allow-manual-updates" "no"
piaware-config "allow-mlat" "yes"
piaware-config "mlat-results" "yes"
piaware-config "mlat-results-format" "beast,listen,30105"
 

if [ -z "${FLIGHTAWARE_FEEDER_ID}" ]; then
    echo "No FLIGHTAWARE_FEEDER_ID set"
else
    piaware-config "feeder-id" "${FLIGHTAWARE_FEEDER_ID}"
fi

if [ -n "${FLIGHTAWARE_GPS_HOST}" ]; then
    echo "GPS_HOST specified, forwarding port 2947 to ${FLIGHTAWARE_GPS_HOST}"
    /usr/bin/socat -s TCP-LISTEN:2947,fork TCP:${FLIGHTAWARE_GPS_HOST}:2947 &
fi
# Fix issue with fa-mlat-client
# The fa-mlat-client is run as "nobody" with most permissions dropped.
# This causes issues with extracting to ~/.shiv (the default) so use /tmp instead.
export SHIV_ROOT='/tmp'

exec piaware -plainlog

exit ${?}
