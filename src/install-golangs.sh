#!/usr/bin/env bash

# Exit on error, undefined variable, or failed pipeline command
set -eou pipefail

# Resolve the directory of this script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Load shared functions and variables (e.g., check_version, INSTALL_DIR, check_dependencies)
source "${SCRIPT_DIR}/common.sh"

# URL components for Go tarball downloads
URL_PREFIX="https://go.dev/dl/go"
URL_SUFFIX=".tar.gz"

# Download and install a specific Go version
function download_and_install_version {
    local version
    local os
    local arch

    version="$1"
    os="$2"
    arch="$3"

    if [[ -z "${version}" || -z "${os}" || -z "${arch}" ]]; then
        echo "Error: Missing version, OS, or architecture"
        return 1
    fi

    if [[ -d "${INSTALL_DIR}/${version}" ]]; then
        echo "Go ${version} is already installed."
        return 0
    fi

    local tmp_dir
    tmp_dir="/tmp/go/${version}"

    sudo mkdir -p "${INSTALL_DIR}/${version}"
    mkdir -p "${tmp_dir}"

    pushd "${tmp_dir}" > /dev/null

    local tarball
    local url

    tarball="go${version}.${os}-${arch}.tar.gz"
    url="${URL_PREFIX}${version}.${os}-${arch}${URL_SUFFIX}"

    echo "Downloading: ${url}"
    if ! curl -L --fail -O "${url}"; then
        echo "Download failed: ${url}"
        return 1
    fi

    echo "Extracting: ${tarball}"
    if ! tar -xvf "${tarball}"; then
        echo "Failed to extract: ${tarball}"
        return 1
    fi

    echo "Installing to: ${INSTALL_DIR}/${version}"
    if ! sudo mv go "${INSTALL_DIR}/${version}"; then
        echo "Failed to move Go files"
        return 1
    fi

    rm -f "${tarball}"
    popd > /dev/null
    rm -rf "${tmp_dir}"
}

# Uninstall a specific Go version
function uninstall_go {
    local version
    version="$2"

    if [[ -z "${version}" ]]; then
        echo "Error: No version provided"
        return 1
    fi

    if [[ -d "${INSTALL_DIR}/${version}" ]]; then
        sudo rm -rf "${INSTALL_DIR:?}/${version}"
        echo "Uninstalled Go ${version}"
    else
        echo "Go version ${version} is not installed."
    fi
}

# Install a Go version using detected OS and architecture
function install_go {
    local version
    local os
    local arch

    version="$2"
    os="$(get_os)"
    arch="$(get_arch)"

    sudo mkdir -p "${INSTALL_DIR}"
    download_and_install_version "${version}" "${os}" "${arch}"
}

# Validate operation type
function check_operation {
    local operation
    operation="$1"

    case "${operation}" in
        i|install|u|uninstall)
            return 0
            ;;
        *)
            echo "Invalid operation '${operation}'. Use: i, install, u, uninstall"
            return 1
            ;;
    esac
}

# Validate CLI arguments
function check_args {
    local operation
    local version

    operation="$1"
    version="$2"

    check_operation "${operation}" && check_version "${version}"
}

# Main entry point
function main {
    check_dependencies || exit 1
    check_args "$@" || exit 1

    local operation
    local version

    operation="$1"
    version="$2"

    case "${operation}" in
        i|install)
            install_go "$@"
            ;;
        u|uninstall)
            uninstall_go "$@"
            ;;
    esac
}

main "$@"
