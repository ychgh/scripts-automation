#!/usr/bin/env bash
set -euo pipefail

pattern="ERROR|FATAL"
if [ "$#" -ge 2 ]; then
  pattern="$1"
  shift
fi

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [pattern] <file...>" >&2
  exit 1
fi

grep -En "$pattern" "$@"
