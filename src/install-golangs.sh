#!/usr/bin/env bash

set -eou pipefail

GOLANG_VERSIONS=(
    "1.20.14"
    "1.21.13"
    "1.22.12"
    "1.23.8"
)

# Example URL
# https://go.dev/dl/go1.23.9.linux-amd64.tar.gz"
URL_PREFIX="https://go.dev/dl/go"
URL_SUFFIX=".tar.gz"

# Install all versions to this folder
INSTALL_DIR="/usr/local/bin/go-alts"

function get_os {
    local os_name
    os_name="$(uname | awk '{print tolower($0)}')"
    echo ${os_name}
}

function get_arch {
    local arch_name
    arch_name=$(uname -m)
    if [[ "${arch_name}" == "x86_64" ]]; then
        arch_name="amd64"
    fi
    if [[ "${arch_name}" == "aarch64" ]]; then
        arch_name="arm64"
    fi
    echo "${arch_name}"
}

function download_and_install_version {
    local version
    version="$1"

    local os
    os="$2"

    local arch
    arch="$3"

    if [[ -z "${version}" ]]; then
        echo "no version provided"
        return 1
    fi

    if [[ -z "${os}" ]]; then
        echo "no os provided"
        return 1
    fi

    if [[ -z "${arch}" ]]; then
        echo "no arch provided"
        return 1
    fi

    if [[ -d "${INSTALL_DIR}/${version}" ]]; then
        echo "${version} already installed"
        return 0
    fi

    sudo mkdir -p "${INSTALL_DIR}/${version}"
    (
        mkdir -p "/tmp/go/${version}"
        if ! cd "/tmp/go/${version}"; then
            echo "Failed to initialize temp directory"
            return 1
        fi

        echo "Download file: ${URL_PREFIX}${version}.${os}-${arch}${URL_SUFFIX}"
        if ! curl -L -O "${URL_PREFIX}${version}.${os}-${arch}${URL_SUFFIX}"; then
            echo "Failed to download file"
            return 1
        fi

        if ! tar -xvf "go${version}.${os}-${arch}.tar.gz"; then
            echo "Failed to unpack file"
            return 1
        fi

        if ! sudo mv go "${INSTALL_DIR}/${version}"; then
            echo "Failed to move files to install dir"
            return 1
        fi

        if ! rm "go${version}.${os}-${arch}.tar.gz"; then
            echo "Failed to cleanup tarball"
            return 1
        fi
    )
}

function install_all {
    local os
    os="$(get_os)"

    local arch
    arch="$(get_arch)"

    sudo mkdir -p "${INSTALL_DIR}"

    local current_version
    for current_version in "${GOLANG_VERSIONS[@]}"; do
        download_and_install_version "${current_version}" "${os}" "${arch}"
    done
}

function main {
    if ! install_all; then
        return 1
    fi
}

main
