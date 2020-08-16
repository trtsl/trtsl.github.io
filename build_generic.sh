#!/bin/bash

# NOTE: ensure to declare `local` and `readonly` variables on a separate line
# from a command substitution because `set -e` will fail to recognize an error
# occured with e.g. `readonly x=$(ls -z)` because:
# https://google.github.io/styleguide/shellguide.html#s7.6-use-local-variables
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"

ARGS=("$@")
DATE=$(date --utc --iso=seconds)
TRASH="${DIR}/_CLEANED/$DATE"

# associative array
declare -A IGNORE
IGNORE["$0"]=1
# `build.sh` calls this script with arguments specified
IGNORE["${DIR}/build.sh"]=1
IGNORE["${DIR}/.git"]=1
IGNORE["${DIR}/.gitignore"]=1
IGNORE["${DIR}/_CLEANED"]=1
IGNORE["${DIR}/index.html"]=1

readonly DIR ARGS DATE TRASH IGNORE

function get_files () {
    local files
    readarray -d '' files < <(find "$DIR" -mindepth 1 -maxdepth 1 -print0)

    # `output` is a nameref to allow returning an array from this function
    local -n output=$1
    output=()
    for f in "${files[@]}"; do
        if [[ -z ${IGNORE["$f"]+x} ]]; then
            output+=("$f")
        fi
    done
}

function rust_cargo () {
    local dst=$2
    local target="${DIR}/${1}"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    readonly tmp_dir

    if ! [[ -z "$(ls -A $tmp_dir)" ]]; then
        echo "DANGER: expected empty directory '$tmp_dir'" 1>&2
        exit 1
    fi
    cargo doc --no-deps --manifest-path $dst --target-dir "$tmp_dir"
    mv "${tmp_dir}/doc" "$target"
    echo "Created ${target}"
    if [[ -f "${tmp_dir}/.rustc_info.json" ]]; then
        echo "Removing tmp directory ${tmp_dir}"
        rm -rf "${tmp_dir}"
    else
        printf "\nError: Failed safefy check when attempting to remove ${tmp_dir}\n" 1>&2
        exit 1
    fi
}

function usage() {
    echo "Usage:"
    echo " $0 [path...]      Get docs for the specified 'Cargo.toml'"
    echo " $0 clean          Place previous buillds in directory '_CLEANED'"
    echo "where:"
    echo " path: path to a Cargo.toml"
}

function run() {
    local -a trash_files
    get_files trash_files
    readonly trash_files

    case "${ARGS[0]}" in
        clean)
            if [[ ${#ARGS[@]} -gt 1 ]]; then
                usage 1>&2
                exit 1
            fi
            if [[ ${#trash_files[@]} -eq 0 ]]; then
                echo "No files to clean" 1>&2
                exit 0
            fi
            echo "Moving files to $TRASH:"
            mkdir -p "${TRASH}"
            for f in "${trash_files[@]}"; do
                echo "$f"
                mv "$f" "$TRASH"
            done
            printf "\nContents of ${DIR}/_CLEANED:\n"
            du -hd 1 "${DIR}/_CLEANED"
            ;;
        -h|--help)
            usage 1>&2
            exit 0
            ;;
        *)
            if [[ ${#trash_files[@]} -gt 0 ]]; then
                echo "Run \`$0 clean\` ... found files:" 1>&2
                printf '%s\n' "${trash_files[@]}"
                exit 1
            fi

            # check inputs
            for cargo_toml in "${ARGS[@]}"; do
                if [[ "${cargo_toml##*.}" != "toml" ]]; then
                    usage 1>&2
                    exit 1
                fi
                projects+=("$(awk -F'[ ="]+' '$1 == "name" { print $2 }' $cargo_toml)")
            done

            echo "Found projects:"
            local path proj
            for ii in $(seq 0 $((${#ARGS[@]} - 1)) ); do
                proj="${projects[${ii}]}"
                path="$( realpath -e "${ARGS[${ii}]}" )"
                echo "$proj => $path"
                rust_cargo "$proj" "$path"
            done
            ;;
    esac
}

run
exit 0
