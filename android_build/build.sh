#!/bin/bash
set -e

cd $(dirname $0)/..

SDK=28

if [ -z "$ARCH" ]; then
  echo "ARCH not set"
  exit 1
elif [ "$ARCH" == "aarch64" ]; then
  ANDROID_ABI=arm64-v8a
  export COMPILER=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$SDK-clang
elif [ "$ARCH" == "x86-64" ]; then
  ANDROID_ABI=x86_64
  export COMPILER=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android$SDK-clang
else
  echo "Unknown/Unsupported ARCH $ARCH"
  exit 1
fi

if [ -z "$NDK" ]; then
  echo "NDK not set"
  exit 1
fi

if [ -z "$JRE_VERSION" ]; then
  echo "JRE_VERSION not set"
  exit 1
fi

# Init submodules
git submodule init
git submodule update

# Build and install OMR for the host
cd runtime/omr
cmake -B native_build
cmake --build native_build -j$(nproc)
sudo cmake --install native_build
cd ../..

# Create stub libs
sudo mkdir -p $NDK/toolchains/llvm/prebuilt/linux-x86_64/{aarch64-linux-android,x86_64-linux-android}/lib
sudo chown -R $(id -u):$(id -g) $NDK/toolchains/llvm/prebuilt/linux-x86_64/*/lib
ar cr $NDK/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/lib/libpthread.a
ar cr $NDK/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/lib/librt.a
ar cr $NDK/toolchains/llvm/prebuilt/linux-x86_64/x86_64-linux-android/lib/libpthread.a
ar cr $NDK/toolchains/llvm/prebuilt/linux-x86_64/x86_64-linux-android/lib/librt.a

# Configure
cmake -B build \
  -C runtime/cmake/caches/linux_$ARCH.cmake \
  -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=$ANDROID_ABI \
  -DANDROID_PLATFORM=$SDK \
  -DCMAKE_MODULE_PATH=runtime/omr/cmake/modules \
  -DOMR_GC_LIB=omrgc \
  -DOMR_PORT_NUMA_SUPPORT=NO \
  -DOMR_SEMAPHORE_IMPLEMENTATION=posix \
  -DBOOT_JDK=/usr/lib/jvm/java-$JRE_VERSION-openjdk-amd64 \
  -DJAVA_SPEC_VERSION=$JRE_VERSION \
  -DOMR_EXE_LAUNCHER="$PWD/android_build/exelauncher.sh"

# Generate the config file
bash android_build/gen_version_info.sh

# Build
cmake --build build -j$(nproc)
