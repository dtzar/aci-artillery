#!/bin/sh

set -e
set -o pipefail

./node_modules/artillery/bin/artillery run -o /aci/reports/$CONTAINER_NAME-report.json /aci/artillery-config/load.yml
