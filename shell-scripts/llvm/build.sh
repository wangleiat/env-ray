#!/bin/bash
set -e
set -x

if [ "X${1}" != X ]; then
  CONFIG_AND_BUILD=true
else
  CONFIG_AND_BUILD=false
fi

INSTALL_DIR="$PWD/llvm_install"
PROJ_DIR="llvm-project"

while $CONFIG_AND_BUILD ; do
  rm -rf build
  mkdir build
  break
done

cd build

while $CONFIG_AND_BUILD; do

  #cmake --log-level=VERBOSE --debug-output \
  cmake \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_BUILD_TYPE="Debug" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    \
       ../${PROJ_DIR}/llvm -G Ninja \
    \
    -DLLVM_TARGETS_TO_BUILD="Mips;ARM;AArch64;PowerPC;SystemZ;X86;Sparc" \
    -DLLVM_ENABLE_PROJECTS="clang" \
    \
    -DLLVM_INSTALL_UTILS=ON \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    \
    -DLLVM_INCLUDE_TOOLS=ON \
    -DLLVM_BUILD_TOOLS=ON \
    \
    -DLLVM_INCLUDE_UTILS=ON \
    -DLLVM_BUILD_UTILS=ON \
    \
    -DLLVM_INCLUDE_RUNTIMES=ON \
    -DLLVM_BUILD_RUNTIME=ON \
    \
    -DLLVM_INCLUDE_EXAMPLES=ON \
    -DLLVM_BUILD_EXAMPLES=OFF \
    \
    -DLLVM_INCLUDE_TESTS=ON \
    -DLLVM_BUILD_TESTS=OFF \
    \
    -DLLVM_INCLUDE_DOCS=ON \
    -DLLVM_BUILD_DOCS=OFF \
    -DLLVM_ENABLE_DOXYGEN=OFF \
    -DLLVM_ENABLE_SPHINX=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_ENABLE_BINDINGS=OFF \
    \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON \
    \
    -DLLVM_ENABLE_LIBCXX=OFF \
    -DLLVM_ENABLE_ZLIB=ON \
    -DLLVM_ENABLE_FFI=ON \
    -DLLVM_ENABLE_RTTI=ON \
    -DDEFAULT_SYSROOT="/home/sysroot/" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="mips64el-unknown-linux-gnu"

  break
done

ninja -v -j12

ninja -v install
