#!/bin/bash

set -x

UPSTREAM_REMOTE=$1

# Load the current OpenJDK version
source make/conf/version-numbers.conf

if [[ "${DEFAULT_VERSION_UPDATE}" == "0" ]]; then
    BUILD_NUMBER=$(git ls-remote --tags ${UPSTREAM_REMOTE} |grep jdk-${DEFAULT_VERSION_FEATURE}+ | grep -vE "(-ga|{})$" | cut -d+ -f 2 |sort -n |tail -1)
else
    BUILD_NUMBER=$(git ls-remote --tags ${UPSTREAM_REMOTE} |grep jdk-${DEFAULT_VERSION_FEATURE}.${DEFAULT_VERSION_INTERIM}.${DEFAULT_VERSION_UPDATE} | grep -vE "(-ga|{})$" | cut -d+ -f 2 |sort -n |tail -1)
fi

# Load the current Corretto version
CURRENT_VERSION=$(cat version.txt)
CURRENT_PREFIX=$(echo "${CURRENT_VERSION}" | cut -d. -f1-3)
CURRENT_BUILD_NUMBER=$(echo "${CURRENT_VERSION}" | cut -d. -f4)

NEW_PREFIX="${DEFAULT_VERSION_FEATURE}.${DEFAULT_VERSION_INTERIM}.${DEFAULT_VERSION_UPDATE}"

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
        echo "Error: new build number (${BUILD_NUMBER}) is lower than the existing build number (${CURRENT_BUILD_NUMBER}) for version ${NEW_PREFIX}. Refusing to update." >&2
        exit 1
    fi
fi

if [[ ${CURRENT_VERSION} == ${NEW_PREFIX}.${BUILD_NUMBER:=0}.* ]]; then
    echo "Corretto version is current."
else
    echo "Updating Corretto version"
    NEW_VERSION="${NEW_PREFIX}.${BUILD_NUMBER}.1"
    echo  "${NEW_VERSION}" > version.txt
    git commit -m "Update Corretto version to match upstream: ${NEW_VERSION}" version.txt
fi
