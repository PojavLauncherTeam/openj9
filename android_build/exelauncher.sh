#!/bin/bash
set -e

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(dirname $1):/system/lib64

echo $@

USE_UNCHROOT=0

if [ $(basename $1) == "constgen" ]; then
  if [ "$USE_UNCHROOT" == "1" ]; then
    sudo unchroot su 60000 bash -c "cd /data/linuxdeploy/home/android/openj9/runtime && LD_LIBRARY_PATH=/data/linuxdeploy/home/android/openj9/build/runtime ./../build/runtime/constgen"
  else
    /usr/bin/qemu-aarch64 -L /usr/local/lib/android-ndk-r23b/toolchains/llvm/prebuilt/linux-x86_64/sysroot $@
  fi
else
  $@
fi
