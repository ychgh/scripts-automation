#!/usr/bin/env bash
set -euo pipefail

pattern="ERROR|FATAL"
while getopts ":p:" opt; do
  case "$opt" in
    p) pattern="$OPTARG" ;;
    *) echo "Usage: $0 [-p pattern] <file...>" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [-p pattern] <file...>" >&2
  exit 1
fi

status=0
grep -En "$pattern" "$@" || status=$?
if [ "$status" -gt 1 ]; then
  exit "$status"
fi
