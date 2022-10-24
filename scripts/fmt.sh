#!/bin/bash

set -e
set -u

CURFILE=$( readlink -f $0 )
CURDIR=${CURFILE%/*}
. ${CURDIR}/lib.sh



cargo fmt
cargo clippy --profile ${PROFILE}
