#!/bin/bash

WORK_DIR=$(pwd)
SOURCE_DIR=$1
#DATE_STR=$(date +%Y%m%d)
DATE_STR="20150317"
BUILD_NUM="Build009"
ISO_NAME="Fedora19-Desktop-Loongson-Release-${BUILD_NUM}-${DATE_STR}.iso"

mkisofs -relaxed-filenames -allow-lowercase -graft-points -allow-multidot -pad -r -l -J -d -v -V "f19_${BUILD_NUM}" -hide-rr-moved -o  ${WORK_DIR}/${ISO_NAME} ${SOURCE_DIR}
