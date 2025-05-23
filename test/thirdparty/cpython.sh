#!/bin/bash
repo='git@github.com:python/cpython.git'
. test/thirdparty/common
git reset --hard c75330605d4795850ec74fdc4d69aa5d92f76c00

# Python's './configure' command misidentifies smart as icc
# (Intel C Compiler) because icc is a substring of smart.
# Modify the configure file as a workaround.
sed -i -e 1996,2011d configure.ac
autoreconf

CC=$smart ./configure
$make clean
$make
$make test
