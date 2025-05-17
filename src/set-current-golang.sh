#!/usr/bin/env bash

# Exit on error, undefined variable, or failed pipeline command
set -euo pipefail

# Resolve the directory of this script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Load shared functions and variables (e.g., check_version, INSTALL_DIR, check_dependencies)
source "${SCRIPT_DIR}/common.sh"

# Remove any go-alts bin directories from PATH to avoid duplicates or conflicts
function clean_path {
    local original_path
    original_path="${PATH}"

    local new_path
    # Filter out any PATH entries starting with /usr/local/bin/go-alts
    new_path=$(echo "$original_path" | awk -F: '{s="";for(i=1;i<=NF;i++)if($i!~/^\/usr\/local\/bin\/go-alts/&&$i!="")s=(s==""?$i:s":"$i);print s}')

    echo "${new_path}"
}

function main {
    # Ensure required dependencies and environment are present
    if ! check_dependencies; then
        return 1
    fi

    local version
    version="$1"

    # Validate the provided version string format
    if ! check_version "$version"; then
        echo "Invalid or missing version" >&2
        echo "The following versions are installed:" >&2
        ls "${INSTALL_DIR}" >&2
        return 1
    fi

    # Verify the requested Go version is installed
    if [[ -d "${INSTALL_DIR}/${version}" ]]; then
        # Set GOROOT to the chosen version's go directory
        local goroot="${INSTALL_DIR}/${version}/go"
        local new_path="${goroot}/bin:$(clean_path)"

        # Output export statements for eval
        echo "export GOROOT=${goroot}"
        echo "export PATH=${new_path}"
    else
        echo "${version} was not found in ${INSTALL_DIR}" >&2
        return 1
    fi
}

main "$@"
