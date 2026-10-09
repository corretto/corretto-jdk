#!/usr/bin/env bash

set -xeuo pipefail

UPSTREAM_REMOTE=$1

# Load the current OpenJDK version
source make/conf/version-numbers.conf

# strip trailing zeroes: https://openjdk.org/jeps/322
ELEMENTS=("${DEFAULT_VERSION_FEATURE}" "${DEFAULT_VERSION_INTERIM}" "${DEFAULT_VERSION_UPDATE}" "${DEFAULT_VERSION_PATCH}")
LAST=${#ELEMENTS[@]}
while (( LAST > 1 )) && [[ "${ELEMENTS[$((LAST-1))]}" == "0" ]]; do
  ((LAST--))
done
VERSION_STR=$(IFS=.; echo "${ELEMENTS[*]:0:$LAST}")

BUILD_NUMBER=$(git ls-remote --tags ${UPSTREAM_REMOTE} |grep "jdk-${VERSION_STR}+" | grep -vE "(-ga|{})$" | cut -d+ -f 2 | sort -n | tail -1)

# Load the current Corretto version
CURRENT_VERSION=$(cat version.txt)
# version.txt format: FEATURE.INTERIM.UPDATE.PATCH.BUILD
CURRENT_PREFIX=$(echo "${CURRENT_VERSION}" | cut -d. -f1-4)
CURRENT_BUILD_NUMBER=$(echo "${CURRENT_VERSION}" | cut -d. -f5)

NEW_PREFIX="${DEFAULT_VERSION_FEATURE}.${DEFAULT_VERSION_INTERIM}.${DEFAULT_VERSION_UPDATE}.${DEFAULT_VERSION_PATCH}"

# When the preceding version numbers (feature.interim.update.patch) are unchanged,
# the build number must not go backwards. If it would, there is nothing to update.
# A changed prefix is a new version line, so this check is skipped.
if [[ "${CURRENT_PREFIX}" == "${NEW_PREFIX}" ]]; then
    if ! [[ "${BUILD_NUMBER:=0}" =~ ^[0-9]+$ ]]; then
        echo "Error: upstream BUILD_NUMBER '${BUILD_NUMBER}' is not a valid number." >&2
        exit 1
    fi
    if ! [[ "${CURRENT_BUILD_NUMBER:=0}" =~ ^[0-9]+$ ]]; then
        echo "Error: current build number '${CURRENT_BUILD_NUMBER}' from version.txt is not a valid number." >&2
        exit 1
    fi
    if (( BUILD_NUMBER < CURRENT_BUILD_NUMBER )); then
        echo "New build number (${BUILD_NUMBER}) is lower than the existing build number (${CURRENT_BUILD_NUMBER}) for version ${NEW_PREFIX}. Nothing to update."
        exit 0
    fi
fi

if [[ "${CURRENT_VERSION}" == "${NEW_PREFIX}.${BUILD_NUMBER:=0}" ]]; then
  echo "Corretto version is current."
else
  echo "Updating Corretto version"
  NEW_VERSION="${NEW_PREFIX}.${BUILD_NUMBER}"
  echo "${NEW_VERSION}" > version.txt
  git commit -m "Update Corretto version to match upstream: ${NEW_VERSION}" version.txt
fi
