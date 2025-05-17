#!/usr/bin/env bash

# Normally I would prefer to set these options, but since this has to be sourced it causes a lot of problems with the interactive shell
# set -eou pipefail

# Since this script has to be sourced, it needs to work in zsh too
if [[ -n "${BASH_VERSION-}" ]]; then
    SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [[ -n "${ZSH_VERSION-}" ]]; then
    SCRIPT_PATH="${(%):-%N}"
else
    echo "Unsupported shell" >&2
    exit 1
fi

# Use subshell to avoid cd affecting current directory
SCRIPT_DIR=$(cd -- "$(dirname -- "$SCRIPT_PATH")" &> /dev/null && pwd)

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
    if ! check_version "$1"; then
        echo "Invalid or missing version"
        echo "The following versions are installed:"
        ls "${INSTALL_DIR}"
        return 1
    fi

    echo "Setting current golang version to ${version}"

    # Verify the requested Go version is installed
    if [[ -d "${INSTALL_DIR}/${version}" ]]; then
        # Set GOROOT to the chosen version's go directory
        GOROOT="${INSTALL_DIR}/${version}/go"

        # Prepend the chosen Go version's bin directory to PATH, cleaning old entries
        PATH="${INSTALL_DIR}/${version}/go/bin:$(clean_path)"

        echo "Setting GOROOT to '${GOROOT}'"
        echo "Setting PATH to '${PATH}'"

        # Export variables for current shell session
        export GOROOT
        export PATH
    else
        # Error if the requested version directory does not exist
        echo "${version} was not found in ${INSTALL_DIR}"
        return 1
    fi
}

main "$@"
