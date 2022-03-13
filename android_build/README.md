# Android build
## Configuring and building
Note that the minimum API is 28 (Android 9) for now.

This is still under construction and is unfinished!
```shell
cd openj9

# Clone the OMR repository (https://github.com/khanhduytran0/omr) into runtime/omr
# git clone ...

# Note: change JAVA_SPEC_VERSION=17 incase building for Java 17
cmake -B build -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=28 -DCMAKE_MODULE_PATH=runtime/omr/cmake/modules -DOMR_GC_LIB=omrgc -DOMR_SEMAPHORE_IMPLEMENTATION=posix -DBOOT_JDK=/usr/lib/jvm/jdk8u322-b06 -DJAVA_SPEC_VERSION=8 -DJ9VM_ARCH_AARCH64=1 -DOMR_ARCH_AARCH64=1 -C runtime/cmake/caches/linux_aarch64.cmake -DJ9JIT_EXTRA_CFLAGS="-DOMR_GC_REALTIME" -DJ9JIT_EXTRA_CXXFLAGS="-DOMR_GC_REALTIME"

# Hack: constgen cross-compile, unfinised!
# cp ../runtime_jligen_CMakeFiles_run_constgen.dir_build.make build/runtime/jilgen/CMakeFiles/run_constgen.dir/build.make

# Manually generate openj9_version_info.h
COMPILER=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android28-clang JRE_VERSION=8 bash gen_version_info.sh

# Build
make -C build -j$(nproc)
```

## Constructing the Java 8 Runtime
```shell
SRC=/path/to/openj9/build/runtime
DST=/path/to/jre8-android
LIBPATH=$(dirname $(find $DST -name jvm.cfg))

cp $SRC/java*.properties $LIBPATH/
cp $SRC/build/libomrsig.so $SRC/build/libj*9*.so $LIBPATH/

# Add j9vm
mkdir $LIBPATH/j9vm
cp $SRC/libjsig.so $SRC/libjvm.so $LIBPATH/j9vm/
echo "-j9vm KNOWN" >> $LIBPATH/jvm.cfg

# Download necessary file
wget -O $LIBPATH/../classlib.properties https://raw.githubusercontent.com/ibmruntimes/openj9-openjdk-jdk8/openj9/closed/classlib.properties

# should be?
rm -rf $LIBPATH/server
cp -R $LIBPATH/j9vm $LIBPATH/server
```

## Constructing the Java 17 Runtime
Coming soon
