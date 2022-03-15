#!/bin/bash
set -e

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(dirname $1):/system/lib64

echo $@

if [ $(basename $1) == "constgen" ]; then
  /usr/bin/qemu-aarch64 -L /usr/local/lib/android-ndk-r23b/toolchains/llvm/prebuilt/linux-x86_64/sysroot $@
else
  $@
fi
