#!/bin/bash
cd $(dirname $0)/..

if [ -z "$COMPILER" ]; then
  echo "COMPILER is not set"
  exit 1
fi

COMPILER_VERSION_OUTPUT=$($COMPILER --version 2>&1)
# Collapse compiler output into a single line
COMPILER_VERSION_STRING=$(echo $COMPILER_VERSION_OUTPUT)

OPENJ9_SHA="$(git rev-parse --short HEAD)"
if [ -z "$OPENJ9_SHA" ]; then
  echo "Could not determine OpenJ9 SHA"
  exit 1
fi

# Find OpenJ9 tag associated with current commit (suppressing stderr in case there is no such tag).
OPENJ9_TAG="$(git describe --exact-match HEAD 2>/dev/null)"
if [ -z "$OPENJ9_TAG" ]; then
  OPENJ9_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [ -z "$OPENJ9_BRANCH" ]; then
    echo "Could not determine OpenJ9 branch"
    exit 1
  fi
  OPENJ9_VERSION_STRING="$OPENJ9_BRANCH-$OPENJ9_SHA"
else
  OPENJ9_VERSION_STRING="$OPENJ9_TAG"
fi

if [ -z "$JRE_VERSION" ]; then
  echo "JRE_VERSION is not set"
  exit 1
elif [ "$JRE_VERSION" == "8" ]; then
  JRE_RELEASE_VERSION="1.8.0-internal-b??"
else
  JRE_RELEASE_VERSION="$JRE_VERSION-internal-b??"
fi

cat > build/runtime/openj9_version_info.h << EOF
/*
 * ===========================================================================
 * (c) Copyright IBM Corp. 2017, 2020 All Rights Reserved
 * ===========================================================================
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
 *
 * IBM designates this particular file as subject to the "Classpath" exception
 * as provided by IBM in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, see <http://www.gnu.org/licenses/>.
 * ===========================================================================
 */

#ifndef OPENJ9_VERSION_INFO_H
#define OPENJ9_VERSION_INFO_H

#define J9COMPILER_VERSION_STRING "$COMPILER_VERSION_STRING"
#define J9PRODUCT_NAME            "OpenJDK"

#ifdef __LP64__
#define J9TARGET_CPU_BITS         "64"
#else
#define J9TARGET_CPU_BITS         "32"
#endif

#ifdef __aarch64__
#define J9TARGET_CPU_OSARCH       "aarch64"
#elif defined(__arm__)
#define J9TARGET_CPU_OSARCH       "arm"
#elif defined(__x86_64__)
#define J9TARGET_CPU_OSARCH       "amd64"
#elif defined(__i386__)
#define J9TARGET_CPU_OSARCH       "i686"
#else
# error Unspecified architecture
#endif

// TODO: Darwin iOS
#define J9TARGET_OS               "linux"
#define J9USERNAME                "PojavLauncherTeam"
#define J9VERSION_STRING          "$JRE_RELEASE_VERSION"
#define OPENJDK_SHA               "unknown" /* @OPENJDK_SHA@ */
#define OPENJDK_TAG               "unknown" /* @OPENJDK_TAG@ */
#define J9JVM_VERSION_STRING      "$OPENJ9_VERSION_STRING"
#define OPENJ9_TAG                "$OPENJ9_TAG"
#define J9JDK_EXT_VERSION         "8.0.?.?"
#define J9JDK_EXT_NAME            "Extensions for OpenJDK for Eclipse OpenJ9"
#define JAVA_VENDOR               "Eclipse OpenJ9"
#define JAVA_VENDOR_URL           "http://www.eclipse.org/openj9"

#endif /* OPENJ9_VERSION_INFO_H */
EOF
