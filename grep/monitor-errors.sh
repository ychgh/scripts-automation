#!/usr/bin/env bash
set -euo pipefail

pattern="${1:-ERROR|FATAL}"
shift || true

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <pattern> <file...>" >&2
  exit 1
fi

grep -En "$pattern" "$@"
