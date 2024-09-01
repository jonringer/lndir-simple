#!/usr/bin/env bash

set -eo pipefail

log() {
  echo "$@" >&2
}

usage() {
  log "lndir (simple) - Create shadow directories populated with symlinks to original source"
  log ""
  log "Usage:"
  log "  lndir <from dir> <to dir>"
}

fromDir=$1
toDir=$2

# Remove all optional arguments, we assume silent, and don't respect
# ignorelinks (deprecated) and -withrevinfo (not relevant for nix use case)
while [ "$#" -gt 0 ]; do
  i="$1"; shift 1
  case "$i" in
    -silent)
      shift 1
      ;;
    -ignorelinks)
      shift 1
      ;;
    -withrevinfo)
      shift 1
      ;;
    --help)
      usage
      exit 1
      ;;
    *)
      fromDir="$i"
      break
      ;;
  esac
done

# fromDir was parsed of arg loop
if [ "$#" -lt 1 ]; then
  log "must pass <from dir> and <to dir> to lndir";
  exit 1
fi

if [ "$#" -gt 1 ]; then
  log "too many arguments passed to lndir";
  exit 1
fi

toDir=$1

# Do a DFS traversal, creating directories as they are encountered.
# Files will be symlinked back to original source file
shadow_copy_dir() {
  local from="$1"
  local to="$2"

  for f in "${from}"/*; do
    local baseName=
    baseName="$(basename "$f")"

    if [ -d "${from}/$baseName" ]; then
      local newToDir="${to}/${baseName}"
      local newFromDir="${from}/${baseName}"

      mkdir -p "$newToDir"

      shadow_copy_dir "$newFromDir" "$newToDir"
    else
      fullFromPath="$(realpath "${from}/${baseName}")"

      ln -s "$fullFromPath" "${to}/$(basename "$f")"
    fi
  done
}

# Make the destination directory if it doesn't exist
if [ ! -e "$toDir" ] && [ -d "$fromDir" ]; then
  mkdir -p "$toDir"
fi

if [ ! -d "$fromDir" ]; then
  ln -s "$(realpath "$fromDir")" "$(realpath "$toDir")"
fi

shadow_copy_dir "$(realpath "$fromDir")" "$(realpath "$toDir")"
