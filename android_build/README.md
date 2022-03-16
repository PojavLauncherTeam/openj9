# Android build

## Configuring and building
Note that the minimum API is 28 (Android 9) for now.
```shell
cd openj9

# Set architecture. One of aarch64, x86-64
export ARCH=aarch64

# Set NDK version. One of 8, 11, 17 (?)
export JRE_VERSION=8

# Set NDK path. Below is an example
export NDK=/usr/local/lib/android-ndk-r23b

# Configure and build OMR and OpenJ9
bash android_build/build.sh
```

## Constructing the Java 8 Runtime
These below will be moved to a script later
```shell
SRC=/path/to/openj9/build/runtime
DST=/path/to/jre8-android
LIBPATH=$(dirname $(find $DST -name jvm.cfg))

cp $SRC/java*.properties $LIBPATH/
cp $SRC/libomrsig.so $SRC/libcuda4j29.so $SRC/libj*9*.so $LIBPATH/

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
