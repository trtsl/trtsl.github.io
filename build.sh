#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ARGS=("$@")
DATE=$(date --utc --iso=seconds)
TRASH="${DIR}/_CLEANED/$DATE"

IGNORE=()
IGNORE+=("$0")
IGNORE+=('./.git')
IGNORE+=('./.gitignore')
IGNORE+=('./_CLEANED')

IGNORE+=('./index.html')

function all_files () {
    local ALL_FILES="$(find "$DIR" -mindepth 1 -maxdepth 1)"
    for elem in "${IGNORE[@]}"; do
        ALL_FILES="$(echo "${ALL_FILES}" | grep -v "^$(realpath "${DIR}/${elem}")$")"
    done
    echo "$ALL_FILES"
}

function rust_cargo () {
    local DST=$2
    local TARGET="${DIR}/${1}"

    echo "$PROJECT $DST"

    local TMP_DIR=$(mktemp -d)
    cargo doc --no-deps --manifest-path $DST --target-dir "$TMP_DIR"
    mv "${TMP_DIR}/doc" "$TARGET"
    echo "Created ${TARGET}"
    echo "Removing tmp directory ${TMP_DIR}"
    rm -rf "${TMP_DIR}"
}

function usage() {
    echo "Usage:"
    echo " $0 [path...]      Get docs for the specified 'Cargo.toml'"
    echo " $0 clean          Place previous buillds in directory '_CLEANED'"
    echo "where:"
    echo " path: path to a Cargo.toml"

}

ALL_FILES=($(all_files))
PROJECTS=()
case "${ARGS[0]}" in
    clean)
        if [ ${#ARGS[@]} -gt 1 ]; then
            usage 2>&1
            exit 1
        fi
        if [ ${#ALL_FILES[@]} -eq 0 ]; then
            echo "No files to clean" 2>&1
            exit 1
        fi
        echo "Moving files to $TRASH:"
        mkdir -p "${TRASH}"
        for elem in "${ALL_FILES[@]}"; do
            echo "$elem"
            mv "$elem" "$TRASH"
        done
        ;;
    -h|--help)
        usage 2>&1
        exit 0
        ;;
    *)
        if [ ${#ALL_FILES[@]} -gt 0 ]; then
            echo "Run \`$0 clean\` ... found files:" 2>&1
            printf '%s\n' "${ALL_FILES[@]}"
            exit 1
        fi

        # check inputs
        for cargo_toml in "${ARGS[@]}"; do
            if [ "${cargo_toml##*.}" != "toml" ]; then
                usage 2>&1
                exit 1
            fi
            PROJECT+=("$(awk -F'[ ="]+' '$1 == "name" { print $2 }' $cargo_toml)")
            PROJECTS+=($PROJECT)
        done

        echo "Found projects:"
        for ii in $(seq 0 $((${#ARGS[@]} - 1)) ); do
            echo "${PROJECTS[${ii}]} => ${ARGS[${ii}]}"
            rust_cargo "${PROJECTS[${ii}]}" "${ARGS[${ii}]}"
        done
        ;;
esac
