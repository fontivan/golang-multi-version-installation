#!/usr/bin/env bash

# Install all versions to this folder
INSTALL_DIR="/usr/local/bin/go-alts"

# Get the operating system name in lowercase (e.g., "linux", "darwin")
function get_os {
    local os_name
    os_name="$(uname | awk '{print tolower($0)}')"
    echo ${os_name}
}

# Get the machine architecture and normalize common values
# Converts "x86_64" to "amd64" and "aarch64" to "arm64"
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

# Check if a version string is a valid semantic version (e.g., "1.20.3")
# Returns 0 if valid, 1 otherwise
function check_version {
    local version
    version="$1"

    # Ensure a version argument was provided
    if [[ -z "${version}" ]]; then
        echo "version not provided"
        return 1
    fi

    # Validate version format: must be digits separated by two dots (e.g., 1.20.3)
    if [[ "${version}" =~ ^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
        return 0
    else
        echo "Could not match version to a valid go version"
        return 1
    fi
}

# Check that required commands are available before proceeding
function check_dependencies {
    local missing=0
    local deps=(awk curl tar sudo)

    for cmd in "${deps[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            echo "Error: '${cmd}' is required but not installed or not in PATH."
            missing=1
        fi
    done

    if [[ "${missing}" -eq 1 ]]; then
        echo "Please install the missing dependencies and try again."
        return 1
    fi

    return 0
}
