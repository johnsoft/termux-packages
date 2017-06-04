#!/bin/bash

set -euo pipefail

main() {
    TERMUX_SCRIPTDIR=$(cd "$(dirname "$0")"; pwd)
    TERMUX_DEBDIR="$TERMUX_SCRIPTDIR/debs"

    for TERMUX_ARCH in aarch64 arm i686 x86_64; do
        build_python_zip
    done
}

build_python_zip() {
    ZIP_PREP_DIR=$(mktemp -d)
    local ZIP_FILENAME="$TERMUX_SCRIPTDIR/python_3.6.1_${TERMUX_ARCH}.zip"

    ./build-package.sh -a "$TERMUX_ARCH" python

    collect_deb python_3.6.1
    collect_deb libandroid-support_14
    collect_deb libutil_0.2
    collect_deb libffi_3.2.1-2
    collect_deb openssl_1.0.2l

    [[ -f "$ZIP_FILENAME" ]] && rm "$ZIP_FILENAME"
    pushd "$ZIP_PREP_DIR/usr" > /dev/null
    zip -qr "$ZIP_FILENAME" .
    popd > /dev/null

    rm -r "$ZIP_PREP_DIR"
}

collect_deb() {
    local DEB_NAME="$1"
    local TMP_DIR=$(mktemp -d)

    mkdir "$TMP_DIR/deb"
    pushd "$TMP_DIR/deb" > /dev/null
    ar x "$TERMUX_DEBDIR/${DEB_NAME}_${TERMUX_ARCH}.deb"
    popd > /dev/null

    mkdir "$TMP_DIR/data"
    tar xJf "$TMP_DIR/deb/data.tar.xz" -C "$TMP_DIR/data"
    rsync -a "$TMP_DIR/data/data/data/com.termux/files/" "$ZIP_PREP_DIR"

    rm -r "$TMP_DIR"
}

main
