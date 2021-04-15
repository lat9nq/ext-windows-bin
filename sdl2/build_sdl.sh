#!/bin/bash

# This script is meant to make it easy to rebuild Boost using the linux-fresh
# yuzu-emu container. Re-purposed for building SDL2 with MinGW for Windows.

# Run this from within boost_[version] directory
# Downloaded source archive must come from https://www.libsdl.org/download-2.0.php

THIS=$(readlink -e $0)
ARCH=`uname -m`
HOST="${ARCH}-w64-mingw32"
TARGET="${ARCH}-windows"
BASE_NAME=`readlink -e $(pwd) | sed 's/.*\///g'`
ARCHIVE_NAME=${BASE_NAME}-${HOST}.tar.xz
XZ=$(which xz)
if [ -n "$(which pixz)" ]; then
    XZ=$(which pixz)
fi

mkdir -p build || true
cd build
../configure CC=${HOST}-gcc --host=${HOST} --build=${TARGET} --prefix=/
mkdir -p ${BASE_NAME}
make -j$(nproc) install DESTDIR=$(readlink -e ${BASE_NAME})
cp -v ../BUGS.txt \
      ../COPYING.txt \
      ../README.txt \
      ../README-SDL.txt \
      ../WhatsNew.txt \
      ${BASE_NAME}

cp -v ${THIS} ${BASE_NAME}/

cd ..

tar cv ${BASE_NAME} | ${XZ} -c > ${ARCHIVE_NAME}

if [ $# -eq 2 ]; then
    chown -R $1:$2 .
fi

if [ -e ${ARCHIVE_NAME} ]; then
    echo "Package can be found at $(readlink -e ${ARCHIVE_NAME})"
fi


