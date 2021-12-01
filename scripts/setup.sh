#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

LLVM_11_ARCHIVE_LINK=https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/llvm-project-11.0.0.tar.xz
LLVM_11_ARCHIVE_PATH=/home/vagrant/download/llvm-project-11.0.0.tar.xz
LLVM_11_ARCHIVE_SHA1SUM=3c88390b19ac6779c8d9c89256892d690903412b

# Download LLVM's source code if necessary
if [[ ! -f $LLVM_11_ARCHIVE_PATH ]] && [[ $(sha1sum $LLVM_11_ARCHIVE_PATH) != $LLVM_11_ARCHIVE_SHA1SUM ]]
then
    echo -e "${GREEN}Downloading LLVM-11 to $LLVM_11_ARCHIVE_PATH ...${NC}"
    wget $LLVM_11_ARCHIVE_LINK -O $LLVM_11_ARCHIVE_PATH
fi

# Uncompress LLVM's source code
echo -e "${GREEN}Uncompressing LLVM ${NC}"
cp download/llvm-project-11.0.0.tar.xz .
tar -xJvf llvm-project-11.0.0.tar.xz

# Build LLVM
LLVM_SRC_DIR=/home/vagrant/llvm-project-11.0.0
LLVM_INSTALL_DIR=/home/vagrant/llvm-11
echo -e "${GREEN}Building LLVM ${NC}"
mkdir -p $LLVM_SRC_DIR/build
cd $LLVM_SRC_DIR/build
# LLVM will be installed into ${LLVM_INSTALL_DIR} in Release mode
cmake -G 'Ninja' -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;compiler-rt;libunwind;lld;lldb;polly;debuginfo-tests' -DCMAKE_INSTALL_PREFIX=$LLVM_INSTALL_DIR -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=`which python3` ../llvm
ninja -j16
ninja install
export PATH=$LLVM_INSTALL_DIR/bin:$PATH

echo -e "${GREEN}Building LLVM libcxxabi with DFSAN${NC}"
mkdir -p $LLVM_SRC_DIR/build-libcxxabi
cd $LLVM_SRC_DIR/build-libcxxabi
CC=clang CXX=clang++ cmake -G "Ninja" -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=$LLVM_INSTALL_DIR -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_FLAGS=-fsanitize=dataflow -DCMAKE_CXX_FLAGS=-fsanitize=dataflow -DLLVM_PATH=$LLVM_SRC_DIR -DLIBCXXABI_ENABLE_SHARED=NO -DLIBCXXABI_LIBCXX_PATH=../libcxx ../libcxxabi
ninja
ninja install

echo -e "${GREEN}Building LLVM libcxx with DFSAN${NC}"
mkdir -p $LLVM_SRC_DIR/build-libcxx
cd $LLVM_SRC_DIR/build-libcxx
CC=clang CXX=clang++ cmake -G "Ninja" -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=$LLVM_INSTALL_DIR -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_FLAGS=-fsanitize=dataflow -DCMAKE_CXX_FLAGS=-fsanitize=dataflow -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_CXX_ABI=libcxxabi -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON -DLIBCXX_CXX_ABI_INCLUDE_PATHS=../libcxxabi/include/ -DLIBCXX_CXX_ABI_LIBRARY_PATH=../build-libcxxabi/lib/ ../libcxx
ninja
ninja install

cd /home/vagrant
rm -f llvm-project-11.0.0.tar.xz
rm -rf $LLVM_SRC_DIR

echo -e "${GREEN}Setup done. ${NC}"
