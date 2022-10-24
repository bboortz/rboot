#!/bin/bash


set -e
set -u

CURFILE=$( readlink -f $0 )
CURDIR=${CURFILE%/*}
. ${CURDIR}/lib.sh



if [ -n "${CODECOV_TOKEN}" ]; then
  export LLVM_PROFILE_FILE="target/${OUTPUT_PROFILE}/prof/rusterella-%p-%m.profraw"
  export RUSTFLAGS="-Zprofile -Ccodegen-units=1 -Cinline-threshold=0 -Clink-dead-code -Coverflow-checks=off -Cpanic=abort -Zpanic_abort_tests -Cinstrument-coverage "
  export RUSTDOCFLAGS="-Zprofile -Ccodegen-units=1 -Cinline-threshold=0 -Clink-dead-code -Coverflow-checks=off -Cpanic=abort -Zpanic_abort_tests -Cinstrument-coverage"
  PROFILE=test
fi


cargo build --profile ${PROFILE}
cargo test --profile ${PROFILE} -- --nocapture
if [ ! -f "${RUST_TARGET_FILE}" ]; then
  echo "ERROR: target file missing: ${RUST_TARGET_FILE}"
  exit 1
fi
du -sh ${RUST_TARGET_FILE}


if [ -n "${CODECOV_TOKEN}" ]; then
  if [ ! -f ./temp/grcov ]; then
    mkdir -p temp
    cd temp
    curl -L https://github.com/mozilla/grcov/releases/download/v0.8.11/grcov-x86_64-unknown-linux-gnu.tar.bz2 | tar jxf -
    cd -
  fi

  zip target/${OUTPUT_PROFILE}/prof/${PROJECT_NAME}.zip target/${OUTPUT_PROFILE}/prof/*.profraw
  du -sh target/${OUTPUT_PROFILE}/prof/${PROJECT_NAME}.zip

  ./temp/grcov . -s ./ --binary-path target/${OUTPUT_PROFILE} --llvm --branch --ignore-not-existing --ignore "/*" -t html -o target/${OUTPUT_PROFILE}/coverage
  ./temp/grcov . -s ./ --binary-path target/${OUTPUT_PROFILE} --llvm --branch --ignore-not-existing --ignore "/*" --token "${CODECOV_TOKEN}" -t coveralls -o target/${OUTPUT_PROFILE}/codecov.json
  du -sh target/${OUTPUT_PROFILE}/codecov.json

  bash <(curl -s https://codecov.io/bash) -f target/${OUTPUT_PROFILE}/codecov.json

  # ./temp/grcov target/prof/rusterella.zip -s ./ -t html --llvm --branch --ignore-not-existing --ignore "/*" -o target/coverage -b target/debug
  # ./temp/grcov . -s ./ --binary-path target/debug --llvm --branch --ignore-not-existing --ignore "/*" --token "${CODACY_TOKEN}" -t lcov -o target/codacy.json
  # bash <(curl -Ls https://coverage.codacy.com/get.sh) report -r target/codacy.json
fi
