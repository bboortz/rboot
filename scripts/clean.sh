#!/bin/bash

set -e
set -u 

CURFILE=$( readlink -f $0 )
CURDIR=${CURFILE%/*}
. ${CURDIR}/lib.sh


cargo c 2>&1 | awk -F '/' '/^package:/ { print $7 }' | while read f; do
  cd $f
  make clean
  cd -
done

cargo clean
rm -rf ./temp

