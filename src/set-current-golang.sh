#!/usr/bin/env bash

# Install all versions to this folder
INSTALL_DIR="/usr/local/bin/go-alts"

function clean_path {
    local original_path
    original_path="${PATH}"

    local new_path
    new_path=$(echo "$original_path" | awk -F: '{s="";for(i=1;i<=NF;i++)if($i!~/^\/usr\/local\/bin\/go-alts/&&$i!="")s=(s==""?$i:s":"$i);print s}')

    echo "${new_path}"
}

function main {
    local version
    version="$1"

    if [[ -z "${version}" ]]; then
        echo "no version provided to \$1"
        echo "The following versions are installed:"
        ls "${INSTALL_DIR}"
        return 1
    fi

    echo "Setting golang version to ${version}"

    if [[ -d "${INSTALL_DIR}/${version}" ]]; then
        GOROOT="${INSTALL_DIR}/${version}/go"
        echo "Setting GOROOT to ${GOROOT}"
        PATH="${INSTALL_DIR}/${version}/go/bin:$(clean_path)"
        echo "Setting PATH to ${PATH}"
        export GOROOT
        export PATH
    else
        echo "${version} was not found in ${INSTALL_DIR}"
        return 1
    fi

}

main "$@"
