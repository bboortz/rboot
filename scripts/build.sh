#!/bin/bash

set -e
set -u 

CURFILE=$( readlink -f $0 )
CURDIR=${CURFILE%/*}
. ${CURDIR}/lib.sh



cargo build --profile ${PROFILE} --target x86_64-unknown-linux-musl 
